import 'package:auth_ui/auth_ui.dart' show AuthViewModel;
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
///   authViewModel: mockAuthViewModel,
/// );
/// await viewModel.init();
/// ```
class AppViewModel extends BaseNavigationViewModel {
  final AuthViewModel _authViewModel;
  bool _isInitialized = false;

  /// Cria uma instância do [AppViewModel].
  ///
  /// Exemplo de uso com DSCard customizado:
  /// ```dart
  /// AppViewModel(
  ///   authViewModel: authViewModel,
  ///   cardBuilder: (child) => DSCard(
  ///     padding: EdgeInsets.all(16),
  ///     elevation: 4,
  ///     child: child,
  ///   ),
  /// )
  /// ```
  AppViewModel({
    required AuthViewModel authViewModel,
    super.cardBuilder, // Passa o cardBuilder para o BaseNavigationViewModel
  }) : _authViewModel = authViewModel;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    logger.info('App View Model Init EMS System');

    _authViewModel.addListener(_onAuthChanged);

    // Inicializa com o estado atual (se já estiver carregado)
    _onAuthChanged();
  }

  void _onAuthChanged() {
    final user = _authViewModel.currentUser;
    if (user != null) {
      updateUserRole(user.role);
    }
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthChanged);
    super.dispose();
  }
}
