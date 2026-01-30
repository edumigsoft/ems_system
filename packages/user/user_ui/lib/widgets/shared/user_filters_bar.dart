import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart';

/// Barra de filtros reutilizável para usuários.
///
/// Permite filtrar por role e status ativo.
class UserFiltersBar extends StatelessWidget {
  final UserRole? selectedRole;
  final bool? selectedActive;
  final ValueChanged<UserRole?> onRoleChanged;
  final ValueChanged<bool?> onActiveChanged;

  const UserFiltersBar({
    super.key,
    this.selectedRole,
    this.selectedActive,
    required this.onRoleChanged,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Filtro de Role
        ChoiceChip(
          label: const Text('Owner'),
          selected: selectedRole == UserRole.owner,
          onSelected: (selected) =>
              onRoleChanged(selected ? UserRole.owner : null),
        ),
        ChoiceChip(
          label: const Text('Admin'),
          selected: selectedRole == UserRole.admin,
          onSelected: (selected) =>
              onRoleChanged(selected ? UserRole.admin : null),
        ),
        ChoiceChip(
          label: const Text('Manager'),
          selected: selectedRole == UserRole.manager,
          onSelected: (selected) =>
              onRoleChanged(selected ? UserRole.manager : null),
        ),
        ChoiceChip(
          label: const Text('Usuário'),
          selected: selectedRole == UserRole.user,
          onSelected: (selected) =>
              onRoleChanged(selected ? UserRole.user : null),
        ),

        // Divider visual
        const SizedBox(width: 8),

        // Filtro de Status Ativo
        ChoiceChip(
          label: const Text('Ativos'),
          selected: selectedActive == true,
          onSelected: (selected) => onActiveChanged(selected ? true : null),
        ),
        ChoiceChip(
          label: const Text('Inativos'),
          selected: selectedActive == false,
          onSelected: (selected) => onActiveChanged(selected ? false : null),
        ),
      ],
    );
  }
}
