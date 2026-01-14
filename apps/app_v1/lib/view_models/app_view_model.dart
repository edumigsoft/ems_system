import 'package:core_ui/core_ui.dart' show BaseNavigationViewModel;

/// ViewModel principal do aplicativo que gerencia o estado global da interface do usuário.
///
/// ## Responsabilidades
/// - Gerenciar o estado da navegação entre telas
/// - Controlar a exibição e manipulação dos itens do dashboard
/// - Coordenar a comunicação entre a interface do usuário e os serviços de negócio
/// - Manter o estado da sessão do usuário
/// - Gerenciar temas e preferências de exibição
///
/// ## Ciclo de Vida
/// 1. Inicialização via `init()`
/// 2. Configuração de listeners e streams
/// 3. Atualização de estado via `notifyListeners()`
/// 4. Liberação de recursos no `dispose()`
///
/// ## Testes
/// - Cobertura atual: 100% (49/49 linhas)
/// - Testes unitários disponíveis em: `test/unit/view_models/app_view_model_test.dart`
///
/// ## Exemplo de Uso
/// ```dart
/// final viewModel = AppViewModel(
///   authStorageService: mockAuthStorageService,
/// );
/// await viewModel.init();
/// ```
class AppViewModel extends BaseNavigationViewModel {
  // final AuthStorageService _authStorageService;

  /// Cria uma instância do [AppViewModel].
  AppViewModel();

  @override
  Future<void> init() async {
    logger.info('App View Model Init EMS System');
  }

  // -------------------
  // Propriedades de Navegação
  // -------------------

  // -------------------
  // Propriedades de Navegação (Rotas Nomeadas)
  // -------------------

  // final Map<String, Widget> _routesMap = {};

  // String _selectedRoute = '';

  // String get selectedRoute => _selectedRoute;

  // void navigateTo(String route) {
  //   if (_selectedRoute != route && _routesMap.containsKey(route)) {
  //     _selectedRoute = route;
  //     notifyListeners();
  //   }
  // }

  // void registerRoute(String route, Widget view) {
  //   _routesMap[route] = view;
  //   // Define a primeira rota registrada como padrão se ainda não houver seleção
  //   if (_selectedRoute.isEmpty) {
  //     _selectedRoute = route;
  //   }
  // }

  // Widget get currentView {
  //   return _routesMap[_selectedRoute] ??
  //       const Center(child: Text('Rota não encontrada'));
  // }

  // -------------------
  // Gerenciamento de Visualizações
  // -------------------

  // -------------------
  // Itens de Navegação Dinâmicos (AppNavigationItem)
  // -------------------

  // final List<AppNavigationItem> _navigationItems = [];

  // /// Lista de itens de navegação agnósticos a UI.
  // List<AppNavigationItem> get navigationItems =>
  //     List.unmodifiable(_navigationItems);

  // /// Adiciona um item de navegação à lista.
  // void addNavigationItem(AppNavigationItem item) {
  //   _navigationItems.add(item);
  //   notifyListeners();
  // }

  /// Obtém a entidade de autenticação atual do usuário.
  ///
  /// Este método consulta o serviço de armazenamento de autenticação para
  /// recuperar a sessão do usuário atualmente autenticado.
  ///
  /// Retorna:
  ///   - Um [Future] que completa com [AuthEntity] contendo os dados da sessão do usuário,
  ///     ou `null` se não houver sessão ativa.
  ///
  /// Lança:
  ///   - Exceções lançadas pelo `_authStorageService.getSession()`
  // Future<AuthEntity?> getAuth() async {
  //   final result = await _authStorageService.getSession();

  //   // Padrão de correspondência de padrões para verificar o resultado
  //   return result.valueOrNull;
  // }
}
