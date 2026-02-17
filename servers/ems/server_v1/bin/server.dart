import 'dart:io';

import 'package:core_server/core_server.dart' show AddRoutes, RateLimit, Server;
import 'package:core_shared/core_shared.dart' show LogService, LogLevel;
import 'package:ems_server_v1/config/env/env.dart';
import 'package:ems_server_v1/config/injector.dart';
import 'package:open_api_shared/open_api_shared.dart' show api, ApiInfo;
import 'package:shelf/shelf.dart' hide Server;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'server.reflectable.dart';

// -------------Somente para gerar Swagger---------------

const version = String.fromEnvironment('APP_VERSION', defaultValue: 'unknown');

@api
@ApiInfo(
  title: 'EMS System API',
  version: version,
  description: 'API para o EMS System',
)
class Document {}
// -------------Somente para gerar Swagger---------------

void main() async {
  // Inicializa o serviço de log com o nível mínimo para DEVELOPMENT e log em arquivo
  await LogService.init(
    LogLevel.verbose, // Mostra tudo: verbose, debug, info, warning, error
    writeToFile: true, // Opcional: habilita log em arquivo em dev também
  );

  // Opcional: Log para confirmar o ambiente
  final logger = LogService.getLogger('Environment');
  logger.info('Running in DEVELOPMENT environment with verbose logging.');

  // // Inicializa o serviço de log com o nível mínimo para PRODUCTION e log em arquivo
  // await LogService.init(
  //   LogLevel.warning, // Mostra warning, error
  //   writeToFile:
  //       true, // Habilita log em arquivo em produção para rastreabilidade
  // );

  // // Opcional: Log para confirmar o ambiente
  // final logger = LogService.getLogger('Environment');
  // logger.info(
  //   'Running in PRODUCTION environment with warning+ logging.',
  // );

  // // Inicializa o serviço de log com o nível mínimo para STAGING e log em arquivo
  // await LogService.init(
  //   LogLevel.info, // Mostra info, warning, error
  //   writeToFile: true, // Habilita log em arquivo em staging
  // );

  // // Opcional: Log para confirmar o ambiente
  // final logger = LogService.getLogger('Environment');
  // logger.info('Running in STAGING environment with info+ logging.');

  initializeReflectable();

  final di = await registryInjectors();

  final rateLimit = RateLimit(
    requestsPerPeriod: 20,
    period: Duration(minutes: 1),
  );

  final allowedOrigins = Env.allowedOrigins.trim().split(',');
  final addRouters = di.get<AddRoutes>();
  final handler = Pipeline()
      .addMiddleware(
        corsHeaders(
          originChecker: allowedOrigins.contains,
          headers: {
            'Access-Control-Allow-Headers': 'Authorization, Content-Type',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          },
        ),
      )
      .addMiddleware(rateLimit.middleware)
      .addMiddleware(logRequests())
      .addHandler(addRouters.call);

  try {
    await Server().initialize(
      handler: handler,
      address: InternetAddress.anyIPv4,
      backendPathApi: Env.backendPathApi,
      port: Env.serverPort,
      urlDoc: Env.enableDocs,
    );
  } catch (e, s) {
    LogService.getLogger(
      'main',
    ).severe('Erro fatal ao inicializar o servidor.', e, s);
    // Em produção, considere enviar o erro para um serviço de monitoramento (Sentry, etc.)
    exit(1); // Encerra a aplicação com código de erro
  }
}
