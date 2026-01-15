import 'package:flutter/material.dart';
import '../view_models/settings_view_model.dart';

/// Página de Configurações do Usuário.
///
/// Permite configurar notificações, tema, idioma e outras preferências.
class SettingsPage extends StatefulWidget {
  final SettingsViewModel viewModel;

  /// Callback para navegar ao perfil.
  final VoidCallback? onNavigateToProfile;

  /// Callback para mudança de senha.
  final VoidCallback? onChangePassword;

  const SettingsPage({
    super.key,
    required this.viewModel,
    this.onNavigateToProfile,
    this.onChangePassword,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(title: const Text('Configurações')),
          body: ListView(
            children: [
              // Seção Conta
              _buildSectionHeader(theme, 'Conta'),
              _buildListTile(
                icon: Icons.person,
                title: 'Perfil',
                subtitle: 'Gerenciar informações do perfil',
                onTap: widget.onNavigateToProfile,
              ),
              _buildListTile(
                icon: Icons.lock,
                title: 'Alterar Senha',
                subtitle: 'Atualizar senha de acesso',
                onTap:
                    widget.onChangePassword ??
                    () => _showChangePasswordDialog(context),
              ),
              const Divider(),

              // Seção Notificações
              _buildSectionHeader(theme, 'Notificações'),
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Notificações',
                subtitle: 'Habilitar todas as notificações',
                value: widget.viewModel.notificationsEnabled,
                onChanged: widget.viewModel.toggleNotifications,
              ),
              _buildSwitchTile(
                icon: Icons.email,
                title: 'Email',
                subtitle: 'Receber notificações por email',
                value: widget.viewModel.emailNotifications,
                onChanged: widget.viewModel.toggleEmailNotifications,
                enabled: widget.viewModel.notificationsEnabled,
              ),
              _buildSwitchTile(
                icon: Icons.phone_android,
                title: 'Push',
                subtitle: 'Notificações push no dispositivo',
                value: widget.viewModel.pushNotifications,
                onChanged: widget.viewModel.togglePushNotifications,
                enabled: widget.viewModel.notificationsEnabled,
              ),
              const Divider(),

              // Seção Aparência
              _buildSectionHeader(theme, 'Aparência'),
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Modo Escuro',
                subtitle: 'Usar tema escuro',
                value: widget.viewModel.darkMode,
                onChanged: widget.viewModel.toggleDarkMode,
              ),
              _buildListTile(
                icon: Icons.language,
                title: 'Idioma',
                subtitle: _getLanguageName(widget.viewModel.language),
                onTap: () => _showLanguageDialog(context),
              ),
              const Divider(),

              // Seção Privacidade
              _buildSectionHeader(theme, 'Privacidade'),
              _buildListTile(
                icon: Icons.shield,
                title: 'Privacidade',
                subtitle: 'Gerenciar privacidade e dados',
                onTap: () => _showPrivacyInfo(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'pt_BR':
        return 'Português (Brasil)';
      case 'en_US':
        return 'English (US)';
      case 'es_ES':
        return 'Español';
      default:
        return code;
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Senha Atual',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implementar mudança de senha
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Senha alterada com sucesso!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('As senhas não coincidem'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Idioma'),
        content: RadioGroup<String>(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Português (Brasil)'),
                value: 'pt_BR',
              ),
              RadioListTile<String>(
                title: const Text('English (US)'),
                value: 'en_US',
              ),
              RadioListTile<String>(
                title: const Text('Español'),
                value: 'es_ES',
              ),
            ],
          ),
          onChanged: (value) {
            if (value != null) {
              widget.viewModel.setLanguage(value);
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacidade'),
        content: const Text(
          'Suas informações pessoais são protegidas e usadas apenas '
          'para melhorar sua experiência no aplicativo.\n\n'
          'Não compartilhamos seus dados com terceiros sem consentimento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}
