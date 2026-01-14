import 'package:core_server/core_server.dart';
import 'package:core_shared/core_shared.dart';
import 'package:auth_server/auth_server.dart';

import '../repository/user_repository.dart';
import '../repository/user_repository_impl.dart';
import '../database/user_database.dart';
import '../routes/user_routes.dart';

/// Inicializa o módulo de usuários no servidor.
///
/// Registra o [UserRepository] e [UserRoutes] no injetor de dependências
/// e configura as rotas no servidor.
///
/// Exemplo:
/// ```dart
/// await initUserModule(
///   di: di,
///   backendBaseApi: '/api/v1',
/// );
/// ```
class InitUserModuleToServer implements InitServerModule {
  static Future<void> init({
    required DependencyInjector di,
    required String backendBaseApi,
    bool security = true,
  }) async {
    // 1. Database
    final dbProvider = di.get<DatabaseProvider>();
    final userDb = UserDatabase(dbProvider.executor);

    // Inicializa tabelas se necessário
    await userDb.init();

    di.registerSingleton<UserDatabase>(userDb);

    // 2. Repository
    di.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(userDb));

    // 3. Routes
    di.registerLazySingleton<UserRoutes>(
      () => UserRoutes(
        di.get<UserRepository>(),
        di.get<AuthMiddleware>(),
        backendBaseApi: backendBaseApi,
      ),
    );

    // 4. Mount Routes
    addRoutes(di, di.get<UserRoutes>(), security: security);
  }
}
