import 'package:drift/drift.dart';
import 'package:school_shared/school_shared.dart' show SchoolStatus;

/// Converter para [SchoolStatus] em colunas de texto Drift.
///
/// Converte entre o enum [SchoolStatus] e sua representação String no banco.
class SchoolStatusConverter extends TypeConverter<SchoolStatus, String> {
  const SchoolStatusConverter();

  @override
  SchoolStatus fromSql(String fromDb) {
    return SchoolStatus.values.firstWhere(
      (role) => role.name == fromDb,
      orElse: () => SchoolStatus.inactive,
    );
  }

  @override
  String toSql(SchoolStatus value) {
    return value.name;
  }
}
