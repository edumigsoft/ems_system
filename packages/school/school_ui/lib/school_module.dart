import 'package:core_shared/core_shared.dart' show DependencyInjector, Loggable;
import 'package:core_ui/core_ui.dart'
    show AppModule, AppNavigationItem, AppNavigationSection;
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';

// import 'package:localizations_ui/localizations_ui.dart' show AppLocalizations;
import 'package:school_client/school_client.dart'
    show SchoolService, SchoolRepositoryClient;
import 'package:school_shared/school_shared.dart'
    show
        SchoolRepository,
        GetAllUseCase,
        CreateUseCase,
        UpdateUseCase,
        DeleteUseCase;
import 'ui/view_models/school_view_model.dart';
import 'ui/pages/school_page.dart';

class SchoolModule extends AppModule with Loggable {
  final DependencyInjector di;

  SchoolModule({required this.di});

  /// Constante pública para rota de escolas.
  /// Pode ser utilizada pelo App para configurar rotas ou links seguros.
  static const String routeName = '/schools';

  @override
  void registerDependencies(DependencyInjector di) {
    logger.info('registerDependencies');

    di.registerLazySingleton<SchoolService>(
      () => SchoolService(di.get()),
    );
    di.registerLazySingleton<SchoolRepository>(
      () => SchoolRepositoryClient(
        schoolService: di.get<SchoolService>(),
      ),
    );
    di.registerLazySingleton<GetAllUseCase>(
      () => GetAllUseCase(repository: di.get<SchoolRepository>()),
    );
    di.registerLazySingleton<CreateUseCase>(
      () => CreateUseCase(repository: di.get<SchoolRepository>()),
    );
    di.registerLazySingleton<UpdateUseCase>(
      () => UpdateUseCase(repository: di.get<SchoolRepository>()),
    );
    di.registerLazySingleton<DeleteUseCase>(
      () => DeleteUseCase(repository: di.get<SchoolRepository>()),
    );
    di.registerLazySingleton<SchoolViewModel>(
      () => SchoolViewModel(
        getAllUseCase: di.get<GetAllUseCase>(),
        createUseCase: di.get<CreateUseCase>(),
        updateUseCase: di.get<UpdateUseCase>(),
        deleteUseCase: di.get<DeleteUseCase>(),
      ),
    );
    di.registerLazySingleton<SchoolPage>(
      () => SchoolPage(viewModel: di.get<SchoolViewModel>()),
    );
  }

  @override
  Map<String, Widget> get routes => {
    routeName: di.get<SchoolPage>(),
  };

  @override
  List<AppNavigationItem> get navigationItems => [
    AppNavigationItem(
      labelBuilder: (context) =>
          /*AppLocalizations.of(context)?.schools ??*/ 'Escolas',
      icon: DSIcons.school,
      route: routeName,
      section: AppNavigationSection.academic,
    ),
  ];
}
