import 'package:core_shared/core_shared.dart' show Loggable, UserRole;
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

  UserRole? _currentUserRole;

  void updateUserRole(UserRole role) {
    _currentUserRole = role;
    notifyListeners();
  }

  List<AppNavigationItem> get visibleNavigationItems {
    if (_currentUserRole == null) {
      return [];
    }

    return _navigationItems
        .where((item) => item.isVisibleFor(_currentUserRole!))
        .map((item) {
          // Se o item tem filhos, filtra os filhos também
          if (item.children.isNotEmpty) {
            final visibleChildren = item.children
                .where((child) => child.isVisibleFor(_currentUserRole!))
                .toList();

            // Retorna uma cópia do item com os filhos filtrados
            // Precisamos garantir que AppNavigationItem seja imutável mas permita "cópia" ou
            // instanciar um novo com as mesmas propriedades.
            // Como AppNavigationItem não tem copyWith, e é const, teremos que recriar se filhos mudarem.
            // Mas espere, AppNavigationItem.children é final.
            // Se filtrarmos apenas o primeiro nível, pode ser suficiente se assumirmos que a permissão do pai governa.
            // Mas o requisito diz "Menu Hierárquico".

            return AppNavigationItem(
              labelBuilder: item.labelBuilder,
              icon: item.icon,
              route: item.route,
              section: item.section,
              defaultExpanded: item.defaultExpanded,
              allowedRoles: item.allowedRoles,
              children: visibleChildren,
            );
          }
          return item;
        })
        .where(
          (item) => item.children.isNotEmpty || item.hasRoute,
        ) // Remove pais que ficaram sem filhos e sem rota
        .toList();
  }

  void addNavigationItem(AppNavigationItem item) {
    _navigationItems.add(item);
    notifyListeners();
  }
}
