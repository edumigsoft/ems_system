import 'package:core_shared/core_shared.dart' show DependencyInjector;
import 'package:flutter/material.dart';

import '../navigation/app_navigation_item.dart';

/// Contrato para todos os módulos de feature da aplicação.
///
/// Cada módulo (School, User, Auth, etc.) deve implementar esta classe para
/// de forma declarativa expor suas dependências, rotas e itens de navegação,
/// desacoplando sua configuração do `injector` principal.
abstract class AppModule {
  /// Registra as dependências específicas do módulo no injetor de dependências.
  ///
  /// Ex: di.registerFactory(() => MyViewModel());
  void registerDependencies(DependencyInjector di);

  /// Retorna o mapa de rotas e suas respectivas views.
  Map<String, Widget> get routes => {};

  /// Retorna a lista de itens de navegação agnósticos a UI.
  ///
  /// Estes itens são usados pelo [AppViewModel] para construir o menu lateral
  /// de forma dinâmica, sem acoplamento com Widgets específicos.
  List<AppNavigationItem> get navigationItems => [];
}
