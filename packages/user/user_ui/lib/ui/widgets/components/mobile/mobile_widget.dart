import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart';
import 'package:user_shared/user_shared.dart';
import '../../../../view_models/manage_users_view_model.dart';
import '../../../../widgets/shared/shared.dart';

/// Widget para layout mobile do gerenciamento de usuários.
///
/// Usa ListView com UserCard e bottom sheet para detalhes.
class MobileWidget extends StatefulWidget {
  final ManageUsersViewModel viewModel;

  const MobileWidget({super.key, required this.viewModel});

  @override
  State<MobileWidget> createState() => _MobileWidgetState();
}

class _MobileWidgetState extends State<MobileWidget> {
  String? _searchQuery;
  UserRole? _selectedRole;
  bool? _selectedActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de Busca
        Padding(
          padding: const EdgeInsets.all(16),
          child: UserSearchField(
            value: _searchQuery,
            onChanged: (value) {
              setState(() => _searchQuery = value);
              widget.viewModel.searchUsers(value.isEmpty ? null : value);
            },
            onClear: () {
              setState(() => _searchQuery = null);
              widget.viewModel.searchUsers(null);
            },
          ),
        ),

        // Filtros
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: UserFiltersBar(
            selectedRole: _selectedRole,
            selectedActive: _selectedActive,
            onRoleChanged: (role) {
              setState(() => _selectedRole = role);
              widget.viewModel.filterByRole(role);
            },
            onActiveChanged: (active) {
              setState(() => _selectedActive = active);
              // Filtrar localmente por active (se o backend não suportar)
              widget.viewModel.loadUsers(refresh: true);
            },
          ),
        ),

        const SizedBox(height: 16),

        // Lista de Usuários
        Expanded(child: _buildUsersList()),
      ],
    );
  }

  Widget _buildUsersList() {
    if (widget.viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar usuários',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.viewModel.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => widget.viewModel.loadUsers(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (widget.viewModel.isLoading && widget.viewModel.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredUsers = _applyLocalFilters(widget.viewModel.users);

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum usuário encontrado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => widget.viewModel.loadUsers(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return UserCard(
            user: user,
            onTap: () => _showUserDetails(user),
            onEdit: widget.viewModel.isOwner
                ? () => _showEditDialog(user)
                : null,
            onDelete: widget.viewModel.isOwner && !user.isDeleted
                ? () => _confirmDelete(user)
                : null,
          );
        },
      ),
    );
  }

  List<UserDetails> _applyLocalFilters(List<UserDetails> users) {
    var filtered = users;

    // Filtro por status ativo
    if (_selectedActive != null) {
      filtered = filtered.where((u) => u.isActive == _selectedActive).toList();
    }

    return filtered;
  }

  Future<void> _showUserDetails(UserDetails user) async {
    await UserDetailsBottomSheet.show(
      context: context,
      user: user,
      onEdit: widget.viewModel.isOwner
          ? () {
              Navigator.pop(context);
              _showEditDialog(user);
            }
          : null,
      onDelete: widget.viewModel.isOwner && !user.isDeleted
          ? () {
              Navigator.pop(context);
              _confirmDelete(user);
            }
          : null,
      onResetPassword: widget.viewModel.canResetPassword(user)
          ? () {
              Navigator.pop(context);
              _confirmResetPassword(user);
            }
          : null,
    );
  }

  void _showEditDialog(UserDetails user) {
    // TODO: Implementar dialog de edição
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edição em desenvolvimento')),
    );
  }

  Future<void> _confirmDelete(UserDetails user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Usuário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tem certeza que deseja deletar ${user.name}?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta ação não pode ser desfeita.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await widget.viewModel.deleteUser(user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Usuário deletado com sucesso'
                  : widget.viewModel.error ?? 'Erro ao deletar usuário',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmResetPassword(UserDetails user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tem certeza que deseja resetar a senha de ${user.name}?'),
            const SizedBox(height: 12),
            const Text(
              'O usuário será obrigado a alterar a senha no próximo login.',
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta ação não pode ser desfeita.',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await widget.viewModel.resetUserPassword(user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Senha resetada com sucesso. ${user.name} deverá alterar a senha no próximo login.'
                  : widget.viewModel.error ?? 'Erro ao resetar senha',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: Duration(seconds: success ? 4 : 3),
          ),
        );
      }
    }
  }
}
