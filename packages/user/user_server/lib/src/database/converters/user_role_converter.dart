import 'package:drift/drift.dart';
import 'package:core_shared/core_shared.dart' show UserRole;

/// Converter para [UserRole] em colunas de texto Drift.
///
/// Converte entre o enum [UserRole] e sua representação String no banco.
class UserRoleConverter extends TypeConverter<UserRole, String> {
  const UserRoleConverter();

  @override
  UserRole fromSql(String fromDb) {
    return UserRole.values.firstWhere(
      (role) => role.name == fromDb,
      orElse: () => UserRole.user,
    );
  }

  @override
  String toSql(UserRole value) {
    return value.name;
  }
}
