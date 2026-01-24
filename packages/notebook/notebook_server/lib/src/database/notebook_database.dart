import 'package:drift/drift.dart';

import 'tables/document_reference_table.dart';
import 'tables/notebook_table.dart';
import 'tables/notebook_tag_table.dart';

part 'notebook_database.g.dart';

/// Modular database for Notebook feature.
///
/// Includes tables:
/// - [NotebookTable]: Main notebooks table
/// - [DocumentReferenceTable]: Document attachments
/// - [NotebookTagTable]: Junction table for notebook-tag relationships
@DriftDatabase(
  tables: [
    NotebookTable,
    DocumentReferenceTable,
    NotebookTagTable,
  ],
)
class NotebookDatabase extends _$NotebookDatabase {
  NotebookDatabase(super.e);

  @override
  int get schemaVersion => 1;

  /// Ensures that the module's tables exist.
  ///
  /// Creates tables if they don't exist, ignoring "already exists" errors.
  /// This allows multiple modules to safely initialize their tables.
  Future<void> init() async {
    final m = createMigrator();
    for (final table in allTables) {
      try {
        await m.createTable(table);
      } catch (e) {
        // Ignore "already exists" errors (PostgreSQL error 42P07)
        if (!e.toString().contains('already exists') &&
            !e.toString().contains('42P07')) {
          rethrow;
        }
      }
    }
  }
}
