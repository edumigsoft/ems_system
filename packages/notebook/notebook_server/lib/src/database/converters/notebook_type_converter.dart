import 'package:drift/drift.dart';
import 'package:notebook_shared/notebook_shared.dart';

/// Converter for NotebookType enum to/from String for database storage.
///
/// Maps between [NotebookType] enum and String representation.
/// Uses 'quick' as default value when null or when stored value doesn't match any enum value.
class NotebookTypeConverter extends TypeConverter<NotebookType?, String> {
  const NotebookTypeConverter();

  @override
  NotebookType? fromSql(String fromDb) {
    try {
      return NotebookType.values.firstWhere(
        (e) => e.name == fromDb,
        orElse: () => NotebookType.quick,
      );
    } catch (_) {
      return NotebookType.quick;
    }
  }

  @override
  String toSql(NotebookType? value) {
    return value?.name ?? 'quick';
  }
}
