import 'package:flutter/material.dart';
import '../view_models/auth_view_model.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'reset_password_page.dart';

/// Estados possíveis do fluxo de autenticação.
enum AuthFlowState {
  /// Tela de login.
  login,

  /// Tela de registro de nova conta.
  register,

  /// Tela de recuperação de senha.
  forgotPassword,

  /// Tela de redefinição de senha com token.
  resetPassword,
}

/// Widget responsável por gerenciar navegação entre páginas de autenticação.
///
/// O [AuthFlowPage] orquestra a navegação entre:
/// - [LoginPage]: Login com email/senha
/// - [RegisterPage]: Registro de nova conta
/// - [ForgotPasswordPage]: Solicitar recuperação de senha
/// - [ResetPasswordPage]: Redefinir senha com token
///
/// ## Navegação
///
/// Os callbacks das páginas são conectados às transições de estado:
///
/// ```
/// LoginPage
///   ├── onRegisterTap → RegisterPage
///   ├── onForgotPasswordTap → ForgotPasswordPage
///   └── onLoginSuccess → App Principal (via AuthGuard)
///
/// RegisterPage
///   ├── onLoginTap → LoginPage
///   └── onRegisterSuccess → LoginPage
///
/// ForgotPasswordPage
///   └── onBackToLogin → LoginPage
///
/// ResetPasswordPage
///   └── onResetSuccess → LoginPage
/// ```
///
/// ## Deep Links
///
/// Suporta token de reset de senha via deep link:
/// ```
/// ems://reset-password?token=abc123xyz
/// ```
///
/// ## Exemplo de Uso
///
/// ```dart
/// AuthFlowPage(
///   authViewModel: authViewModel,
///   initialResetToken: 'token-from-email', // Opcional
/// )
/// ```
class AuthFlowPage extends StatefulWidget {
  /// ViewModel que gerencia autenticação.
  final AuthViewModel authViewModel;

  /// Token opcional de reset de senha (de deep link).
  ///
  /// Se fornecido, inicia o fluxo na tela de reset de senha.
  final String? initialResetToken;

  const AuthFlowPage({
    super.key,
    required this.authViewModel,
    this.initialResetToken,
  });

  @override
  State<AuthFlowPage> createState() => _AuthFlowPageState();
}

class _AuthFlowPageState extends State<AuthFlowPage> {
  late AuthFlowState _currentState;
  String? _resetToken;
  String? _loginWelcomeMessage;

  @override
  void initState() {
    super.initState();

    // Se há token de reset, inicia na tela de reset
    if (widget.initialResetToken != null) {
      _currentState = AuthFlowState.resetPassword;
      _resetToken = widget.initialResetToken;
    } else {
      _currentState = AuthFlowState.login;
    }
  }

  /// Navega para um novo estado do fluxo de autenticação.
  void _navigateTo(
    AuthFlowState newState, {
    String? resetToken,
    String? loginMessage,
  }) {
    setState(() {
      _currentState = newState;
      if (resetToken != null) {
        _resetToken = resetToken;
      }
      if (newState == AuthFlowState.login) {
        _loginWelcomeMessage = loginMessage;
      } else {
        _loginWelcomeMessage = null;
      }
    });
  }

  /// Limpa o token de reset após uso.
  void _clearResetToken() {
    setState(() {
      _resetToken = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildCurrentPage(),
    );
  }

  /// Constrói a página atual baseada no estado do fluxo.
  Widget _buildCurrentPage() {
    switch (_currentState) {
      case AuthFlowState.login:
        return LoginPage(
          key: const ValueKey('login'),
          viewModel: widget.authViewModel,
          onRegisterTap: () => _navigateTo(AuthFlowState.register),
          onForgotPasswordTap: () => _navigateTo(AuthFlowState.forgotPassword),
          welcomeMessage: _loginWelcomeMessage,
          // onLoginSuccess não precisa callback - AuthGuard detecta automaticamente
        );

      case AuthFlowState.register:
        return RegisterPage(
          key: const ValueKey('register'),
          viewModel: widget.authViewModel,
          onLoginTap: () => _navigateTo(AuthFlowState.login),
          onRegisterSuccess: () {
            // Volta para login após registro bem-sucedido com mensagem
            _navigateTo(
              AuthFlowState.login,
              loginMessage: 'Conta criada com sucesso!',
            );
          },
        );

      case AuthFlowState.forgotPassword:
        return ForgotPasswordPage(
          key: const ValueKey('forgot'),
          viewModel: widget.authViewModel,
          onBackToLogin: () => _navigateTo(AuthFlowState.login),
        );

      case AuthFlowState.resetPassword:
        // Requer token
        if (_resetToken == null) {
          // Se não há token, volta para login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateTo(AuthFlowState.login);
          });
          return const SizedBox.shrink();
        }

        return ResetPasswordPage(
          key: const ValueKey('reset'),
          viewModel: widget.authViewModel,
          token: _resetToken!,
          onResetSuccess: () {
            // Limpa token e volta para login
            _clearResetToken();
            _navigateTo(AuthFlowState.login);
          },
        );
    }
  }
}
