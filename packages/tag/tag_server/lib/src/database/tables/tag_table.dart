import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
import 'package:tag_shared/tag_shared.dart';

/// Drift table for tags with PostgreSQL backend.
///
/// Uses [DriftTableMixinPostgres] to automatically include:
/// - id (UUID primary key)
/// - isDeleted (soft delete flag)
/// - isActive (active status flag)
/// - createdAt (creation timestamp)
/// - updatedAt (update timestamp)
///
/// This table maps to [TagDetails] entity via @UseRowClass.
@UseRowClass(TagDetails)
class TagTable extends Table with DriftTableMixinPostgres {
  @override
  String get tableName => 'tags';

  /// Tag name (required, max 50 characters).
  TextColumn get name => text().withLength(min: 1, max: 50)();

  /// Optional description (max 200 characters).
  TextColumn get description => text().withLength(max: 200).nullable()();

  /// Optional hex color code (e.g., #FF5722).
  TextColumn get color => text().withLength(max: 9).nullable()();

  /// Usage counter - how many times this tag is used.
  IntColumn get usageCount => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {name}, // Tag names must be unique
      ];
}
