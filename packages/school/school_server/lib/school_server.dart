library;

import 'package:core_server/core_server.dart';
import 'package:school_shared/school_shared.dart' show SchoolRepository;
import 'src/repositories/school_repository_server.dart';
import 'src/queries/school_queries.dart';
import 'src/routes/school_routes.dart';
import 'src/database/school_database.dart';

export 'src/routes/school_routes.dart';
export 'src/repositories/school_repository_server.dart';
export 'src/queries/school_queries.dart';
export 'src/database/school_database.dart';
export 'src/database/tables/school_table.dart';

class InitSchoolModuleToServer implements InitServerModule {
  static Future<void> init({
    required DependencyInjector di,
    required String backendBaseApi,
    bool security = true,
  }) async {
    // Database

    final dbProvider = di.get<DatabaseProvider>();
    final schoolDb = SchoolDatabase(dbProvider.executor);

    // Inicializa tabelas se necessário
    await schoolDb.init();

    di.registerSingleton<SchoolDatabase>(schoolDb);

    // Queries
    di.registerLazySingleton<SchoolQueries>(
      () => SchoolQueries(di.get<SchoolDatabase>()),
    );

    // Repository
    di.registerLazySingleton<SchoolRepository>(
      () => SchoolRepositoryServer(schoolQueries: di.get<SchoolQueries>()),
    );

    // Routes
    di.registerLazySingleton<SchoolRoutes>(
      () => SchoolRoutes(
        backendBaseApi: backendBaseApi,
        repository: di.get<SchoolRepository>(),
        security: security,
      ),
    );
    addRoutes(di, di.get<SchoolRoutes>(), security: security);
  }
}
