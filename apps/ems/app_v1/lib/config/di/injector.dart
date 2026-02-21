import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:auth_client/auth_client.dart'
    show TokenStorage, AuthInterceptor;
import 'package:auth_ui/auth_ui.dart' show AuthModule, AuthViewModel;
import 'package:core_client/core_client.dart' show ApiKeyInterceptor;
import 'package:core_shared/core_shared.dart'
    show Loggable, GetItInjector, DependencyInjector;
import 'package:core_ui/core_ui.dart'
    show AppModule, FlutterSecureStorageAdapter, DashboardRegistry;
import 'package:dashboard_ui/dashboard_ui.dart' show DashboardModule;
import 'package:design_system_ui/design_system_ui.dart' show DSCard;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:notebook_ui/notebook_ui.dart';
import 'package:tag_ui/tag_ui.dart' show TagModule;
import 'package:user_ui/user_ui.dart' show SettingsViewModel, UserModule;
import 'package:user_client/user_client.dart' show SettingsStorage;

import '../../app_layout.dart';
import '../../main.dart';
import '../../view_models/app_view_model.dart';
import '../env/env.dart';
import '../network/dio_factory.dart';
import '../network/safe_log_interceptor.dart';

final _diMain = GetItInjector();

class Injector with Loggable {
  Future<void> injector() async {
    logger.info('injector');

    // 1. Registra serviços core (Dio, Storage, etc) - SEM AppViewModel ainda
    await _registerCoreServices(_diMain);

    // 2. Registra DashboardRegistry antes dos módulos de feature
    _diMain.registerSingleton<DashboardRegistry>(DashboardRegistry());

    // 3. Registra módulos (que registram AuthViewModel, etc)
    final List<AppModule> appModules = [
      // AuraModule(di: _diMain),
      // SchoolModule(di: _diMain),
      UserModule(di: _diMain),
      // AcademicConfigModule(di: _diMain),
      // AcademicStructureModule(di: _diMain),
      // SystemModule(di: _diMain),
      AuthModule(di: _diMain),
      TagModule(di: _diMain),
      NotebookModule(di: _diMain),
      DashboardModule(di: _diMain), // ← registrar por último (após features)
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

    // Navega para o dashboard como rota inicial (seção de menor prioridade = 0).
    // registerModules usa ordem de registro, não de prioridade de seção.
    appViewModel.navigateTo(DashboardModule.routeName);

    // Configura os interceptors do Dio após tudo ser registrado.
    _setupDioInterceptors(_diMain);
  }

  Future<void> _registerCoreServices(DependencyInjector di) async {
    // Registra SettingsStorage para carregar configurações de servidor
    final settingsStorage = SettingsStorage(FlutterSecureStorageAdapter());

    logger.info('🔍 Starting server configuration...');
    logger.info('ENV - backendBaseUrl: ${Env.backendBaseUrl}');
    logger.info('ENV - backendRemoteUrl: ${Env.backendRemoteUrl}');
    logger.info('ENV - backendPathApi: ${Env.backendPathApi}');

    // Carrega configurações de servidor
    final settingsResult = await settingsStorage.loadSettings();
    String? customBaseUrl;
    String? customRefreshUrl;

    settingsResult.when(
      success: (settings) {
        // Log modo de execução
        logger.info('═══════════════════════════════════════════════════');
        logger.info('Build Mode: ${kReleaseMode ? "RELEASE" : "DEBUG"}');
        logger.info('Platform: NATIVE');
        logger.info('User Settings - Server Type: ${settings.serverType}');

        // ⚠️ SEGURANÇA: Em RELEASE, FORÇA servidor remoto
        final effectiveServerType = kReleaseMode
            ? 'remote'
            : settings.serverType;
        logger.info('Effective Server Type: $effectiveServerType');

        if (effectiveServerType == 'remote') {
          customBaseUrl = '${Env.backendRemoteUrl}${Env.backendPathApi}';
          customRefreshUrl =
              '${Env.backendRemoteUrl}${Env.backendPathApi}/auth/refresh';
          logger.info('✓ Using REMOTE server');
          logger.info('  Base URL: $customBaseUrl');
          logger.info('  Refresh URL: $customRefreshUrl');

          // Se forçou em RELEASE, atualiza configuração salva para consistência
          if (kReleaseMode && settings.serverType != 'remote') {
            logger.warning(
              '⚠ RELEASE mode detected: forcing remote server (was: ${settings.serverType})',
            );
            settingsStorage.saveSettings(
              settings.copyWith(serverType: 'remote'),
            );
          }
        } else {
          customBaseUrl = '${Env.backendBaseUrl}${Env.backendPathApi}';
          customRefreshUrl =
              '${Env.backendBaseUrl}${Env.backendPathApi}/auth/refresh';
          logger.info('✓ Using LOCAL server');
          logger.info('  Base URL: $customBaseUrl');
          logger.info('  Refresh URL: $customRefreshUrl');
        }
        logger.info('═══════════════════════════════════════════════════');
      },
      failure: (_) {
        logger.warning('Failed to load server settings, using default');
        // Em RELEASE, fallback é remote; em DEBUG, é local
        if (kReleaseMode) {
          customBaseUrl = '${Env.backendRemoteUrl}${Env.backendPathApi}';
          customRefreshUrl =
              '${Env.backendRemoteUrl}${Env.backendPathApi}/auth/refresh';
        } else {
          customBaseUrl = '${Env.backendBaseUrl}${Env.backendPathApi}';
          customRefreshUrl =
              '${Env.backendBaseUrl}${Env.backendPathApi}/auth/refresh';
        }
      },
    );

    // Cria Dio com URL dinâmica
    final dio = DioFactory.create(customBaseUrl: customBaseUrl);
    logger.info('🌐 Dio created with baseUrl: ${dio.options.baseUrl}');

    di.registerLazySingleton<Dio>(() => dio);

    // Registra a refreshUrl para uso posterior
    di.registerLazySingleton<String>(
      () => customRefreshUrl!,
      instanceName: 'refreshUrl',
    );
    logger.info('🔒 RefreshUrl registered: $customRefreshUrl');
    // Outros serviços core básicos...
  }

  void _setupDioInterceptors(DependencyInjector di) {
    final dio = di.get<Dio>();
    final refreshUrl = di.get<String>(instanceName: 'refreshUrl');

    // Registra AuthInterceptor do pacote auth_client
    di.registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(
        tokenStorage: di.get<TokenStorage>(),
        dio: dio,
        refreshUrl: refreshUrl,
      ),
    );

    final aliceDioAdapter = AliceDioAdapter();
    alice.addAdapter(aliceDioAdapter);

    if (!dio.interceptors.any((i) => i is AuthInterceptor)) {
      dio.interceptors.addAll([
        ApiKeyInterceptor(apiKey: Env.apiKey),
        di.get<AuthInterceptor>(),
        SafeLogInterceptor(), // Interceptor seguro que filtra dados sensíveis
        aliceDioAdapter,
      ]);
    }
  }
}
