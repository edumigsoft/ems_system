import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart';

/// Badge reutilizável para exibir o role do usuário.
///
/// Mostra o role com cor correspondente:
/// - Owner: roxo
/// - Admin: azul
/// - Manager: verde
/// - User: cinza
class UserRoleBadge extends StatelessWidget {
  final UserRole role;
  final bool compact;

  const UserRoleBadge({
    super.key,
    required this.role,
    this.compact = false,
  });

  Color get _backgroundColor {
    switch (role) {
      case UserRole.owner:
        return Colors.purple.shade100;
      case UserRole.admin:
        return Colors.blue.shade100;
      case UserRole.manager:
        return Colors.green.shade100;
      case UserRole.user:
        return Colors.grey.shade200;
    }
  }

  Color get _textColor {
    switch (role) {
      case UserRole.owner:
        return Colors.purple.shade900;
      case UserRole.admin:
        return Colors.blue.shade900;
      case UserRole.manager:
        return Colors.green.shade900;
      case UserRole.user:
        return Colors.grey.shade800;
    }
  }

  String get _label {
    switch (role) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.user:
        return 'Usuário';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _label,
        style: TextStyle(
          color: _textColor,
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: _backgroundColor,
      visualDensity: compact ? VisualDensity.compact : null,
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 4)
          : const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
