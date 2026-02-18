import 'package:flutter/material.dart';
import 'package:user_shared/user_shared.dart';
import '../view_models/profile_view_model.dart';

/// Página de Perfil do Usuário.
///
/// Recebe ViewModel via construtor (DI).
class ProfilePage extends StatefulWidget {
  final ProfileViewModel viewModel;

  /// Callback para logout.
  final VoidCallback? onLogout;

  const ProfilePage({super.key, required this.viewModel, this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Inicia carregamento do perfil ao abrir a página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Meu Perfil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: widget.viewModel.profile != null
                    ? () => _showEditDialog(context)
                    : null,
              ),
            ],
          ),
          body: _buildBody(context, theme),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    final profile = widget.viewModel.profile;
    if (profile == null) return;

    final nameController = TextEditingController(text: profile.name);
    final phoneController = TextEditingController(text: profile.phone ?? '');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final update = UserUpdate(
                id: profile.id,
                name: nameController.text.isNotEmpty
                    ? nameController.text
                    : null,
                phone: phoneController.text.isNotEmpty
                    ? phoneController.text
                    : null,
              );
              Navigator.pop(context);
              final success = await widget.viewModel.updateProfile(update);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perfil atualizado!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => ListenableBuilder(
        listenable: widget.viewModel,
        builder: (_, _) => AlertDialog(
          title: const Text('Alterar Senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.viewModel.authErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    widget.viewModel.authErrorMessage!,
                    style: TextStyle(
                      color: Theme.of(dialogContext).colorScheme.error,
                    ),
                  ),
                ),
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha Atual',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Nova Senha',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: widget.viewModel.isAuthLoading
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: widget.viewModel.isAuthLoading
                  ? null
                  : () async {
                      final success = await widget.viewModel.changePassword(
                        currentPassword: currentPasswordController.text,
                        newPassword: newPasswordController.text,
                        confirmPassword: confirmPasswordController.text,
                      );
                      if (success && dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Senha alterada com sucesso!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
              child: widget.viewModel.isAuthLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    if (widget.viewModel.isLoading && widget.viewModel.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.viewModel.error != null && widget.viewModel.profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Erro ao carregar perfil', style: theme.textTheme.titleMedium),
            if (widget.viewModel.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  widget.viewModel.error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: widget.viewModel.loadProfile,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final profile = widget.viewModel.profile;
    if (profile == null) {
      return const Center(child: Text('Perfil não encontrado'));
    }

    return RefreshIndicator(
      onRefresh: widget.viewModel.loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                  ? Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.headlineLarge,
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // Nome
            Text(
              profile.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            // Email
            Text(
              profile.email,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),

            // Badge de verificação
            if (profile.emailVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Email verificado',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // Informações
            _buildInfoCard(theme, profile),
            const SizedBox(height: 24),

            // Botão Alterar Senha
            OutlinedButton.icon(
              onPressed: () => _showChangePasswordDialog(context),
              icon: const Icon(Icons.lock_outline),
              label: const Text('Alterar Senha'),
            ),
            const SizedBox(height: 12),

            // Botão Logout
            OutlinedButton.icon(
              onPressed: () async {
                await widget.viewModel.logout();
                if (widget.onLogout != null) {
                  widget.onLogout!();
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, UserDetails profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow(Icons.person, 'Username', '@${profile.username}'),
            if (profile.phone != null)
              _buildInfoRow(Icons.phone, 'Telefone', profile.phone!),
            _buildInfoRow(
              Icons.shield,
              'Tipo',
              profile.role.name.toUpperCase(),
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'Membro desde',
              _formatDate(profile.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
