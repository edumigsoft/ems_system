import 'package:flutter/material.dart';
import '../view_models/auth_view_model.dart';

/// Página de Redefinição de Senha.
///
/// Recebe ViewModel e Token via construtor.
class ResetPasswordPage extends StatefulWidget {
  final AuthViewModel viewModel;
  final String token;
  final VoidCallback? onResetSuccess;

  const ResetPasswordPage({
    super.key,
    required this.viewModel,
    required this.token,
    this.onResetSuccess,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.viewModel.confirmPasswordReset(
      token: widget.token,
      newPassword: _passwordController.text,
    );

    if (success && mounted) {
      setState(() => _isSuccess = true);
      // Opcional: chamar callback após delay ou botão
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Usa ListenableBuilder para reagir a loading/error
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Redefinir Senha')),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _isSuccess
                      ? _buildSuccessState(theme)
                      : _buildForm(theme),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Nova Senha',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Crie uma nova senha segura para sua conta.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Nova Senha
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nova Senha',
              prefixIcon: Icon(Icons.lock_open),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe a nova senha';
              }
              if (value.length < 8) {
                return 'A senha deve ter pelo menos 8 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirmar Senha
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSubmit(),
            decoration: const InputDecoration(
              labelText: 'Confirmar Senha',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirme a senha';
              }
              if (value != _passwordController.text) {
                return 'As senhas não conferem';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Erro
          if (widget.viewModel.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.viewModel.errorMessage!,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),

          // Botão
          FilledButton(
            onPressed: widget.viewModel.isLoading ? null : _handleSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: widget.viewModel.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Redefinir Senha'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 64,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Senha Redefinida!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sua senha foi alterada com sucesso. Você já pode fazer login com a nova senha.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: widget.onResetSuccess,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
          child: const Text('Ir para Login'),
        ),
      ],
    );
  }
}
