import 'package:drift/drift.dart';

import 'notebook_table.dart';

/// Junction table for many-to-many relationship between Notebooks and Tags.
///
/// This table enables:
/// - One notebook to have multiple tags
/// - One tag to be used across multiple notebooks
///
/// Does NOT use @UseRowClass as it's a pure junction table without
/// a corresponding domain entity.
class NotebookTagTable extends Table {
  @override
  String get tableName => 'notebook_tags';

  /// Composite primary key ensures uniqueness of (notebookId, tagId) pairs.
  @override
  Set<Column> get primaryKey => {notebookId, tagId};

  /// Foreign key to notebook.
  ///
  /// OnDelete: Cascade - if notebook is deleted, remove all tag associations.
  @JsonKey('notebook_id')
  TextColumn get notebookId =>
      text().references(NotebookTable, #id, onDelete: KeyAction.cascade)();

  /// Foreign key to tag (from tag_server package).
  ///
  /// Will add FK constraint after initial code generation.
  @JsonKey('tag_id')
  TextColumn get tagId => text()();

  /// Timestamp when the tag was associated with the notebook.
  ///
  /// Useful for auditing and tracking when tags were added.
  @JsonKey('associated_at')
  DateTimeColumn get associatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
