import 'package:core_shared/core_shared.dart' show DependencyInjector, Loggable;
import 'package:core_ui/core_ui.dart'
    show AppModule, AppNavigationItem, AppNavigationSection;
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart' show AppLocalizations;
import 'package:user_client/user_client.dart' show UserService;

import 'pages/profile_page.dart';
import 'view_models/profile_view_model.dart';

class UserModule extends AppModule with Loggable {
  final DependencyInjector di;

  UserModule({required this.di});

  static const String routeName = '/users';

  @override
  void registerDependencies(DependencyInjector di) {
    logger.info('registerDependencies');

    di.registerLazySingleton<UserService>(() => UserService(di.get()));
    // di.registerLazySingleton<UserRepository>(
    //   () => UserRepositoryClient(userService: di.get<UserService>()),
    // );
    // di.registerLazySingleton<GetAllUsersUseCase>(
    //   () => GetAllUsersUseCase(repository: di.get<UserRepository>()),
    // );
    // di.registerLazySingleton<GetUserByIdUseCase>(
    //   () => GetUserByIdUseCase(repository: di.get<UserRepository>()),
    // );
    // di.registerLazySingleton<CreateUserWithTempPasswordUseCase>(
    //   () => CreateUserWithTempPasswordUseCase(
    //     repository: di.get<UserRepository>(),
    //   ),
    // );
    // di.registerLazySingleton<UpdateUserUseCase>(
    //   () => UpdateUserUseCase(repository: di.get<UserRepository>()),
    // );
    // di.registerLazySingleton<DeleteUserUseCase>(
    //   () => DeleteUserUseCase(repository: di.get<UserRepository>()),
    // );

    di.registerLazySingleton<ProfileViewModel>(
      () => ProfileViewModel(
        userService: di.get<UserService>(),
        // getAllUsersUseCase: di.get<GetAllUsersUseCase>(),
        // getUserByIdUseCase: di.get<GetUserByIdUseCase>(),
        // createUserWithTempPasswordUseCase: di
        //     .get<CreateUserWithTempPasswordUseCase>(),
        // updateUserUseCase: di.get<UpdateUserUseCase>(),
        // deleteUserUseCase: di.get<DeleteUserUseCase>(),
      ),
    );
    di.registerLazySingleton<ProfilePage>(
      () => ProfilePage(viewModel: di.get<ProfileViewModel>()),
    );
  }

  @override
  Map<String, Widget> get routes => {routeName: di.get<ProfilePage>()};

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
          labelBuilder: (context) => 'Meu Perfil', // TODO: Localizar
          icon: Icons.person,
          route: routeName, // /users -> ProfilePage
        ),
        AppNavigationItem(
          labelBuilder: (context) => 'Configurações', // TODO: Localizar
          icon: Icons.settings,
          route: '$routeName/settings', // /users/settings
        ),
        // Item condicional para admins (precisa de lógica de filtragem)
        AppNavigationItem(
          labelBuilder: (context) => 'Gerenciar Usuários', // TODO: Localizar
          icon: Icons.admin_panel_settings,
          route: '$routeName/manage', // /users/manage
        ),
      ],
    ),
  ];
}
