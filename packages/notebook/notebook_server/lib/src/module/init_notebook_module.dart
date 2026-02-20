import 'package:auth_server/auth_server.dart' show AuthMiddleware;
import 'package:core_server/core_server.dart'
    show
        InitServerModule,
        DatabaseProvider,
        addRoutes,
        StorageService,
        LocalStorageService;
import 'package:core_shared/core_shared.dart' show DependencyInjector;
import 'package:notebook_shared/notebook_shared.dart'
    show NotebookRepository, DocumentReferenceRepository;
import 'dart:io';

import '../repository/notebook_repository_server.dart';
import '../repository/document_reference_repository_server.dart';
import '../database/notebook_database.dart';
import '../routes/notebook_routes.dart';
import '../routes/document_routes.dart';

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
    String uploadsPath = 'uploads',
    bool security = true,
  }) async {
    // 1. Database
    final dbProvider = di.get<DatabaseProvider>();
    final notebookDb = NotebookDatabase(dbProvider.executor);

    // Inicializa tabelas se necessário
    await notebookDb.init();

    di.registerSingleton<NotebookDatabase>(notebookDb);

    // 2. Storage Service
    final storagePath = Platform.environment['UPLOAD_PATH'] ?? uploadsPath;
    di.registerLazySingleton<StorageService>(
      () => LocalStorageService(basePath: storagePath),
    );

    // 3. Repositories
    di.registerLazySingleton<NotebookRepository>(
      () => NotebookRepositoryServer(notebookDb),
    );

    di.registerLazySingleton<DocumentReferenceRepository>(
      () => DocumentReferenceRepositoryServer(notebookDb),
    );

    // 4. Routes
    di.registerLazySingleton<NotebookRoutes>(
      () => NotebookRoutes(
        di.get<NotebookRepository>(),
        di.get<DocumentReferenceRepository>(),
        di.get<StorageService>(),
        di.get<AuthMiddleware>(),
        di, // Passa DI para lazy resolution de AuthService
        backendBaseApi: backendBaseApi,
      ),
    );

    di.registerLazySingleton<DocumentRoutes>(
      () => DocumentRoutes(
        di.get<DocumentReferenceRepository>(),
        di.get<StorageService>(),
        di.get<AuthMiddleware>(),
        backendBaseApi: backendBaseApi,
      ),
    );

    // 4. Mount Routes
    // Nota: security=false porque as rotas gerenciam sua própria autenticação
    // internamente via AuthMiddleware, não dependendo do authRequired global
    addRoutes(di, di.get<NotebookRoutes>(), security: false);
    addRoutes(di, di.get<DocumentRoutes>(), security: false);
  }
}
