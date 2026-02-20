import 'package:core_shared/core_shared.dart' show DependencyInjector, Loggable;
import 'package:core_ui/core_ui.dart'
    show AppModule, AppNavigationItem, AppNavigationSection, DashboardRegistry;
import 'package:flutter/material.dart';

import 'pages/dashboard_page.dart';
import 'view_models/dashboard_view_model.dart';

class DashboardModule extends AppModule with Loggable {
  final DependencyInjector di;

  DashboardModule({required this.di});

  static const String routeName = '/dashboard';

  @override
  void registerDependencies(DependencyInjector di) {
    logger.info('registerDependencies');

    di.registerLazySingleton<DashboardViewModel>(
      () => DashboardViewModel(registry: di.get<DashboardRegistry>()),
    );

    di.registerLazySingleton<DashboardPage>(
      () => DashboardPage(viewModel: di.get<DashboardViewModel>()),
    );
  }

  @override
  Map<String, Widget> get routes => {routeName: di.get<DashboardPage>()};

  @override
  List<AppNavigationItem> get navigationItems => [
    AppNavigationItem(
      labelBuilder: (_) => 'Dashboard',
      icon: Icons.dashboard,
      section: AppNavigationSection.dashboard,
      route: routeName,
    ),
  ];
}
