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
    return db.transaction(() async {
      try {
        // 1. Criar o notebook (sem a coluna tags JSON)
        final companion = NotebookTableCompanion.insert(
          title: data.title,
          content: data.content,
          projectId: Value(data.projectId),
          parentId: Value(data.parentId),
          type: Value(data.type),
          reminderDate: Value(data.reminderDate),
          notifyOnReminder: Value(data.notifyOnReminder),
          documentIds: const Value(null),
          tags: const Value(null), // Ignora coluna legada
        );

        final row = await db.into(db.notebookTable).insertReturning(companion);

        // 2. Inserir tags na junction table
        if (data.tags != null && data.tags!.isNotEmpty) {
          await db.batch((batch) {
            batch.insertAll(
              db.notebookTagTable,
              data.tags!.map((tagId) {
                return NotebookTagTableCompanion.insert(
                  notebookId: row.id,
                  tagId: tagId,
                );
              }),
            );
          });
        }

        // 3. Retornar com tags preenchidas
        return Success(row.copyWith(tags: data.tags));
      } catch (e, s) {
        return Failure(
          StorageException('Error creating notebook', stackTrace: s),
        );
      }
    });
  }

  @override
  Future<Result<NotebookDetails>> getById(String id) async {
    try {
      final notebook = await (db.select(
        db.notebookTable,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (notebook == null) {
        return Failure(StorageException('Notebook not found'));
      }

      // Carregar tags associadas
      final tagsQuery = db.select(db.notebookTagTable)
        ..where((t) => t.notebookId.equals(id));
      final tags = await tagsQuery.map((row) => row.tagId).get();

      return Success(notebook.copyWith(tags: tags));
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

      // --- Filtros ---

      if (activeOnly) {
        query.where((t) => t.isActive.equals(1) & t.isDeleted.equals(0));
      }

      if (search != null && search.isNotEmpty) {
        query.where(
          (t) => t.title.contains(search) | t.content.contains(search),
        );
      }

      if (projectId != null) {
        query.where((t) => t.projectId.equals(projectId));
      }

      if (parentId != null) {
        query.where((t) => t.parentId.equals(parentId));
      }

      if (type != null) {
        query.where((t) => t.type.equals(type.name));
      }

      if (overdueOnly) {
        final now = DateTime.now();
        query.where(
          (t) =>
              t.reminderDate.isSmallerThanValue(now.toIso8601String()) &
              t.reminderDate.isNotNull(),
        );
      }

      // Filtro por tags usando JOIN com a tabela de junção
      if (tags != null && tags.isNotEmpty) {
        // Subquery para encontrar notebooks que tenham UMA DAS tags (OR logic)
        final subQuery = db.selectOnly(db.notebookTagTable)
          ..addColumns([db.notebookTagTable.notebookId]);

        subQuery.where(db.notebookTagTable.tagId.isIn(tags));
        subQuery.groupBy([db.notebookTagTable.notebookId]);

        query.where((t) => t.id.isInQuery(subQuery));
      }

      // Executar query principal
      final notebooks = await query.get();

      // Carregar tags para todos os notebooks retornados
      // Para evitar N+1, fazemos uma query para pegar todas as tags desses notebooks
      if (notebooks.isEmpty) {
        return const Success([]);
      }

      final notebookIds = notebooks.map((n) => n.id).toList();
      final allTagsQuery = db.select(db.notebookTagTable)
        ..where((t) => t.notebookId.isIn(notebookIds));

      final allTags = await allTagsQuery.get();

      // Agrupar tags por notebookId
      final tagsMap = <String, List<String>>{};
      for (final row in allTags) {
        tagsMap.putIfAbsent(row.notebookId, () => []).add(row.tagId);
      }

      // Mapear resultado
      final details = notebooks.map((row) {
        final tags = tagsMap[row.id] ?? [];
        return row.copyWith(tags: tags);
      }).toList();

      return Success(details);
    } catch (e, s) {
      return Failure(
        StorageException('Error listing notebooks', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<NotebookDetails>> update(NotebookUpdate data) async {
    return db.transaction(() async {
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
          type: data.type != null ? Value(data.type) : const Value.absent(),
          reminderDate: data.reminderDate != null
              ? Value(data.reminderDate!)
              : const Value.absent(),
          notifyOnReminder: data.notifyOnReminder != null
              ? Value(data.notifyOnReminder)
              : const Value.absent(),
          tags: const Value(null), // Ignora coluna legada
        );

        final query = db.update(db.notebookTable)
          ..where((t) => t.id.equals(data.id));

        final rows = await query.writeReturning(companion);
        if (rows.isEmpty) {
          return Failure(StorageException('Notebook not found'));
        }

        final updatedRow = rows.first;
        List<String> currentTags = [];

        // Atualizar tags se fornecidas
        if (data.tags != null) {
          // 1. Remover associações antigas
          await (db.delete(
            db.notebookTagTable,
          )..where((t) => t.notebookId.equals(data.id))).go();

          // 2. Inserir novas associações
          if (data.tags!.isNotEmpty) {
            await db.batch((batch) {
              batch.insertAll(
                db.notebookTagTable,
                data.tags!.map((tagId) {
                  return NotebookTagTableCompanion.insert(
                    notebookId: data.id,
                    tagId: tagId,
                  );
                }),
              );
            });
            currentTags = data.tags!;
          }
        } else {
          // Se tags não foram atualizadas, precisamos carregá-las
          final tagsQuery = db.select(db.notebookTagTable)
            ..where((t) => t.notebookId.equals(data.id));
          currentTags = await tagsQuery.map((row) => row.tagId).get();
        }

        return Success(updatedRow.copyWith(tags: currentTags));
      } catch (e, s) {
        return Failure(
          StorageException('Error updating notebook', stackTrace: s),
        );
      }
    });
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
