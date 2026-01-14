import 'package:core_ui/core_ui.dart' show AppModule, AppNavigationItem;

import '../../view_models/app_view_model.dart';

/// Serviço responsável pela construção e orquestração da navegação do aplicativo.
///
/// Este serviço itera sobre os módulos registrados e configura as rotas de navegação
/// para Desktop e Mobile, além de itens do Dashboard.
///
/// ## Exemplo de Uso
///
/// ```dart
/// final navigationService = NavigationService(
///   appViewModel: appViewModel,
///   appModules: [
///     AuthModule(),
///     DashboardModule(),
///   ],
/// );
///
/// navigationService.buildNavigation();
/// ```
class NavigationService {
  final AppViewModel appViewModel;
  final List<AppModule> appModules;

  NavigationService({required this.appViewModel, required this.appModules});

  /// Constrói a estrutura de navegação agregando configurações de todos os módulos.
  ///
  /// Popula o [AppViewModel] com:
  /// - Destinos de navegação Desktop ([navRailsDestination])
  /// - Destinos de navegação Mobile ([botNavDestination])
  /// - Cards de visualização do Dashboard ([dashboardItemsViews])
  /// - Views completas ([widgetDestinationViews])
  void buildNavigation() {
    final List<AppNavigationItem> allNavItems = [];

    for (final module in appModules) {
      // 1. Register Routes
      module.routes.forEach((route, view) {
        appViewModel.registerRoute(route, view);
      });

      // 2. Collect Navigation Items
      allNavItems.addAll(module.navigationItems);
    }

    // Sort navigation items by section priority
    // Dashboard(0) < Academic(1) < Environment(2) < System(3)
    allNavItems.sort((a, b) {
      final pA = a.section?.priority ?? 999;
      final pB = b.section?.priority ?? 999;
      return pA.compareTo(pB);
    });

    // Add sorted items to ViewModel
    for (final item in allNavItems) {
      appViewModel.addNavigationItem(item);
    }
  }
}
