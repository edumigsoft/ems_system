import 'package:core_shared/core_shared.dart' show UserRole;
import 'package:core_ui/core_ui.dart' show ResponsiveLayout, UserRoleExtension;
import 'package:flutter/material.dart';
import 'package:user_shared/user_shared.dart' show UserCreateAdmin;
import '../view_models/manage_users_view_model.dart';
import '../ui/widgets/components/mobile/mobile_widget.dart';
import '../ui/widgets/components/tablet/tablet_widget.dart';

/// Página de Gerenciamento de Usuários (Admin).
///
/// Permite administradores visualizar, buscar, filtrar e gerenciar usuários.
/// Recebe ViewModel via construtor (DI).
///
/// Usa ResponsiveLayout com layouts específicos para Mobile e Tablet/Desktop.
class ManageUsersPage extends StatefulWidget {
  final ManageUsersViewModel viewModel;

  const ManageUsersPage({super.key, required this.viewModel});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  @override
  void initState() {
    super.initState();
    // Carrega usuários ao abrir a página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.initialize();
      widget.viewModel.loadUsers(refresh: true);
    });
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
              // Adicionar usuário (apenas owner)
              if (widget.viewModel.isOwner)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  tooltip: 'Adicionar Usuário',
                  onPressed: _showCreateUserDialog,
                ),
            ],
          ),
          body: ResponsiveLayout(
            mobile: MobileWidget(viewModel: widget.viewModel),
            tablet: TabletWidget(viewModel: widget.viewModel),
            desktop: TabletWidget(viewModel: widget.viewModel), // Temporary
          ),
        );
      },
    );
  }

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
}
