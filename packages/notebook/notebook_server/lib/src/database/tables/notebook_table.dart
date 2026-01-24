import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
import 'package:notebook_shared/notebook_shared.dart' show NotebookDetails;

import '../converters/notebook_type_converter.dart';
import '../converters/string_list_converter.dart';

/// Drift table for notebooks with PostgreSQL backend.
///
/// Usa [@UseRowClass] para mapear diretamente para [NotebookDetails] do domínio,
/// evitando duplicação de classes e simplificando a conversão.
///
/// O Drift usará o construtor NotebookDetails.create() ao ler dados da tabela.
///
/// Uses [DriftTableMixinPostgres] to automatically include:
/// - id (UUID primary key)
/// - isDeleted (soft delete flag)
/// - isActive (active status flag)
/// - createdAt (creation timestamp)
/// - updatedAt (update timestamp)
@UseRowClass(NotebookDetails, constructor: 'create')
class NotebookTable extends Table with DriftTableMixinPostgres {
  @override
  String get tableName => 'notebooks';

  /// Title of the notebook (required).
  TextColumn get title => text()();

  /// Content in Markdown or plain text (required).
  TextColumn get content => text()();

  /// Optional project ID for organizing notebooks by project.
  @JsonKey('project_id')
  TextColumn get projectId => text().nullable()();

  /// Optional parent notebook ID for hierarchical organization.
  ///
  /// Self-referencing foreign key for nested notebooks.
  @JsonKey('parent_id')
  TextColumn get parentId => text().nullable()();

  /// Tags associated with the notebook (array of strings).
  ///
  /// Stored as JSON array in PostgreSQL. Nullable.
  TextColumn get tags => text().nullable().map(const StringListConverter())();

  /// Type of notebook: quick, organized, or reminder.
  TextColumn get type => text()
      .map(NullAwareTypeConverter.wrap(const NotebookTypeConverter()))
      .nullable()();

  /// Optional reminder date/time for reminder-type notebooks.
  @JsonKey('reminder_date')
  DateTimeColumn get reminderDate => dateTime().nullable()();

  /// Whether to send a notification when reminder time is reached.
  @JsonKey('notify_on_reminder')
  IntColumn get notifyOnReminder =>
      integer().map(const BooleanConverter()).nullable()();

  /// List of document IDs attached to this notebook (JSON array).
  ///
  /// This is a denormalized field for quick access. The source of truth
  /// is still the document_references table with the notebook_id FK.
  @JsonKey('document_ids')
  TextColumn get documentIds =>
      text().nullable().map(const StringListConverter())();
}
