import 'package:core_shared/core_shared.dart' show Loggable, UserRole;
import 'package:flutter/material.dart';

import '../../core/commons/app_module.dart';
import '../../core/navigation/app_navigation_item.dart';

abstract class BaseNavigationViewModel extends ChangeNotifier with Loggable {
  BaseNavigationViewModel({Widget Function(Widget child)? cardBuilder})
    : _cardBuilder = cardBuilder;

  final Widget Function(Widget child)? _cardBuilder;

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
    final content =
        _routesMap[_selectedRoute] ??
        const Center(child: Text('Rota não encontrada'));

    return Scaffold(
      body:
          _cardBuilder?.call(content) ??
          Card(
            child: content,
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

  /// Registra uma lista de módulos e configura a navegação.
  ///
  /// Itera sobre cada módulo para:
  /// 1. Registrar suas rotas no mapa de rotas.
  /// 2. Coletar seus itens de navegação.
  /// 3. Ordenar os itens baseados na prioridade da seção.
  void registerModules(List<AppModule> modules) {
    final List<AppNavigationItem> allNavItems = [];

    for (final module in modules) {
      // 1. Register Routes
      module.routes.forEach((route, view) {
        registerRoute(route, view);
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
    _navigationItems.clear();
    for (final item in allNavItems) {
      addNavigationItem(item);
    }
  }
}
