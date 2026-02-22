import 'dart:io';

import 'package:core_server/core_server.dart'
    show AddRoutes, ApiKeyMiddleware, RateLimit, Server;
import 'package:core_shared/core_shared.dart'
    show DependencyInjector, LogService;
import 'package:shelf/shelf.dart' hide Server;

/// Inicializa e executa o servidor HTTP com a infraestrutura padrão.
///
/// Configura automaticamente:
/// - Rate limiting (20 req/min)
/// - API Key middleware
/// - Pipeline de middlewares (rate limit → api key → log → rotas)
/// - Tratamento de erros fatais com exit code 1
///
/// **Importante:** [LogService.init()] deve ser chamado antes desta função,
/// pois a configuração de injeção de dependência ([registryBaseInfrastructure])
/// já utiliza o logger durante sua inicialização.
///
/// Exemplo de uso no `bin/server.dart`:
/// ```dart
/// void main() async {
///   await LogService.init(LogLevel.verbose, writeToFile: true);
///   initializeReflectable();
///   final di = await registryInjectors();
///   await runServer(
///     di: di,
///     apiKey: Env.apiKey,
///     backendPathApi: Env.backendPathApi,
///     port: Env.serverPort,
///     urlDoc: Env.enableDocs,
///   );
/// }
/// ```
Future<void> runServer({
  required DependencyInjector di,
  required String apiKey,
  required String backendPathApi,
  required int port,
  required bool urlDoc,
}) async {
  final rateLimit = RateLimit(
    requestsPerPeriod: 20,
    period: Duration(minutes: 1),
  );
  final apiKeyMiddleware = ApiKeyMiddleware(apiKey: apiKey);
  final addRoutes = di.get<AddRoutes>();

  final handler = Pipeline()
      .addMiddleware(rateLimit.middleware)
      .addMiddleware(apiKeyMiddleware.middleware)
      .addMiddleware(logRequests())
      .addHandler(addRoutes.call);

  try {
    await Server().initialize(
      handler: handler,
      address: InternetAddress.anyIPv4,
      backendPathApi: backendPathApi,
      port: port,
      urlDoc: urlDoc,
    );
  } catch (e, s) {
    LogService.getLogger('main').severe(
      'Erro fatal ao inicializar o servidor.',
      e,
      s,
    );
    exit(1);
  }
}
