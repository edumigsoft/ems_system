import 'package:core_shared/core_shared.dart'
    show DependencyInjector, Loggable, UserRole;
import 'package:core_ui/core_ui.dart'
    show AppModule, AppNavigationItem, AppNavigationSection;
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart' show AppLocalizations;
import 'package:user_client/user_client.dart'
    show UserService, SettingsStorage, UserRepositoryClient;
import 'package:user_shared/user_shared.dart'
    show
        UserRepository,
        GetProfileUseCase,
        UpdateProfileUseCase,
        GetAllUsersUseCase,
        CreateUserUseCase,
        UpdateUserUseCase,
        DeleteUserUseCase,
        UpdateUserRoleUseCase,
        ResetPasswordUseCase;
import 'package:auth_client/auth_client.dart' show AuthService;
import 'package:auth_ui/auth_ui.dart' show AuthViewModel, RoleGuard;

import 'pages/manage_users_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'view_models/manage_users_view_model.dart';
import 'view_models/profile_view_model.dart';
import 'view_models/settings_view_model.dart';

class UserModule extends AppModule with Loggable {
  final DependencyInjector di;

  UserModule({required this.di});

  static const String routeName = '/users';

  @override
  void registerDependencies(DependencyInjector di) {
    logger.info('registerDependencies');

    // Services
    di.registerLazySingleton<UserService>(() => UserService(di.get()));

    // Register SettingsStorage
    di.registerLazySingleton<SettingsStorage>(() => SettingsStorage());

    // Repository
    di.registerLazySingleton<UserRepository>(
      () => UserRepositoryClient(service: di.get<UserService>()),
    );

    // Use Cases
    di.registerLazySingleton<GetProfileUseCase>(
      () => GetProfileUseCase(repository: di.get<UserRepository>()),
    );
    di.registerLazySingleton<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(repository: di.get<UserRepository>()),
    );
    di.registerLazySingleton<GetAllUsersUseCase>(
      () => GetAllUsersUseCase(repository: di.get<UserRepository>()),
    );
    di.registerLazySingleton<CreateUserUseCase>(
      () => CreateUserUseCase(repository: di.get<UserRepository>()),
    );
    di.registerLazySingleton<UpdateUserUseCase>(
      () => UpdateUserUseCase(repository: di.get<UserRepository>()),
    );
    di.registerLazySingleton<DeleteUserUseCase>(
      () => DeleteUserUseCase(repository: di.get<UserRepository>()),
    );
    di.registerLazySingleton<UpdateUserRoleUseCase>(
      () => UpdateUserRoleUseCase(repository: di.get<UserRepository>()),
    );
    di.registerLazySingleton<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(repository: di.get<UserRepository>()),
    );

    // ViewModels e Pages
    di.registerLazySingleton<ProfileViewModel>(
      () => ProfileViewModel(
        getProfileUseCase: di.get<GetProfileUseCase>(),
        updateProfileUseCase: di.get<UpdateProfileUseCase>(),
        authViewModel: di.get<AuthViewModel>(),
      ),
    );
    di.registerLazySingleton<ProfilePage>(
      () => ProfilePage(viewModel: di.get<ProfileViewModel>()),
    );

    di.registerLazySingleton<SettingsViewModel>(
      () => SettingsViewModel(
        storage: di.get<SettingsStorage>(),
        authService: di.get<AuthService>(),
      ),
    );
    di.registerLazySingleton<SettingsPage>(
      () => SettingsPage(viewModel: di.get<SettingsViewModel>()),
    );

    di.registerLazySingleton<ManageUsersViewModel>(
      () => ManageUsersViewModel(
        getAllUsersUseCase: di.get<GetAllUsersUseCase>(),
        createUserUseCase: di.get<CreateUserUseCase>(),
        updateUserUseCase: di.get<UpdateUserUseCase>(),
        deleteUserUseCase: di.get<DeleteUserUseCase>(),
        updateUserRoleUseCase: di.get<UpdateUserRoleUseCase>(),
        resetPasswordUseCase: di.get<ResetPasswordUseCase>(),
        authService: di.get<AuthService>(),
      ),
    );
    di.registerFactory<ManageUsersPage>(
      () {
        return ManageUsersPage(
          viewModel: di.get<ManageUsersViewModel>(),
        );
      },
    );
  }

  @override
  Map<String, Widget> get routes => {
    routeName: di.get<ProfilePage>(),
    '$routeName/settings': di.get<SettingsPage>(),
    '$routeName/manage': RoleGuard(
      allowedRoles: const [UserRole.admin, UserRole.owner],
      authViewModel: di.get<AuthViewModel>(),
      child: di.get<ManageUsersPage>(),
    ),
  };

  @override
  List<AppNavigationItem> get navigationItems => [
    AppNavigationItem(
      labelBuilder: (context) => AppLocalizations.of(context).users,
      icon: DSIcons.users,
      section: AppNavigationSection.system,
      // O item pai não tem rota própria, serve apenas para agrupar
      route: null,
      defaultExpanded: true,
      children: [
        AppNavigationItem(
          labelBuilder: (context) => AppLocalizations.of(context).myProfile,
          icon: Icons.person,
          route: routeName,
        ),
        AppNavigationItem(
          labelBuilder: (context) => AppLocalizations.of(context).settings,
          icon: Icons.settings,
          route: '$routeName/settings',
        ),
        AppNavigationItem(
          labelBuilder: (context) => AppLocalizations.of(context).manageUsers,
          icon: Icons.admin_panel_settings,
          route: '$routeName/manage',
          allowedRoles: [UserRole.admin, UserRole.owner],
        ),
      ],
    ),
  ];
}
