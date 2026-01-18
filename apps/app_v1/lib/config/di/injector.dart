import 'package:auth_client/auth_client.dart'
    show TokenStorage, AuthInterceptor;
import 'package:auth_ui/auth_ui.dart' show AuthModule, AuthViewModel;
import 'package:ems_system_core_shared/core_shared.dart'
    show Loggable, GetItInjector, DependencyInjector;
import 'package:ems_system_core_ui/core_ui.dart' show AppModule;
import 'package:dio/dio.dart';
import 'package:user_ui/user_ui.dart' show SettingsViewModel, UserModule;

import '../../app_layout.dart';
import '../../view_models/app_view_model.dart';
import '../env/env.dart';
import '../network/dio_factory.dart';

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

    // 4. Registra AppLayout (depende de AppViewModel e AuthViewModel)
    _diMain.registerLazySingleton<AppLayout>(
      () => AppLayout(
        viewModel: _diMain.get<AppViewModel>(),
        authViewModel: _diMain.get<AuthViewModel>(),
        settingsViewModel: _diMain.get<SettingsViewModel>(),
      ),
    );

    final appViewModel = _diMain.get<AppViewModel>();

    // 5. Registra Módulos e Configura Navegação
    appViewModel.registerModules(appModules);

    // Configura os interceptors do Dio após tudo ser registrado.
    _setupDioInterceptors(_diMain);
  }

  void _registerCoreServices(DependencyInjector di) {
    di.registerLazySingleton<Dio>(() => DioFactory.create());
    // Outros serviços core básicos...
  }

  void _setupDioInterceptors(DependencyInjector di) {
    final dio = di.get<Dio>();

    // Registra AuthInterceptor do pacote auth_client
    di.registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(
        tokenStorage: di.get<TokenStorage>(),
        dio: dio,
        refreshUrl: '${Env.backendBaseUrl}${Env.backendPathApi}/auth/refresh',
      ),
    );

    if (!dio.interceptors.any((i) => i is AuthInterceptor)) {
      dio.interceptors.addAll([
        di.get<AuthInterceptor>(),
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
