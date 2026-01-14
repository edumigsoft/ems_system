import 'package:core_shared/core_shared.dart';
import 'package:core_server/core_server.dart';
import 'package:user_server/user_server.dart';
import 'package:auth_server/auth_server.dart';

import '../database/auth_database.dart';
import '../middleware/resource_permission_middleware.dart';

/// Inicializa o módulo de autenticação no servidor.
///
/// Registra repositories, services, middlewares e rotas.
Future<void> initAuthModule({required DependencyInjector di}) async {
  // 1. Database & Repositories
  final dbProvider = di.get<DatabaseProvider>();
  // Cria a instância do banco de dados modular usando o executor do provider
  final authDb = AuthDatabase(dbProvider.executor);
  di.registerSingleton<AuthDatabase>(authDb);

  di.registerLazySingleton<AuthRepository>(() => AuthRepository(authDb));
  di.registerLazySingleton<ResourcePermissionRepository>(
    () => ResourcePermissionRepository(authDb),
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
      // TODO: Obter config de env vars
      accessTokenExpiresMinutes: 15,
      refreshTokenExpiresDays: 7,
    ),
  );

  di.registerLazySingleton<ResourcePermissionService>(
    () => ResourcePermissionService(di.get<ResourcePermissionRepository>()),
  );

  // 3. Middleware
  di.registerLazySingleton<AuthMiddleware>(
    () => AuthMiddleware(di.get<SecurityService>()),
  );

  di.registerLazySingleton<ResourcePermissionMiddleware>(
    () => ResourcePermissionMiddleware(di.get<ResourcePermissionService>()),
  );

  // 4. Routes
  di.registerLazySingleton<AuthRoutes>(() => AuthRoutes(di.get<AuthService>()));

  // Adicionar rotas ao servidor
  await addRoutes(di, di.get<AuthRoutes>());
}
