import 'package:flutter/material.dart';
import '../view_models/auth_view_model.dart';

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
/// - Tokens são renovados automaticamente em background pelo [TokenRefreshService]
class AuthGuard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authViewModel,
      builder: (context, _) {
        // Estado inicial ou carregando: mostra splash screen
        if (authViewModel.state == AuthState.initial ||
            authViewModel.state == AuthState.loading) {
          return _buildSplashScreen(context);
        }

        // Autenticado: mostra app principal
        if (authViewModel.isAuthenticated) {
          return authenticatedChild;
        }

        // Não autenticado ou erro: mostra fluxo de login
        return unauthenticatedChild;
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
