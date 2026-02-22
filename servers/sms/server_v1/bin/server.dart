import 'dart:io';

import 'package:core_shared/core_shared.dart' show LogService, LogLevel;
import 'package:sms_server_v1/config/env/env.dart';
import 'package:sms_server_v1/config/injector.dart';
import 'package:open_api_shared/open_api_shared.dart' show api, ApiInfo;
import 'package:server_base/server_base.dart' show runServer;

import 'server.reflectable.dart';

// Metadados para geração do Swagger — não remover esta classe.
const version = String.fromEnvironment('APP_VERSION', defaultValue: 'unknown');

@api
@ApiInfo(
  title: 'SMS System API',
  version: version,
  description: 'API para o SMS System',
)
class Document {}

void main() async {
  // LogLevel.verbose = desenvolvimento | .info = staging | .warning = produção
  await LogService.init(LogLevel.verbose, writeToFile: true);
  initializeReflectable();

  final di = await registryInjectors();

  final apiKey = Platform.environment['API_KEY'] ??
      (throw StateError('API_KEY is required but not set in environment'));

  await runServer(
    di: di,
    apiKey: apiKey,
    backendPathApi: Env.backendPathApi,
    port: Env.serverPort,
    urlDoc: Env.enableDocs,
  );
}
