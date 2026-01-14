import 'package:flutter/material.dart';
import '../view_models/auth_view_model.dart';
import 'session_expiration_dialog.dart';

/// Widget responsável por verificar autenticação e decidir qual interface mostrar.
///
/// O [AuthGuard] observa o [AuthViewModel] e renderiza diferentes widgets
/// baseado no estado de autenticação:
///
/// - [AuthState.initial] ou [AuthState.loading]: Exibe splash screen
/// - [AuthState.authenticated]: Exibe [authenticatedChild] (app principal)
/// - [AuthState.unauthenticated] ou [AuthState.error]: Exibe [unauthenticatedChild] (fluxo de login)
///
/// ## Exemplo de Uso
///
/// ```dart
/// AuthGuard(
///   authViewModel: authViewModel,
///   authenticatedChild: MainAppLayout(),
///   unauthenticatedChild: AuthFlowPage(authViewModel: authViewModel),
/// )
/// ```
///
/// ## Comportamento
///
/// - Reage automaticamente a mudanças no [AuthViewModel] via [ListenableBuilder]
/// - Mostra splash screen durante verificação inicial de tokens
/// - Evita "flash" de tela de login ao iniciar app com sessão válida
/// - Monitora expiração de sessão e exibe diálogo de aviso
class AuthGuard extends StatefulWidget {
  /// ViewModel que gerencia o estado de autenticação.
  final AuthViewModel authViewModel;

  /// Widget exibido quando usuário está autenticado (app principal).
  final Widget authenticatedChild;

  /// Widget exibido quando usuário não está autenticado (fluxo de login).
  final Widget unauthenticatedChild;

  const AuthGuard({
    super.key,
    required this.authViewModel,
    required this.authenticatedChild,
    required this.unauthenticatedChild,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  void initState() {
    super.initState();

    // Registrar callback para mostrar diálogo de expiração
    widget.authViewModel.onTokenExpiring = _showExpirationDialog;

    // Adicionar listener para detectar quando mostrar diálogo
    widget.authViewModel.addListener(_checkShowExpirationDialog);
  }

  @override
  void dispose() {
    widget.authViewModel.removeListener(_checkShowExpirationDialog);
    super.dispose();
  }

  /// Verifica se deve mostrar o diálogo de expiração.
  void _checkShowExpirationDialog() {
    if (widget.authViewModel.isAuthenticated &&
        widget.authViewModel.hasShownExpirationWarning &&
        mounted) {
      _showExpirationDialog(context);
    }
  }

  /// Exibe o diálogo de aviso de expiração de sessão.
  void _showExpirationDialog(BuildContext context) {
    // Verifica se já não há diálogo aberto
    if (ModalRoute.of(context)?.isCurrent != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          SessionExpirationDialog(viewModel: widget.authViewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authViewModel,
      builder: (context, _) {
        // Estado inicial ou carregando: mostra splash screen
        if (widget.authViewModel.state == AuthState.initial ||
            widget.authViewModel.state == AuthState.loading) {
          return _buildSplashScreen(context);
        }

        // Autenticado: mostra app principal
        if (widget.authViewModel.isAuthenticated) {
          return widget.authenticatedChild;
        }

        // Não autenticado ou erro: mostra fluxo de login
        return widget.unauthenticatedChild;
      },
    );
  }

  /// Constrói a tela de splash exibida durante verificação de autenticação.
  ///
  /// Exibe:
  /// - Logo do Flutter (placeholder - substituir por logo do app)
  /// - Indicador de carregamento
  /// - Mensagem "Verificando autenticação..."
  Widget _buildSplashScreen(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo do app (placeholder)
            Icon(
              Icons.shield_outlined,
              size: 100,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 32),

            // Indicador de carregamento
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 24),

            // Mensagem
            Text(
              'Verificando autenticação...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
