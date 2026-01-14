import 'package:auth_client/auth_client.dart' show AuthService;
import 'package:core_shared/core_shared.dart' show Loggable, DependencyInjector;
import 'package:core_ui/core_ui.dart' show AppModule;
import 'package:flutter/material.dart';

import 'view_models/auth_view_model.dart';

class AuthModule extends AppModule with Loggable {
  final DependencyInjector di;
  final Widget loggedInPage;

  AuthModule({required this.di, required this.loggedInPage});

  @override
  void registerDependencies(DependencyInjector di) {
    di.registerLazySingleton<AuthService>(() => AuthService(di.get()));
    di.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryClient(
        service: di.get<AuthService>(),
        storageService: di.get<AuthStorageService>(),
      ),
    );
    di.registerLazySingleton<AuthViewModel>(
      () => AuthViewModel(
        repository: di.get<AuthRepository>(),
        loggedIn: loggedInPage,
      ),
    );
    di.registerLazySingleton<AuthPage>(
      () => AuthPage(viewModel: di.get<AuthViewModel>()),
    );

    di.registerLazySingleton<SplashPage>(
      () => SplashPage(
        viewModel: di.get<AuthViewModel>(),
        notLoggedIn: di.get<AuthPage>(),
      ),
    );
    di.registerLazySingleton<SignOutPage>(
      () => SignOutPage(
        viewModel: di.get<AuthViewModel>(),
        notLoggedIn: di.get<AuthPage>(),
      ),
    );
  }
}
