import 'package:flutter/material.dart';
import 'package:user_shared/user_shared.dart';
import 'package:intl/intl.dart';
import 'user_role_badge.dart';

/// Bottom sheet reutilizável para exibir detalhes completos de um usuário.
///
/// Usa DraggableScrollableSheet para permitir altura variável.
class UserDetailsBottomSheet extends StatelessWidget {
  final UserDetails user;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onResetPassword;

  const UserDetailsBottomSheet({
    super.key,
    required this.user,
    this.onEdit,
    this.onDelete,
    this.onResetPassword,
  });

  /// Método estático para exibir o bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required UserDetails user,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onResetPassword,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserDetailsBottomSheet(
        user: user,
        onEdit: onEdit,
        onDelete: onDelete,
        onResetPassword: onResetPassword,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Indicador de drag
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Conteúdo scrollável
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Cabeçalho com Avatar
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                user.avatarUrl != null &&
                                    user.avatarUrl!.isNotEmpty
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            backgroundColor: theme.colorScheme.primary,
                            child:
                                user.avatarUrl == null ||
                                    user.avatarUrl!.isEmpty
                                ? Text(
                                    user.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 36,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          UserRoleBadge(role: user.role),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Informações Básicas
                    _buildSection(
                      context,
                      title: 'Informações Básicas',
                      children: [
                        _buildInfoRow(
                          context,
                          icon: Icons.alternate_email,
                          label: 'Username',
                          value: '@${user.username}',
                        ),
                        _buildInfoRow(
                          context,
                          icon: Icons.email,
                          label: 'Email',
                          value: user.email,
                        ),
                        if (user.phone != null)
                          _buildInfoRow(
                            context,
                            icon: Icons.phone,
                            label: 'Telefone',
                            value: user.phone!,
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Status
                    _buildSection(
                      context,
                      title: 'Status',
                      children: [
                        _buildStatusRow(
                          context,
                          label: 'Ativo',
                          value: user.isActive,
                        ),
                        _buildStatusRow(
                          context,
                          label: 'Email Verificado',
                          value: user.emailVerified,
                        ),
                        _buildStatusRow(
                          context,
                          label: 'Deve Mudar Senha',
                          value: user.mustChangePassword,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Dados do Sistema
                    _buildSection(
                      context,
                      title: 'Dados do Sistema',
                      children: [
                        _buildInfoRow(
                          context,
                          icon: Icons.fingerprint,
                          label: 'ID',
                          value: user.id,
                        ),
                        _buildInfoRow(
                          context,
                          icon: Icons.access_time,
                          label: 'Criado em',
                          value: dateFormat.format(user.createdAt),
                        ),
                        _buildInfoRow(
                          context,
                          icon: Icons.update,
                          label: 'Atualizado em',
                          value: dateFormat.format(user.updatedAt),
                        ),
                      ],
                    ),

                    const SizedBox(height: 80), // Espaço para os botões
                  ],
                ),
              ),

              // Botões de Ação
              if (onEdit != null || onDelete != null || onResetPassword != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        if (onEdit != null)
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit),
                              label: const Text('Editar'),
                            ),
                          ),
                        if (onEdit != null && onResetPassword != null)
                          const SizedBox(width: 8),
                        if (onResetPassword != null)
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: onResetPassword,
                              icon: const Icon(Icons.lock_reset),
                              label: const Text('Reset Senha'),
                            ),
                          ),
                        if ((onEdit != null || onResetPassword != null) &&
                            onDelete != null)
                          const SizedBox(width: 8),
                        if (onDelete != null)
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete),
                              label: const Text('Deletar'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context, {
    required String label,
    required bool value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: value ? Colors.green[600] : Colors.red[600],
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value ? 'Sim' : 'Não',
            style: TextStyle(
              fontSize: 14,
              color: value ? Colors.green[600] : Colors.red[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
