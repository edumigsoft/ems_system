import 'package:auth_client/auth_client.dart'
    show AuthService, AuthApiService, TokenStorage, TokenRefreshService;
import 'package:core_shared/core_shared.dart' show Loggable, DependencyInjector;
import 'package:core_ui/core_ui.dart' show AppModule, AppNavigationItem;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/forgot_password_page.dart';
import 'view_models/auth_view_model.dart';

class AuthModule extends AppModule with Loggable {
  final DependencyInjector di;

  AuthModule({required this.di});

  static const String routeName = '/auth';

  @override
  void registerDependencies(DependencyInjector di) {
    // Register AuthApiService (Retrofit service)
    di.registerLazySingleton<AuthApiService>(
      () => AuthApiService(di.get<Dio>()),
    );

    // Register TokenStorage
    di.registerLazySingleton<TokenStorage>(() => TokenStorage());

    // Register TokenRefreshService
    di.registerLazySingleton<TokenRefreshService>(
      () => TokenRefreshService(
        tokenStorage: di.get<TokenStorage>(),
        apiService: di.get<AuthApiService>(),
      ),
    );

    // Register AuthService
    di.registerLazySingleton<AuthService>(
      () => AuthService(
        api: di.get<AuthApiService>(),
        tokenStorage: di.get<TokenStorage>(),
        refreshService: di.get<TokenRefreshService>(),
      ),
    );

    // Register AuthViewModel
    di.registerLazySingleton<AuthViewModel>(
      () => AuthViewModel(authService: di.get<AuthService>()),
    );

    // Register pages
    di.registerLazySingleton<LoginPage>(
      () => LoginPage(viewModel: di.get<AuthViewModel>()),
    );

    di.registerLazySingleton<RegisterPage>(
      () => RegisterPage(viewModel: di.get<AuthViewModel>()),
    );

    di.registerLazySingleton<ForgotPasswordPage>(
      () => ForgotPasswordPage(viewModel: di.get<AuthViewModel>()),
    );

    // Note: ResetPasswordPage is not registered here because it requires
    // a runtime token parameter from the password reset link.
    // Create it on-demand during navigation: ResetPasswordPage(viewModel: di.get(), token: token)
  }

  @override
  Map<String, Widget> get routes => {
    '${routeName}/login': di.get<LoginPage>(),
    '${routeName}/register': di.get<RegisterPage>(),
    '${routeName}/forgot-password': di.get<ForgotPasswordPage>(),
    // ResetPasswordPage not included - requires runtime token parameter
  };

  @override
  List<AppNavigationItem> get navigationItems => [];
}
