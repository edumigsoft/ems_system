import 'package:auth_server/auth_server.dart' show InitAuthModuleToServer;
import 'package:core_shared/core_shared.dart' show DependencyInjector;
import 'package:user_server/user_server.dart' show InitUserModuleToServer;

import '../config/server_base_config.dart';

Future<void> registryCommonModules(
  DependencyInjector di,
  ServerBaseConfig config,
) async {
  await InitUserModuleToServer.init(
    di: di,
    backendBaseApi: config.backendPathApi,
  );

  await InitAuthModuleToServer.init(
    di: di,
    backendBaseApi: config.backendPathApi,
    security: false,
    accessTokenExpiresMinutes: config.accessTokenExpiresMinutes,
    refreshTokenExpiresDays: config.refreshTokenExpiresDays,
    verificationLinkBaseUrl: config.verificationLinkBaseUrl,
  );
}
