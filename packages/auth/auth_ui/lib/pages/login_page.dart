import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart';
import 'package:user_ui/view_models/settings_view_model.dart';
import '../view_models/auth_view_model.dart';

/// Página de Login.
///
/// Recebe ViewModel via construtor (DI).
class LoginPage extends StatefulWidget {
  final AuthViewModel viewModel;

  /// Callback para navegação ao registro.
  final VoidCallback? onRegisterTap;

  /// Callback para navegação ao esqueci senha.
  final VoidCallback? onForgotPasswordTap;

  /// Callback quando login é bem-sucedido.
  final VoidCallback? onLoginSuccess;

  /// Mensagem de boas-vindas opcional (ex: após registro).
  final String? welcomeMessage;

  /// ViewModel de configurações (opcional).
  ///
  /// Se fornecido, permite seleção de servidor na tela de login (DEBUG apenas).
  final SettingsViewModel? settingsViewModel;

  const LoginPage({
    super.key,
    required this.viewModel,
    this.onRegisterTap,
    this.onForgotPasswordTap,
    this.onLoginSuccess,
    this.welcomeMessage,
    this.settingsViewModel,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showWelcomeBanner = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChange);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChange);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onViewModelChange() {
    if (widget.viewModel.isAuthenticated) {
      widget.onLoginSuccess?.call();
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await widget.viewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
      rememberMe: _rememberMe,
    );
  }

  /// Manipula mudança de servidor.
  ///
  /// Salva a nova configuração e mostra dialog informando necessidade de reiniciar.
  void _handleServerChange(String? newServerType) {
    if (newServerType == null) return;

    final oldServerType = widget.settingsViewModel!.serverType;
    if (oldServerType == newServerType) return;

    // Salva nova configuração
    widget.settingsViewModel!.setServerType(newServerType);

    // Mostra dialog informando necessidade de reiniciar
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.info_outline, size: 48),
        title: const Text('Reinício Necessário'),
        content: Text(
          'Para conectar ao servidor ${newServerType == 'local' ? 'local' : 'remoto'}, '
          'é necessário reiniciar o aplicativo.\n\n'
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Reverte a mudança
              widget.settingsViewModel!.setServerType(oldServerType);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Mostra SnackBar instruindo usuário a reiniciar manualmente
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Configuração salva! Feche e reabra o aplicativo para aplicar.',
                    ),
                    duration: Duration(seconds: 5),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo/Título
                        Icon(
                          Icons.lock_outline,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bem-vindo',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Entre com sua conta para continuar',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Banner de boas-vindas (pós-registro)
                        if (widget.welcomeMessage != null && _showWelcomeBanner)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade600,
                                  Colors.green.shade500,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.welcomeMessage!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Faça login com suas credenciais para continuar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showWelcomeBanner = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                        // Campo Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe seu email';
                            }
                            if (!value.contains('@')) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Campo Senha
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe sua senha';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Link Esqueci Senha
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: widget.onForgotPasswordTap,
                            child: const Text('Esqueci minha senha'),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Checkbox Lembrar-me
                        CheckboxListTile(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? true;
                            });
                          },
                          title: Text(
                            AppLocalizations.of(context).authRememberMeLabel,
                          ),
                          subtitle: Text(
                            _rememberMe
                                ? AppLocalizations.of(
                                    context,
                                  ).authRememberMeSessionActive
                                : AppLocalizations.of(
                                    context,
                                  ).authRememberMeSessionExpires,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 8),

                        // Seletor de Servidor (apenas em debug mode)
                        if (kDebugMode && widget.settingsViewModel != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ListenableBuilder(
                              listenable: widget.settingsViewModel!,
                              builder: (context, _) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.dns_outlined,
                                            size: 16,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Servidor (Desenvolvimento)',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      SegmentedButton<String>(
                                        segments: const [
                                          ButtonSegment<String>(
                                            value: 'local',
                                            label: Text('Local'),
                                            icon: Icon(
                                              Icons.computer,
                                              size: 16,
                                            ),
                                          ),
                                          ButtonSegment<String>(
                                            value: 'remote',
                                            label: Text('Remoto'),
                                            icon: Icon(Icons.cloud, size: 16),
                                          ),
                                        ],
                                        selected: {
                                          widget.settingsViewModel!.serverType,
                                        },
                                        onSelectionChanged:
                                            (Set<String> selected) {
                                              _handleServerChange(
                                                selected.first,
                                              );
                                            },
                                        showSelectedIcon: false,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                        // Erro
                        if (widget.viewModel.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.viewModel.errorMessage!,
                                    style: TextStyle(
                                      color: theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Botão Entrar
                        FilledButton(
                          onPressed: widget.viewModel.isLoading
                              ? null
                              : _handleLogin,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: widget.viewModel.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Entrar'),
                        ),
                        const SizedBox(height: 24),

                        // Link Registro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Não tem conta?',
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: widget.onRegisterTap,
                              child: const Text('Cadastre-se'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
