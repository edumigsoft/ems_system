import 'package:drift/drift.dart';
import 'package:core_shared/core_shared.dart'
    show Failure, StorageException, Result, Success;
import 'package:notebook_shared/notebook_shared.dart'
    show
        NotebookDetails,
        NotebookCreate,
        NotebookUpdate,
        NotebookRepository,
        NotebookType;

import '../database/notebook_database.dart';

/// Implementação server-side do NotebookRepository usando Drift.
///
/// Gerencia a persistência de notebooks no banco de dados PostgreSQL.
class NotebookRepositoryServer implements NotebookRepository {
  final NotebookDatabase db;

  NotebookRepositoryServer(this.db);

  @override
  Future<Result<NotebookDetails>> create(NotebookCreate data) async {
    try {
      final companion = NotebookTableCompanion.insert(
        title: data.title,
        content: data.content,
        projectId: Value(data.projectId),
        parentId: Value(data.parentId),
        tags: Value(data.tags),
        type: Value(data.type),
        reminderDate: Value(data.reminderDate),
        notifyOnReminder: Value(data.notifyOnReminder),
        documentIds: const Value(null), // Inicialmente vazio
      );

      final row = await db.into(db.notebookTable).insertReturning(companion);
      return Success(row);
    } catch (e, s) {
      return Failure(
        StorageException('Error creating notebook', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<NotebookDetails>> getById(String id) async {
    try {
      final result = await (db.select(
        db.notebookTable,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (result == null) {
        return Failure(StorageException('Notebook not found'));
      }
      return Success(result);
    } catch (e, s) {
      return Failure(
        StorageException('Error finding notebook', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<List<NotebookDetails>>> getAll({
    bool activeOnly = true,
    String? search,
    String? projectId,
    String? parentId,
    NotebookType? type,
    List<String>? tags,
    bool overdueOnly = false,
  }) async {
    try {
      // Query base
      final query = db.select(db.notebookTable);

      // Aplicar filtro de ativos (soft delete + status ativo)
      if (activeOnly) {
        query.where((t) => t.isActive.equals(1) & t.isDeleted.equals(0));
      }

      // Filtro de busca por título/conteúdo
      if (search != null && search.isNotEmpty) {
        query.where(
          (t) => t.title.contains(search) | t.content.contains(search),
        );
      }

      // Filtro por projeto
      if (projectId != null) {
        query.where((t) => t.projectId.equals(projectId));
      }

      // Filtro por parent (notebooks filhos)
      if (parentId != null) {
        query.where((t) => t.parentId.equals(parentId));
      }

      // Filtro por tipo
      if (type != null) {
        query.where((t) => t.type.equals(type.name));
      }

      // Filtro de reminders vencidos
      if (overdueOnly) {
        final now = DateTime.now();
        query.where(
          (t) =>
              t.reminderDate.isSmallerThanValue(now.toIso8601String()) &
              t.reminderDate.isNotNull(),
        );
      }

      // Filtro por tags (requer busca em array JSON)
      // Isso requer uma query customizada com operador PostgreSQL @>
      // Por enquanto, vamos pular este filtro

      final results = await query.get();
      return Success(results);
    } catch (e, s) {
      return Failure(
        StorageException('Error listing notebooks', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<NotebookDetails>> update(NotebookUpdate data) async {
    try {
      final companion = NotebookTableCompanion(
        title: data.title != null ? Value(data.title!) : const Value.absent(),
        content: data.content != null
            ? Value(data.content!)
            : const Value.absent(),
        projectId: data.projectId != null
            ? Value(data.projectId)
            : const Value.absent(),
        parentId: data.parentId != null
            ? Value(data.parentId)
            : const Value.absent(),
        tags: data.tags != null ? Value(data.tags) : const Value.absent(),
        type: data.type != null ? Value(data.type) : const Value.absent(),
        reminderDate: data.reminderDate != null
            ? Value(data.reminderDate!)
            : const Value.absent(),
        notifyOnReminder: data.notifyOnReminder != null
            ? Value(data.notifyOnReminder)
            : const Value.absent(),
      );

      final query = db.update(db.notebookTable)
        ..where((t) => t.id.equals(data.id));
      final rows = await query.writeReturning(companion);

      if (rows.isEmpty) {
        return Failure(StorageException('Notebook not found'));
      }
      return Success(rows.first);
    } catch (e, s) {
      return Failure(
        StorageException('Error updating notebook', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      final query = db.update(db.notebookTable)..where((t) => t.id.equals(id));
      await query.write(const NotebookTableCompanion(isDeleted: Value(true)));
      return Success(null);
    } catch (e, s) {
      return Failure(
        StorageException('Error deleting notebook', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<void>> restore(String id) async {
    try {
      final query = db.update(db.notebookTable)..where((t) => t.id.equals(id));
      await query.write(const NotebookTableCompanion(isDeleted: Value(false)));
      return Success(null);
    } catch (e, s) {
      return Failure(
        StorageException('Error restoring notebook', stackTrace: s),
      );
    }
  }
}
