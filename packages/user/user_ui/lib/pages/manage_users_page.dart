import 'package:ems_system_core_shared/core_shared.dart' show UserRole;
import 'package:ems_system_core_ui/core_ui.dart' show UserRoleExtension;
import 'package:design_system_ui/design_system_ui.dart' show DsDialog;
import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart';
import 'package:user_shared/user_shared.dart' show UserDetails, UserCreateAdmin;
import '../view_models/manage_users_view_model.dart';

/// Página de Gerenciamento de Usuários (Admin).
///
/// Permite administradores visualizar, buscar, filtrar e gerenciar usuários.
/// Recebe ViewModel via construtor (DI).
class ManageUsersPage extends StatefulWidget {
  final ManageUsersViewModel viewModel;

  const ManageUsersPage({super.key, required this.viewModel});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Carrega usuários ao abrir a página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.initialize();
      widget.viewModel.loadUsers(refresh: true);
    });

    // Scroll infinito
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9) {
        widget.viewModel.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gerenciar Usuários'),
            actions: [
              // Filtro por role
              PopupMenuButton<UserRole?>(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filtrar por role',
                onSelected: (role) => widget.viewModel.filterByRole(role),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: null, child: Text('Todos')),
                  ...UserRole.values.map(
                    (role) => PopupMenuItem(
                      value: role,
                      child: Text(role.label),
                    ),
                  ),
                ],
              ),
              // Limpar filtros
              if (widget.viewModel.roleFilter != null ||
                  widget.viewModel.searchQuery != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Limpar filtros',
                  onPressed: () {
                    _searchController.clear();
                    widget.viewModel.clearFilters();
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              // Barra de busca
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome, email ou username',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              widget.viewModel.searchUsers(null);
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: widget.viewModel.searchUsers,
                ),
              ),

              if (widget.viewModel.isOwner)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: _showCreateUserDialog,
                        child: const Text('Adicionar Usuário'),
                      ),
                    ],
                  ),
                ),

              // Filtros ativos
              if (widget.viewModel.roleFilter != null ||
                  widget.viewModel.searchQuery != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (widget.viewModel.roleFilter != null)
                        Chip(
                          label: Text(
                            'Role: ${widget.viewModel.roleFilter!.label}',
                          ),
                          onDeleted: () => widget.viewModel.filterByRole(null),
                        ),
                      if (widget.viewModel.searchQuery != null)
                        Chip(
                          label: Text('Busca: ${widget.viewModel.searchQuery}'),
                          onDeleted: () {
                            _searchController.clear();
                            widget.viewModel.searchUsers(null);
                          },
                        ),
                    ],
                  ),
                ),

              // Lista de usuários
              Expanded(child: _buildUsersList()),
            ],
          ),
        );
      },
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
      child: ListView.builder(
        controller: _scrollController,
        itemCount:
            widget.viewModel.users.length +
            (widget.viewModel.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.viewModel.users.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final user = widget.viewModel.users[index];
          return _buildUserTile(user);
        },
      ),
    );
  }

  Widget _buildUserTile(UserDetails user) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          backgroundImage: user.avatarUrl != null
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(user.name, style: theme.textTheme.titleMedium),
            ),
            // Badge de role
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user.role.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text('@${user.username}'),
            const SizedBox(height: 4),
            Row(
              children: [
                if (user.emailVerified)
                  const Icon(Icons.verified, size: 16, color: Colors.green),
                if (user.emailVerified) const SizedBox(width: 4),
                if (user.emailVerified)
                  const Text(
                    'Verificado',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                if (user.emailVerified) const SizedBox(width: 8),
                Icon(
                  user.isActive ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: user.isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  user.isActive ? 'Ativo' : 'Inativo',
                  style: TextStyle(
                    fontSize: 12,
                    color: user.isActive ? Colors.green : Colors.red,
                  ),
                ),
                if (user.isDeleted) const SizedBox(width: 8),
                if (user.isDeleted)
                  const Icon(Icons.delete, size: 16, color: Colors.orange),
                if (user.isDeleted) const SizedBox(width: 4),
                if (user.isDeleted)
                  const Text(
                    'Deletado',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('Ver detalhes'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'role',
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings),
                  SizedBox(width: 8),
                  Text('Alterar role'),
                ],
              ),
            ),
            if (widget.viewModel.canResetPassword(user))
              const PopupMenuItem(
                value: 'reset-password',
                child: Row(
                  children: [
                    Icon(Icons.lock_reset),
                    SizedBox(width: 8),
                    Text('Resetar senha'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(user.isActive ? Icons.block : Icons.check_circle),
                  const SizedBox(width: 8),
                  Text(user.isActive ? 'Desativar' : 'Ativar'),
                ],
              ),
            ),
            if (!user.isDeleted)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Deletar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
          onSelected: (value) => _handleUserAction(value, user),
        ),
      ),
    );
  }

  void _handleUserAction(String action, UserDetails user) {
    switch (action) {
      case 'details':
        _showUserDetails(user);
        break;
      case 'role':
        _showChangeRoleDialog(user);
        break;
      case 'reset-password':
        // _confirmResetPassword(user);
        DsDialog.confirm(
          context,
          title: 'Resetar Senha',
          message: 'Tem certeza que deseja resetar a senha de ${user.name}?',
          confirmText: 'Resetar Senha', // AppLocalizations.of(context).delete
          messageAlert:
              'O usuário será obrigado a alterar a senha no próximo login.',
          bannerAlert: 'Esta ação não pode ser desfeita.',
          confirmedText:
              'Senha resetada com sucesso. ${user.name} deverá alterar a senha no próximo login.',
          canceledText: widget.viewModel.error ?? 'Erro ao resetar senha',
          onConfirm: () async {
            final success = await widget.viewModel.resetUserPassword(user.id);
            return success;
          },
        );
        break;
      case 'toggle':
        _toggleUserStatus(user);
        break;
      case 'delete':
        DsDialog.confirm(
          context,
          title: 'Deletar usuário',
          message: 'Tem certeza que deseja deletar ${user.name}?',
          confirmText: AppLocalizations.of(context).delete,
          messageAlert: 'Esta ação não pode ser desfeita.',
          confirmedText: 'Usuário deletado com sucesso',
          canceledText: 'Erro ao deletar usuário',
          onConfirm: () async {
            final success = await widget.viewModel.deleteUser(user.id);
            return success;
          },
        );
        break;
    }
  }

  void _showUserDetails(UserDetails user) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('ID', user.id),
              _detailRow('Email', user.email),
              _detailRow('Username', user.username),
              _detailRow('Role', user.role.label),
              _detailRow('Telefone', user.phone ?? 'N/A'),
              _detailRow(
                'Email Verificado',
                user.emailVerified ? 'Sim' : 'Não',
              ),
              _detailRow('Status', user.isActive ? 'Ativo' : 'Inativo'),
              _detailRow('Criado em', _formatDate(user.createdAt)),
              _detailRow('Atualizado em', _formatDate(user.updatedAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(UserDetails user) {
    UserRole? selectedRole = user.role;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (innerContext, setState) => AlertDialog(
          title: const Text('Alterar Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: UserRole.values.map((role) {
              final isSelected = selectedRole == role;
              return InkWell(
                onTap: () {
                  setState(() => selectedRole = role);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? Theme.of(innerContext).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text(role.label),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(innerContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: selectedRole != user.role
                  ? () async {
                      Navigator.pop(innerContext);
                      final success = await widget.viewModel.updateUserRole(
                        user.id,
                        selectedRole!,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Role atualizado com sucesso'
                                  : 'Erro ao atualizar role',
                            ),
                            backgroundColor: success
                                ? Colors.green
                                : Colors.red,
                          ),
                        );
                      }
                    }
                  : null,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleUserStatus(UserDetails user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isActive ? 'Desativar usuário' : 'Ativar usuário'),
        content: Text(
          user.isActive
              ? 'Tem certeza que deseja desativar ${user.name}?'
              : 'Tem certeza que deseja ativar ${user.name}?',
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
      final success = await widget.viewModel.toggleUserStatus(
        user.id,
        !user.isActive,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Status atualizado com sucesso'
                  : 'Erro ao atualizar status',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  // Future<void> _confirmDeleteUser(UserDetails user) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Deletar usuário'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Tem certeza que deseja deletar ${user.name}?'),
  //           const SizedBox(height: 8),
  //           const Text(
  //             'Esta ação não pode ser desfeita.',
  //             style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Cancelar'),
  //         ),
  //         FilledButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           style: FilledButton.styleFrom(backgroundColor: Colors.red),
  //           child: const Text('Deletar'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirmed == true && mounted) {
  //     final success = await widget.viewModel.deleteUser(user.id);
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             success
  //                 ? 'Usuário deletado com sucesso'
  //                 : 'Erro ao deletar usuário',
  //           ),
  //           backgroundColor: success ? Colors.green : Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  // Future<void> _confirmResetPassword(UserDetails user) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Resetar Senha'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Tem certeza que deseja resetar a senha de ${user.name}?'),
  //           const SizedBox(height: 12),
  //           const Text(
  //             'O usuário será obrigado a alterar a senha no próximo login.',
  //             style: TextStyle(
  //               fontSize: 13,
  //               fontStyle: FontStyle.italic,
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Container(
  //             padding: const EdgeInsets.all(8),
  //             decoration: BoxDecoration(
  //               color: Colors.orange.shade50,
  //               borderRadius: BorderRadius.circular(8),
  //               border: Border.all(color: Colors.orange.shade200),
  //             ),
  //             child: const Row(
  //               children: [
  //                 Icon(Icons.info_outline, size: 20, color: Colors.orange),
  //                 SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text(
  //                     'Esta ação não pode ser desfeita.',
  //                     style: TextStyle(fontSize: 12, color: Colors.orange),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Cancelar'),
  //         ),
  //         FilledButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           child: const Text('Confirmar'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirmed == true && mounted) {
  //     final success = await widget.viewModel.resetUserPassword(user.id);
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             success
  //                 ? 'Senha resetada com sucesso. ${user.name} deverá alterar a senha no próximo login.'
  //                 : widget.viewModel.error ?? 'Erro ao resetar senha',
  //           ),
  //           backgroundColor: success ? Colors.green : Colors.red,
  //           duration: Duration(seconds: success ? 4 : 3),
  //         ),
  //       );
  //     }
  //   }
  // }

  void _showCreateUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final usernameController = TextEditingController();
    final phoneController = TextEditingController();
    UserRole selectedRole = UserRole.user;

    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (innerContext, setState) => ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final isLoading = widget.viewModel.isLoading;

            return AlertDialog(
              title: const Text('Adicionar Usuário'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome completo *',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }
                          if (value.trim().length < 2) {
                            return 'Nome deve ter no mínimo 2 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email é obrigatório';
                          }
                          final emailRegex = RegExp(
                            r'^[\w\.-]+@[\w\.-]+\.\w{2,}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Formato de email inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username *',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username é obrigatório';
                          }
                          if (value.length < 3) {
                            return 'Username deve ter no mínimo 3 caracteres';
                          }
                          if (value.contains(' ')) {
                            return 'Username não pode conter espaços';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone (opcional)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 10) {
                            return 'Telefone deve ter no mínimo 10 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<UserRole>(
                        initialValue: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role *',
                          border: OutlineInputBorder(),
                        ),
                        items: UserRole.values.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role.label),
                          );
                        }).toList(),
                        onChanged: isLoading
                            ? null
                            : (role) {
                                setState(
                                  () => selectedRole = role ?? UserRole.user,
                                );
                              },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'O usuário receberá um email para definir a senha no primeiro acesso.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (isLoading) ...[
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pop(innerContext),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final data = UserCreateAdmin(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              username: usernameController.text.trim(),
                              role: selectedRole,
                              phone: phoneController.text.trim().isEmpty
                                  ? null
                                  : phoneController.text.trim(),
                            );

                            final success = await widget.viewModel.createUser(
                              data,
                            );

                            // Guardar referência ao context antes de usar
                            if (!innerContext.mounted) return;
                            Navigator.pop(innerContext);

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Usuário criado com sucesso'
                                      : widget.viewModel.error ??
                                            'Erro ao criar usuário',
                                ),
                                backgroundColor: success
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          }
                        },
                  child: const Text('Criar'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
