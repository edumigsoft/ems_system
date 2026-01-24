import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
import 'package:notebook_shared/notebook_shared.dart'
    show DocumentReferenceDetails;

import '../converters/storage_type_converter.dart';
import 'notebook_table.dart';

/// Drift table for document references with PostgreSQL backend.
///
/// Usa [@UseRowClass] para mapear diretamente para [DocumentReferenceDetails] do domínio.
///
/// Uses [DriftTableMixinPostgres] to automatically include:
/// - id (UUID primary key)
/// - isDeleted (soft delete flag)
/// - isActive (active status flag)
/// - createdAt (creation timestamp)
/// - updatedAt (update timestamp)
@UseRowClass(DocumentReferenceDetails, constructor: 'create')
class DocumentReferenceTable extends Table with DriftTableMixinPostgres {
  @override
  String get tableName => 'document_references';

  /// Name of the document/file (required).
  TextColumn get name => text()();

  /// Path or URL to the document (required).
  ///
  /// Can be a local path, server path, or external URL depending on storageType.
  TextColumn get path => text()();

  /// Storage type: server, local, or url (required).
  @JsonKey('storage_type')
  TextColumn get storageType =>
      text().map(const DocumentStorageTypeConverter())();

  /// MIME type of the document (optional).
  ///
  /// Examples: 'application/pdf', 'image/png', 'text/plain'
  @JsonKey('mime_type')
  TextColumn get mimeType => text().nullable()();

  /// Size in bytes (optional).
  @JsonKey('size_bytes')
  IntColumn get sizeBytes => integer().nullable()();

  /// Foreign key to the notebook this document belongs to (optional).
  ///
  /// If null, document is not attached to any notebook.
  /// OnDelete: SetNull - if notebook is deleted, document reference is preserved.
  @JsonKey('notebook_id')
  TextColumn get notebookId => text().nullable().references(
    NotebookTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
}
