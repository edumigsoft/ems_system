import 'package:core_shared/core_shared.dart' show UserRole;
import 'package:flutter/material.dart';

extension UserRoleExtension on UserRole {
  Color get color {
    return switch (this) {
      UserRole.owner => Colors.purple,
      UserRole.admin => Colors.orange,
      UserRole.manager => Colors.green,
      UserRole.user => Colors.blue,
    };
  }

  String get label {
    return switch (this) {
      UserRole.owner => 'Proprietário',
      UserRole.admin => 'Administrador',
      UserRole.manager => 'Gerente',
      UserRole.user => 'Usuário',
    };
  }
}
