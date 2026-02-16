import 'package:drift/drift.dart';
import 'package:core_shared/core_shared.dart'
    show Failure, StorageException, Result, Success;
import 'package:notebook_shared/notebook_shared.dart'
    show
        DocumentReferenceDetails,
        DocumentReferenceCreate,
        DocumentReferenceUpdate,
        DocumentReferenceRepository,
        DocumentStorageType;

import '../database/notebook_database.dart';

/// Implementação server-side do DocumentReferenceRepository usando Drift.
///
/// Gerencia a persistência de referências de documentos no banco de dados PostgreSQL.
class DocumentReferenceRepositoryServer implements DocumentReferenceRepository {
  final NotebookDatabase db;

  DocumentReferenceRepositoryServer(this.db);

  @override
  Future<Result<DocumentReferenceDetails>> create(
    DocumentReferenceCreate data,
  ) async {
    try {
      final companion = DocumentReferenceTableCompanion.insert(
        name: data.name,
        path: data.path,
        storageType: data.storageType,
        mimeType: Value(data.mimeType),
        sizeBytes: Value(data.sizeBytes),
        notebookId: Value(data.notebookId),
      );

      final row = await db
          .into(db.documentReferenceTable)
          .insertReturning(companion);
      return Success(row);
    } catch (e, s) {
      return Failure(
        StorageException('Error creating document reference', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<DocumentReferenceDetails>> getById(String id) async {
    try {
      final result = await (db.select(
        db.documentReferenceTable,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (result == null) {
        return Failure(StorageException('Document reference not found'));
      }
      return Success(result);
    } catch (e, s) {
      return Failure(
        StorageException('Error finding document reference', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<List<DocumentReferenceDetails>>> getByNotebookId(
    String notebookId, {
    DocumentStorageType? storageType,
  }) async {
    try {
      final query = db.select(db.documentReferenceTable)
        ..where((t) => t.notebookId.equals(notebookId));

      // Filtro por tipo de armazenamento
      if (storageType != null) {
        query.where((t) => t.storageType.equals(storageType.name));
      }

      final results = await query.get();
      return Success(results);
    } catch (e, s) {
      return Failure(
        StorageException('Error listing document references', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<DocumentReferenceDetails>> update(
    DocumentReferenceUpdate data,
  ) async {
    try {
      final companion = DocumentReferenceTableCompanion(
        name: data.name != null ? Value(data.name!) : const Value.absent(),
        path: data.path != null ? Value(data.path!) : const Value.absent(),
        storageType: data.storageType != null
            ? Value(data.storageType!)
            : const Value.absent(),
        mimeType: data.mimeType != null
            ? Value(data.mimeType)
            : const Value.absent(),
        sizeBytes: data.sizeBytes != null
            ? Value(data.sizeBytes)
            : const Value.absent(),
        notebookId: data.notebookId != null
            ? Value(data.notebookId)
            : const Value.absent(),
      );

      final query = db.update(db.documentReferenceTable)
        ..where((t) => t.id.equals(data.id));
      final rows = await query.writeReturning(companion);

      if (rows.isEmpty) {
        return Failure(StorageException('Document reference not found'));
      }
      return Success(rows.first);
    } catch (e, s) {
      return Failure(
        StorageException('Error updating document reference', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      final query = db.delete(db.documentReferenceTable)
        ..where((t) => t.id.equals(id));
      final deletedRows = await query.go();

      if (deletedRows == 0) {
        return Failure(StorageException('Document reference not found'));
      }
      return Success(null);
    } catch (e, s) {
      return Failure(
        StorageException('Error deleting document reference', stackTrace: s),
      );
    }
  }
}
