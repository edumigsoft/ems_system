import 'package:core_shared/core_shared.dart' show UserRole;
import 'package:core_ui/core_ui.dart' show UserRoleExtension;
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:user_shared/user_shared.dart';
import '../view_models/manage_users_view_model.dart';

/// Página de formulário para criar/editar usuário.
///
/// Sem Scaffold/AppBar — usa DSCardHeader com botão de voltar.
/// Campos criar: nome, email, username, telefone, role.
/// Campos editar: nome, telefone, role (owner only), ativo.
class ManageUsersFormPage extends StatefulWidget {
  final ManageUsersViewModel viewModel;
  final UserDetails? user;

  const ManageUsersFormPage({
    super.key,
    required this.viewModel,
    this.user,
  });

  @override
  State<ManageUsersFormPage> createState() => _ManageUsersFormPageState();
}

class _ManageUsersFormPageState extends State<ManageUsersFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  UserRole _selectedRole = UserRole.user;
  bool _isActive = true;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.user!.name;
      _phoneController.text = widget.user!.phone ?? '';
      _selectedRole = widget.user!.role;
      _isActive = widget.user!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditing) {
      final user = widget.user!;

      if (_nameController.text.trim() != user.name ||
          _phoneController.text.trim() != (user.phone ?? '')) {
        final success = await widget.viewModel.updateUserBasicInfo(
          userId: user.id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );
        if (!success || !mounted) return;
      }

      if (_selectedRole != user.role && widget.viewModel.isOwner) {
        final success = await widget.viewModel.updateUserRole(
          user.id,
          _selectedRole,
        );
        if (!success || !mounted) return;
      }

      if (_isActive != user.isActive) {
        final success = await widget.viewModel.toggleUserStatus(
          user.id,
          _isActive,
        );
        if (!success || !mounted) return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário atualizado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      final data = UserCreateAdmin(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        role: _selectedRole,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      final success = await widget.viewModel.createUser(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Usuário criado com sucesso'
                  : widget.viewModel.error ?? 'Erro ao criar usuário',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DSCardHeader(
          title: _isEditing ? 'Editar Usuário' : 'Novo Usuário',
          subtitle: _isEditing
              ? widget.user!.name
              : 'Preencha os dados do novo usuário',
          showSearch: false,
          actionButton: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Voltar',
          ),
        ),
        Expanded(
          child: DSCard(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo *',
                        border: OutlineInputBorder(),
                      ),
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
                    const SizedBox(height: 16),

                    // Email — apenas criação
                    if (!_isEditing) ...[
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
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
                      const SizedBox(height: 16),

                      // Username — apenas criação
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username *',
                          border: OutlineInputBorder(),
                        ),
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
                      const SizedBox(height: 16),
                    ],

                    // Telefone
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 10) {
                          return 'Telefone deve ter no mínimo 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Role — criação sempre; edição apenas owner
                    if (!_isEditing || widget.viewModel.isOwner)
                      DropdownButtonFormField<UserRole>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Função *',
                          border: OutlineInputBorder(),
                        ),
                        items: UserRole.values.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role.label),
                          );
                        }).toList(),
                        onChanged: (role) {
                          if (role != null) {
                            setState(() => _selectedRole = role);
                          }
                        },
                      ),

                    // Status ativo — apenas edição
                    if (_isEditing) ...[
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Usuário Ativo'),
                        value: _isActive,
                        onChanged: (value) =>
                            setState(() => _isActive = value),
                      ),
                    ],

                    if (!_isEditing) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'O usuário receberá um email para definir a senha no primeiro acesso.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    ListenableBuilder(
                      listenable: widget.viewModel,
                      builder: (context, _) {
                        final isLoading = widget.viewModel.isLoading;
                        return SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isLoading ? null : _handleSubmit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isEditing ? 'Salvar' : 'Criar Usuário',
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
