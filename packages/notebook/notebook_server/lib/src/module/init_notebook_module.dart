import 'package:auth_server/auth_server.dart' show AuthMiddleware;
import 'package:core_server/core_server.dart'
    show InitServerModule, DatabaseProvider, addRoutes;
import 'package:core_shared/core_shared.dart' show DependencyInjector;
import 'package:notebook_shared/notebook_shared.dart' show NotebookRepository;

import '../repository/notebook_repository_server.dart';
import '../database/notebook_database.dart';
import '../routes/notebook_routes.dart';

/// Inicializa o módulo de notebooks no servidor.
///
/// Registra o [NotebookRepository] e [NotebookRoutes] no injetor de dependências
/// e configura as rotas no servidor.
///
/// Exemplo:
/// ```dart
/// await initNotebookModule(
///   di: di,
///   backendBaseApi: '/api/v1',
/// );
/// ```
class InitNotebookModuleToServer implements InitServerModule {
  static Future<void> init({
    required DependencyInjector di,
    required String backendBaseApi,
    bool security = true,
  }) async {
    // 1. Database
    final dbProvider = di.get<DatabaseProvider>();
    final notebookDb = NotebookDatabase(dbProvider.executor);

    // Inicializa tabelas se necessário
    await notebookDb.init();

    di.registerSingleton<NotebookDatabase>(notebookDb);

    // 2. Repository
    di.registerLazySingleton<NotebookRepository>(
      () => NotebookRepositoryServer(notebookDb),
    );

    // 3. Routes
    di.registerLazySingleton<NotebookRoutes>(
      () => NotebookRoutes(
        di.get<NotebookRepository>(),
        di.get<AuthMiddleware>(),
        di, // Passa DI para lazy resolution de AuthService
        backendBaseApi: backendBaseApi,
      ),
    );

    // 4. Mount Routes
    // Nota: security=false porque NotebookRoutes gerencia sua própria autenticação
    // internamente via AuthMiddleware, não dependendo do authRequired global
    addRoutes(di, di.get<NotebookRoutes>(), security: false);
  }
}
