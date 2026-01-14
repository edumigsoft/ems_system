import 'package:core_shared/core_shared.dart'
    show Loggable, GetItInjector, DependencyInjector;
import 'package:core_ui/core_ui.dart' show AppModule;
import 'package:dio/dio.dart';
import 'package:user_ui/user_module.dart';

import '../../app_layout.dart';
import '../../data/services/navigation_service.dart';
import '../../pages/app_page.dart';
import '../../view_models/app_view_model.dart';
import '../dio/dio_config.dart';
import '../env/env.dart';

final _diMain = GetItInjector();

class Injector with Loggable {
  Future<void> injector() async {
    logger.info('injector');

    // Registra os singletons e serviços essenciais da aplicação.
    _registerCoreServices(_diMain);

    final appViewModel = _diMain.get<AppViewModel>();

    // A lista de módulos agora é criada aqui para garantir que as dependências
    // principais já existam.
    final List<AppModule> appModules = [
      // DashboardModule(di: _diMain),
      // AuraModule(di: _diMain),
      // SchoolModule(di: _diMain),
      UserModule(di: _diMain),
      // AcademicConfigModule(di: _diMain),
      // AcademicStructureModule(di: _diMain),
      // SystemModule(di: _diMain),
      // AuthModule(di: _diMain, loggedInPage: _diMain.get<AppPage>()),
    ];

    // Registra as dependências de cada módulo.
    for (final module in appModules) {
      module.registerDependencies(_diMain);
    }

    // Cria e registra o serviço de navegação.
    _diMain.registerLazySingleton<NavigationService>(
      () =>
          NavigationService(appViewModel: appViewModel, appModules: appModules),
    );

    // Constrói a navegação e as views da UI.
    _diMain.get<NavigationService>().buildNavigation();

    // Configura os interceptors do Dio após tudo ser registrado.
    _setupDioInterceptors(_diMain);
  }

  void _registerCoreServices(DependencyInjector di) {
    di.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: '${Env.backendBaseUrl}${Env.backendPathApi}',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      ),
    );
    // di.registerLazySingleton<FlutterSecureStorage>(
    //   () => const FlutterSecureStorage(),
    // );
    // di.registerLazySingleton<AuthStorageService>(
    //   () => AuthStorageServiceLocal(
    //     flutterSecureStorage: di.get<FlutterSecureStorage>(),
    //   ),
    // );
    // di.registerLazySingleton<SystemRepository>(() => SystemRepositoryLocal());
    di.registerLazySingleton<AppViewModel>(
      () => AppViewModel(
        // authStorageService: di.get<AuthStorageService>(),
      ),
    );
    di.registerLazySingleton<AppLayout>(
      () => AppLayout(
        di: di,
        viewModel: di.get<AppViewModel>(),
        // systemViewModel: di.get<SystemViewModel>(),
      ),
    );
    di.registerLazySingleton<AppPage>(
      () => AppPage(viewModel: di.get<AppViewModel>()),
    );
  }

  void _setupDioInterceptors(DependencyInjector di) {
    di.registerLazySingleton<BackendAuthInterceptor>(
      () => BackendAuthInterceptor(
        dio: di.get<Dio>(),
        // authRepository: di.get<AuthRepository>(),
        backendBaseApi: Env.backendBaseUrl,
        onUnauthorized: () {},
      ),
    );

    final dio = di.get<Dio>();
    if (!dio.interceptors.any((i) => i is BackendAuthInterceptor)) {
      dio.interceptors.addAll([
        di.get<BackendAuthInterceptor>(),
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      ]);
    }
  }
}
