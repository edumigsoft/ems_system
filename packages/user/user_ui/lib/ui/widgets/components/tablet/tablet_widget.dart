import 'package:flutter/material.dart';
import 'package:user_shared/user_shared.dart';
import '../../../../view_models/manage_users_view_model.dart';
import '../../../../pages/manage_users_form_page.dart';
import '../../../../widgets/shared/shared.dart';
import '../../dialogs/dialogs.dart';

/// Widget para layout tablet do gerenciamento de usuários.
///
/// Scaffold + FAB + GridView. Ações de edit/delete nos cards.
class TabletWidget extends StatefulWidget {
  final ManageUsersViewModel viewModel;

  const TabletWidget({super.key, required this.viewModel});

  @override
  State<TabletWidget> createState() => _TabletWidgetState();
}

class _TabletWidgetState extends State<TabletWidget> {
  Future<void> _navigateToCreate() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            ManageUsersFormPage(viewModel: widget.viewModel),
      ),
    );
    if (mounted) widget.viewModel.loadUsers(refresh: true);
  }

  Future<void> _navigateToEdit(UserDetails user) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ManageUsersFormPage(
          viewModel: widget.viewModel,
          user: user,
        ),
      ),
    );
    if (mounted) widget.viewModel.loadUsers(refresh: true);
  }

  Future<void> _confirmDelete(UserDetails user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => UserDeleteConfirmDialog(user: user),
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
      builder: (context) => UserResetPasswordDialog(user: user),
    );
    if (confirmed == true && mounted) {
      final success = await widget.viewModel.resetUserPassword(user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Senha resetada. ${user.name} deverá alterar a senha no próximo login.'
                  : widget.viewModel.error ?? 'Erro ao resetar senha',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: Duration(seconds: success ? 4 : 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        elevation: 0,
      ),
      floatingActionButton: widget.viewModel.isOwner
          ? FloatingActionButton(
              onPressed: _navigateToCreate,
              tooltip: 'Adicionar Usuário',
              child: const Icon(Icons.person_add),
            )
          : null,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
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

    if (widget.viewModel.users.isEmpty) {
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
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: widget.viewModel.users.length,
        itemBuilder: (context, index) {
          final user = widget.viewModel.users[index];
          return UserGridCard(
            user: user,
            onTap: () => UserDetailsBottomSheet.show(
              context: context,
              user: user,
              onEdit: widget.viewModel.isOwner
                  ? () {
                      Navigator.pop(context);
                      _navigateToEdit(user);
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
            ),
            onEdit: widget.viewModel.isOwner
                ? () => _navigateToEdit(user)
                : null,
            onDelete: widget.viewModel.isOwner && !user.isDeleted
                ? () => _confirmDelete(user)
                : null,
          );
        },
      ),
    );
  }
}
