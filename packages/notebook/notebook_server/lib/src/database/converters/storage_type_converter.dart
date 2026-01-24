import 'package:drift/drift.dart';
import 'package:notebook_shared/notebook_shared.dart';

/// Converter for DocumentStorageType enum to/from String for database storage.
///
/// Maps between [DocumentStorageType] enum and String representation.
/// Uses 'server' as default value when null or when stored value doesn't match any enum value.
class DocumentStorageTypeConverter
    extends TypeConverter<DocumentStorageType, String> {
  const DocumentStorageTypeConverter();

  @override
  DocumentStorageType fromSql(String fromDb) {
    try {
      return DocumentStorageType.values.firstWhere(
        (e) => e.name == fromDb,
        orElse: () => DocumentStorageType.server,
      );
    } catch (_) {
      return DocumentStorageType.server;
    }
  }

  @override
  String toSql(DocumentStorageType value) {
    return value.name;
  }
}
