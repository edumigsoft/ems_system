import 'package:design_system_shared/design_system_shared.dart';
import 'package:flutter/material.dart';
import 'package:localizations_ui/localization/app_localizations.dart'
    show AppLocalizations;
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
          appBar: AppBar(title: Text(AppLocalizations.of(context).settings)),
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
                icon: Icons.palette,
                title: 'Tema',
                subtitle: _getThemeName(widget.viewModel.theme),
                onTap: () => _showThemeDialog(context),
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
    return widget.viewModel.getLanguageLabel(code);
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismiss while loading
      builder: (context) => ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final isLoading = widget.viewModel.isChangingPassword;

          return AlertDialog(
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
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Nova Senha',
                    helperText:
                        'Mín. 8 caracteres: maiúscula, minúscula, número e especial',
                    helperMaxLines: 2,
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Nova Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  enabled: !isLoading,
                ),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final error = await widget.viewModel.changePassword(
                          currentPassword: currentPasswordController.text,
                          newPassword: newPasswordController.text,
                          confirmPassword: confirmPasswordController.text,
                        );

                        if (context.mounted) {
                          if (error == null) {
                            // Sucesso
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Senha alterada com sucesso!'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            // Erro
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                child: const Text('Alterar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Idioma'),
        content: SingleChildScrollView(
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              return RadioGroup<String>(
                groupValue: widget.viewModel.language,
                onChanged: (value) {
                  if (value != null) {
                    widget.viewModel.setLanguage(value);
                    Navigator.pop(context);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.viewModel.supportedLocales.map((locale) {
                    return RadioListTile<String>(
                      title: Text(locale.label),
                      value: locale.code,
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog<void>(
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

  String _getThemeName(String theme) {
    return widget.viewModel.getThemeLabel(theme);
  }

  void _showThemeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Tema'),
        content: SingleChildScrollView(
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              return RadioGroup<String>(
                groupValue: widget.viewModel.theme,
                onChanged: (value) {
                  if (value != null) {
                    widget.viewModel.setTheme(value);
                    Navigator.pop(context);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.viewModel.supportedThemes.map((theme) {
                    return RadioListTile<String>(
                      title: Text(theme.label),
                      value: theme.name,
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
