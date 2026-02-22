import 'dart:io';

import 'package:core_shared/core_shared.dart' show DependencyInjector;
import 'package:school_server/school_server.dart' show InitSchoolModuleToServer;
import 'package:server_base/server_base.dart';

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

  final di = await registryBaseInfrastructure(config, loggerName: 'SMS SERVER V1');
  await registryCommonModules(di, config);

  // Módulo específico do SMS
  await InitSchoolModuleToServer.init(
    di: di,
    backendBaseApi: Env.backendPathApi,
    security: false,
  );

  return di;
}
