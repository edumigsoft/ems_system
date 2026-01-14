import 'package:auth_ui/auth_ui.dart' show AuthModule, AuthViewModel;
import 'package:auth_client/auth_client.dart' show TokenStorage;
import 'package:core_shared/core_shared.dart'
    show Loggable, GetItInjector, DependencyInjector;
import 'package:core_ui/core_ui.dart' show AppModule;
import 'package:dio/dio.dart';
import 'package:user_ui/user_module.dart';

import '../../app_layout.dart';
import '../../data/services/navigation_service.dart';
import '../../view_models/app_view_model.dart';
import '../dio/dio_config.dart';
import '../env/env.dart';

final _diMain = GetItInjector();

class Injector with Loggable {
  Future<void> injector() async {
    logger.info('injector');

    // 1. Registra serviços core (Dio, Storage, etc) - SEM AppViewModel ainda
    _registerCoreServices(_diMain);

    // 2. Registra módulos (que registram AuthViewModel, etc)
    final List<AppModule> appModules = [
      // DashboardModule(di: _diMain),
      // AuraModule(di: _diMain),
      // SchoolModule(di: _diMain),
      UserModule(di: _diMain),
      // AcademicConfigModule(di: _diMain),
      // AcademicStructureModule(di: _diMain),
      // SystemModule(di: _diMain),
      AuthModule(di: _diMain),
    ];

    // Registra as dependências de cada módulo.
    for (final module in appModules) {
      module.registerDependencies(_diMain);
    }

    // 3. Registra AppViewModel (agora que AuthViewModel já está registrado)
    _diMain.registerLazySingleton<AppViewModel>(
      () => AppViewModel(
        authViewModel: _diMain.get<AuthViewModel>(),
      ),
    );

    // 4. Registra AppLayout (depende de AppViewModel)
    _diMain.registerLazySingleton<AppLayout>(
      () => AppLayout(
        di: _diMain,
        viewModel: _diMain.get<AppViewModel>(),
      ),
    );

    final appViewModel = _diMain.get<AppViewModel>();

    // 5. Registra NavigationService
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
    // Outros serviços core básicos...
  }

  void _setupDioInterceptors(DependencyInjector di) {
    di.registerLazySingleton<BackendAuthInterceptor>(
      () => BackendAuthInterceptor(
        dio: di.get<Dio>(),
        tokenStorage: di.get<TokenStorage>(),
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
