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
  final jwtKey = Platform.environment['JWT_KEY'] ??
      (throw StateError('JWT_KEY is required but not set in environment'));

  final verificationLinkBaseUrl =
      Platform.environment['VERIFICATION_LINK_BASE_URL'] ??
      (throw StateError(
        'VERIFICATION_LINK_BASE_URL is required but not set in environment',
      ));

  final config = ServerBaseConfig(
    dbHost: Platform.environment['DB_HOST'] ??
        (throw StateError('DB_HOST is required but not set in environment')),
    dbPort: int.tryParse(
          Platform.environment['DB_PORT'] ??
              (throw StateError(
                'DB_PORT is required but not set in environment',
              )),
        ) ??
        (throw StateError('DB_PORT must be a valid integer')),
    dbUser: Platform.environment['DB_USER'] ??
        (throw StateError('DB_USER is required but not set in environment')),
    dbPass: Platform.environment['DB_PASS'] ??
        (throw StateError('DB_PASS is required but not set in environment')),
    dbName: Platform.environment['DB_NAME'] ??
        (throw StateError('DB_NAME is required but not set in environment')),
    dbUseSsl: false,
    jwtKey: jwtKey,
    backendPathApi: Env.backendPathApi,
    accessTokenExpiresMinutes: Env.accessTokenExpiresMinutes,
    refreshTokenExpiresDays: Env.refreshTokenExpiresDays,
    verificationLinkBaseUrl: verificationLinkBaseUrl,
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
