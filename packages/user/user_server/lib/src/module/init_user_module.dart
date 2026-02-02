import 'package:auth_server/auth_server.dart' show AuthMiddleware;
import 'package:core_server/core_server.dart'
    show InitServerModule, DatabaseProvider, addRoutes;
import 'package:core_shared/core_shared.dart' show DependencyInjector;
import 'package:user_shared/user_shared.dart' show UserRepository;

import '../repository/user_repository_server.dart';
import '../database/user_database.dart';
import '../queries/user_queries.dart';
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

    // 2. Queries
    di.registerLazySingleton<UserQueries>(
      () => UserQueries(userDb),
    );

    // 3. Repository
    di.registerLazySingleton<UserRepository>(
      () => UserRepositoryServer(di.get<UserQueries>()),
    );

    // 4. Routes
    di.registerLazySingleton<UserRoutes>(
      () => UserRoutes(
        di.get<UserRepository>(),
        di.get<AuthMiddleware>(),
        di, // Passa DI para lazy resolution de AuthService
        backendBaseApi: backendBaseApi,
      ),
    );

    // 5. Mount Routes
    // Nota: security=false porque UserRoutes gerencia sua própria autenticação
    // internamente via AuthMiddleware, não dependendo do authRequired global
    addRoutes(di, di.get<UserRoutes>(), security: false);
  }
}
