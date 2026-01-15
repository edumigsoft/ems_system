import 'package:core_shared/core_shared.dart'
    show DependencyInjector, Loggable, UserRole;
import 'package:core_ui/core_ui.dart'
    show AppModule, AppNavigationItem, AppNavigationSection;
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart' show AppLocalizations;
import 'package:user_client/user_client.dart' show UserService, SettingsStorage;
import 'package:auth_client/auth_client.dart' show AuthService;

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

    di.registerLazySingleton<UserService>(() => UserService(di.get()));

    // Register SettingsStorage
    di.registerLazySingleton<SettingsStorage>(() => SettingsStorage());

    // ViewModels e Pages
    di.registerLazySingleton<ProfileViewModel>(
      () => ProfileViewModel(userService: di.get<UserService>()),
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
      () => ManageUsersViewModel(userService: di.get<UserService>()),
    );
    di.registerLazySingleton<ManageUsersPage>(
      () => ManageUsersPage(viewModel: di.get<ManageUsersViewModel>()),
    );
  }

  @override
  Map<String, Widget> get routes => {
    routeName: di.get<ProfilePage>(),
    '$routeName/settings': di.get<SettingsPage>(),
    '$routeName/manage': di.get<ManageUsersPage>(),
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
          route: routeName, // /users -> ProfilePage
        ),
        AppNavigationItem(
          labelBuilder: (context) => AppLocalizations.of(context).settings,
          icon: Icons.settings,
          route: '$routeName/settings', // /users/settings
        ),
        AppNavigationItem(
          labelBuilder: (context) => AppLocalizations.of(context).manageUsers,
          icon: Icons.admin_panel_settings,
          route: '$routeName/manage', // /users/manage
          allowedRoles: [UserRole.admin, UserRole.owner],
        ),
      ],
    ),
  ];
}
