import 'package:core_shared/core_shared.dart' show Loggable;
import 'package:design_system_ui/design_system_ui.dart' show DSCard;
import 'package:flutter/material.dart';

import '../../core/navigation/app_navigation_item.dart';

abstract class BaseNavigationViewModel extends ChangeNotifier with Loggable {
  Future<void> init();

  final Map<String, Widget> _routesMap = {};

  String _selectedRoute = '';

  String get selectedRoute => _selectedRoute;

  void navigateTo(String route) {
    if (_selectedRoute != route && _routesMap.containsKey(route)) {
      _selectedRoute = route;
      notifyListeners();
    }
  }

  void registerRoute(String route, Widget view) {
    _routesMap[route] = view;

    if (_selectedRoute.isEmpty) {
      _selectedRoute = route;
    }
  }

  Widget get currentView {
    return Scaffold(
      body: DSCard(
        child:
            _routesMap[_selectedRoute] ??
            const Center(child: Text('Rota não encontrada')),
      ),
    );
  }

  final List<AppNavigationItem> _navigationItems = [];

  List<AppNavigationItem> get navigationItems =>
      List.unmodifiable(_navigationItems);

  void addNavigationItem(AppNavigationItem item) {
    _navigationItems.add(item);
    notifyListeners();
  }
}
