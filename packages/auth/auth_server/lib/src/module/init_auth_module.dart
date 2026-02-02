import 'package:core_server/core_server.dart'
    show
        InitServerModule,
        DatabaseProvider,
        SecurityService,
        CryptService,
        EmailService,
        addRoutes;
import 'package:core_shared/core_shared.dart' show DependencyInjector;
import 'package:user_shared/user_shared.dart' show UserRepository;

import '../../auth_server.dart';

import '../database/auth_database.dart';

/// Inicializa o módulo de autenticação no servidor.
///
/// Registra repositories, services, middlewares e rotas.
class InitAuthModuleToServer implements InitServerModule {
  static Future<void> init({
    required DependencyInjector di,
    required String backendBaseApi,
    bool security = true,
    int accessTokenExpiresMinutes = 15,
    int refreshTokenExpiresDays = 7,
    String verificationLinkBaseUrl = 'http://localhost:8181/api/v1/auth/verify',
  }) async {
    // 1. Database & Repositories
    final dbProvider = di.get<DatabaseProvider>();

    // Cria a instância do banco de dados modular usando o executor do provider
    final authDb = AuthDatabase(dbProvider.executor);

    // Inicializa tabelas se necessário
    await authDb.init();

    di.registerSingleton<AuthDatabase>(authDb);

    di.registerLazySingleton<AuthRepository>(() => AuthRepository(authDb));

    // 2. Services
    di.registerLazySingleton<AuthService>(
      () => AuthService(
        authRepo: di.get<AuthRepository>(),
        userRepo: di.get<UserRepository>(),
        securityService: di
            .get<
              SecurityService<dynamic>
            >(), // Deve ser registrado pelo CoreModule
        cryptService: di
            .get<CryptService>(), // Deve ser registrado pelo CoreModule
        emailService: di
            .get<EmailService>(), // Deve ser registrado pelo CoreModule
        // Configurações injetadas
        accessTokenExpiresMinutes: accessTokenExpiresMinutes,
        refreshTokenExpiresDays: refreshTokenExpiresDays,
        verificationLinkBaseUrl: verificationLinkBaseUrl,
      ),
    );

    // 3. Middleware
    // NOTA: AuthMiddleware está pré-registrado no injector global (antes do UserModule)
    // para resolver dependência circular com UserRoutes

    // 4. Routes
    di.registerLazySingleton<AuthRoutes>(
      () => AuthRoutes(di.get<AuthService>(), backendBaseApi: backendBaseApi),
    );

    // Adicionar rotas ao servidor
    addRoutes(di, di.get<AuthRoutes>(), security: security);
  }
}
