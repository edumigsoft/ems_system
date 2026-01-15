import 'package:core_shared/core_shared.dart';
import 'package:core_server/core_server.dart';
import 'package:user_server/user_server.dart';
import 'package:auth_server/auth_server.dart';

import '../database/auth_database.dart';

/// Inicializa o módulo de autenticação no servidor.
///
/// Registra repositories, services, middlewares e rotas.
class InitAuthModuleToServer implements InitServerModule {
  static Future<void> init({
    required DependencyInjector di,
    required String backendBaseApi,
    bool security = true,
  }) async {
    // 1. Database & Repositories
    final dbProvider = di.get<DatabaseProvider>();

    // Cria a instância do banco de dados modular usando o executor do provider
    final authDb = AuthDatabase(dbProvider.executor);

    // Inicializa tabelas se necessário
    await authDb.init();

    di.registerSingleton<AuthDatabase>(authDb);

    di.registerLazySingleton<AuthRepository>(() => AuthRepository(authDb));

    // Feature User Role Repositories
    di.registerLazySingleton<ProjectUserRoleRepository>(
      () => ProjectUserRoleRepository(authDb),
    );

    // 2. Services
    di.registerLazySingleton<AuthService>(
      () => AuthService(
        authRepo: di.get<AuthRepository>(),
        userRepo: di.get<UserRepository>(),
        securityService: di
            .get<SecurityService>(), // Deve ser registrado pelo CoreModule
        cryptService: di
            .get<CryptService>(), // Deve ser registrado pelo CoreModule
        emailService: di
            .get<EmailService>(), // Deve ser registrado pelo CoreModule
        // Obter config de env vars
        accessTokenExpiresMinutes: 15,
        refreshTokenExpiresDays: 7,
      ),
    );

    // Feature User Role Services
    di.registerLazySingleton<ProjectUserRoleService>(
      () => ProjectUserRoleService(di.get<ProjectUserRoleRepository>()),
    );

    // 3. Middleware
    // NOTA: AuthMiddleware está pré-registrado no injector global (antes do UserModule)
    // para resolver dependência circular com UserRoutes

    // Feature Role Middleware (genérico)
    di.registerLazySingleton<FeatureRoleMiddleware>(
      () => FeatureRoleMiddleware(di.get<ProjectUserRoleRepository>()),
    );

    // 4. Routes
    di.registerLazySingleton<AuthRoutes>(
      () => AuthRoutes(di.get<AuthService>(), backendBaseApi: backendBaseApi),
    );

    // Feature User Role Routes
    di.registerLazySingleton<ProjectUserRoleRoutes>(
      () => ProjectUserRoleRoutes(
        di.get<ProjectUserRoleService>(),
        backendBaseApi: backendBaseApi,
      ),
    );

    // Adicionar rotas ao servidor
    addRoutes(di, di.get<AuthRoutes>(), security: security);
    addRoutes(di, di.get<ProjectUserRoleRoutes>(), security: security);
  }
}
