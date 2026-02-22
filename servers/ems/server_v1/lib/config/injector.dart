import 'dart:io';

import 'package:auth_server/auth_server.dart' show AuthMiddleware;
import 'package:core_server/core_server.dart'
    show FileRoutes, StorageService, addRoutes;
import 'package:core_shared/core_shared.dart' show DependencyInjector;
import 'package:notebook_server/notebook_server.dart'
    show InitNotebookModuleToServer;
import 'package:server_base/server_base.dart';
import 'package:tag_server/tag_server.dart' show InitTagModuleToServer;

import 'env/env.dart';

Future<DependencyInjector> registryInjectors() async {
  final config = ServerBaseConfig(
    dbHost: Platform.environment['DB_HOST'] ?? 'localhost',
    dbPort:
        int.tryParse(Platform.environment['DB_PORT'] ?? EnvDatabase.dbPort) ??
        5432,
    dbUser: Platform.environment['DB_USER'] ?? EnvDatabase.dbUser,
    dbPass: Platform.environment['DB_PASS'] ?? EnvDatabase.dbPass,
    dbName: Platform.environment['DB_NAME'] ?? EnvDatabase.dbName,
    dbUseSsl: false,
    jwtKey: Env.jwtKey,
    backendPathApi: Env.backendPathApi,
    accessTokenExpiresMinutes: Env.accessTokenExpiresMinutes,
    refreshTokenExpiresDays: Env.refreshTokenExpiresDays,
    verificationLinkBaseUrl: Env.verificationLinkBaseUrl,
    appVersion: Platform.environment['APP_VERSION'],
    environment:
        Platform.environment['ENV'] ?? Platform.environment['ENVIRONMENT'],
  );

  final di = await registryBaseInfrastructure(config, loggerName: 'EMS SERVER V1');
  await registryCommonModules(di, config);

  // Módulos específicos do EMS
  await InitTagModuleToServer.init(
    di: di,
    backendBaseApi: Env.backendPathApi,
    security: false,
  );

  await InitNotebookModuleToServer.init(
    di: di,
    backendBaseApi: Env.backendPathApi,
    security: false,
  );

  di.registerLazySingleton<FileRoutes>(
    () => FileRoutes(
      di.get<StorageService>(),
      di.get<AuthMiddleware>().verifyJwt,
      backendBaseApi: Env.backendPathApi,
    ),
  );
  addRoutes(di, di.get<FileRoutes>(), security: false);

  return di;
}
