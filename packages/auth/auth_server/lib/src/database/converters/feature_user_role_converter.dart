import 'package:drift/drift.dart';
import 'package:auth_shared/auth_shared.dart';

/// Conversor Drift para o enum FeatureUserRole.
///
/// Converte entre o enum Dart e string no banco de dados.
/// Padrão de fallback: viewer (papel menos privilegiado).
class FeatureUserRoleConverter extends TypeConverter<FeatureUserRole, String> {
  const FeatureUserRoleConverter();

  @override
  FeatureUserRole fromSql(String fromDb) {
    return FeatureUserRole.values.firstWhere(
      (role) => role.name == fromDb,
      orElse: () => FeatureUserRole.viewer,
    );
  }

  @override
  String toSql(FeatureUserRole value) {
    return value.name;
  }
}
