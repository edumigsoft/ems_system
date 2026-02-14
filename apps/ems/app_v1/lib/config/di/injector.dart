import 'package:auth_client/auth_client.dart'
    show TokenStorage, AuthInterceptor;
import 'package:auth_ui/auth_ui.dart' show AuthModule, AuthViewModel;
import 'package:core_shared/core_shared.dart'
    show Loggable, GetItInjector, DependencyInjector;
import 'package:core_ui/core_ui.dart' show AppModule;
import 'package:design_system_ui/design_system_ui.dart' show DSCard;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:notebook_ui/notebook_ui.dart';
import 'package:tag_ui/tag_ui.dart' show TagModule;
import 'package:user_ui/user_ui.dart' show SettingsViewModel, UserModule;
import 'package:user_client/user_client.dart' show SettingsStorage;

import '../../app_layout.dart';
import '../../view_models/app_view_model.dart';
import '../env/env.dart';
import '../network/dio_factory.dart';

final _diMain = GetItInjector();

class Injector with Loggable {
  Future<void> injector() async {
    logger.info('injector');

    // 1. Registra serviços core (Dio, Storage, etc) - SEM AppViewModel ainda
    await _registerCoreServices(_diMain);

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
      TagModule(di: _diMain),
      NotebookModule(di: _diMain),
    ];

    // Registra as dependências de cada módulo.
    for (final module in appModules) {
      module.registerDependencies(_diMain);
    }

    // 3. Registra AppViewModel
    _diMain.registerLazySingleton<AppViewModel>(
      () => AppViewModel(
        authViewModel: _diMain.get<AuthViewModel>(),
        cardBuilder: (child) => DSCard(
          child: child,
        ),
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

  Future<void> _registerCoreServices(DependencyInjector di) async {
    // Registra SettingsStorage para carregar configurações de servidor
    final settingsStorage = SettingsStorage();

    // Carrega configurações de servidor
    final settingsResult = await settingsStorage.loadSettings();
    String? customBaseUrl;

    settingsResult.when(
      success: (settings) {
        // ⚠️ SEGURANÇA: Em RELEASE, FORÇA servidor remoto
        final effectiveServerType = kReleaseMode ? 'remote' : settings.serverType;

        if (effectiveServerType == 'remote') {
          customBaseUrl = '${Env.backendRemoteUrl}${Env.backendPathApi}';
          logger.info('Using remote server: $customBaseUrl');

          // Se forçou em RELEASE, atualiza configuração salva para consistência
          if (kReleaseMode && settings.serverType != 'remote') {
            logger.warning(
              'RELEASE mode detected: forcing remote server (was: ${settings.serverType})',
            );
            settingsStorage.saveSettings(
              settings.copyWith(serverType: 'remote'),
            );
          }
        } else {
          customBaseUrl = '${Env.backendBaseUrl}${Env.backendPathApi}';
          logger.info('Using local server: $customBaseUrl');
        }
      },
      failure: (_) {
        logger.warning('Failed to load server settings, using default');
        // Em RELEASE, fallback é remote; em DEBUG, é local
        customBaseUrl = kReleaseMode
            ? '${Env.backendRemoteUrl}${Env.backendPathApi}'
            : '${Env.backendBaseUrl}${Env.backendPathApi}';
      },
    );

    // Cria Dio com URL dinâmica
    di.registerLazySingleton<Dio>(() => DioFactory.create(customBaseUrl: customBaseUrl));
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
