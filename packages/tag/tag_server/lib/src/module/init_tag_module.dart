import 'package:auth_server/auth_server.dart' show AuthMiddleware;
import 'package:core_server/core_server.dart'
    show InitServerModule, DatabaseProvider, addRoutes;
import 'package:core_shared/core_shared.dart' show DependencyInjector;
import 'package:tag_shared/tag_shared.dart' show TagRepository;

import '../database/tag_database.dart';
import '../repository/tag_repository_server.dart';
import '../routes/tag_routes.dart';

class InitTagModuleToServer implements InitServerModule {
  static Future<void> init({
    required DependencyInjector di,
    required String backendBaseApi,
    bool security = true,
  }) async {
    // 1. Database
    final dbProvider = di.get<DatabaseProvider>();
    final tagDb = TagDatabase(dbProvider.executor);

    await tagDb.init();

    di.registerSingleton<TagDatabase>(tagDb);

    di.registerLazySingleton<TagRepository>(
      () => TagRepositoryServer(tagDb),
    );

    di.registerLazySingleton<TagRoutes>(
      () => TagRoutes(
        di.get<TagRepository>(),
        di.get<AuthMiddleware>(),
        di, // Passa DI para lazy resolution de AuthService
        backendBaseApi: backendBaseApi,
      ),
    );

    addRoutes(di, di.get<TagRoutes>(), security: false);
  }
}
