import 'package:drift/drift.dart';
import 'package:core_shared/core_shared.dart'
    show Failure, StorageException, Result, Success;
import 'package:tag_shared/tag_shared.dart'
    show TagDetails, TagCreate, TagUpdate, TagRepository;

import '../database/tag_database.dart';

/// Server implementation of TagRepository using Drift/PostgreSQL.
class TagRepositoryServer implements TagRepository {
  final TagDatabase db;

  TagRepositoryServer(this.db);

  @override
  Future<Result<TagDetails>> create(TagCreate data) async {
    try {
      final companion = TagTableCompanion.insert(
        name: data.name,
        description: Value(data.description),
        color: Value(data.color),
        usageCount: const Value(0),
        isActive: const Value(true),
        isDeleted: const Value(false),
      );

      final result = await db.into(db.tagTable).insertReturning(companion);
      return Success(result);
    } catch (e, s) {
      return Failure(
        StorageException('Error creating tag', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<TagDetails>> getById(String id) async {
    try {
      final result = await (db.select(
        db.tagTable,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (result == null) {
        return Failure(StorageException('Tag not found'));
      }
      return Success(result);
    } catch (e, s) {
      return Failure(
        StorageException('Error finding tag', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<List<TagDetails>>> getAll({
    bool activeOnly = true,
    String? search,
  }) async {
    try {
      final query = db.select(db.tagTable);

      // Apply filters
      if (activeOnly) {
        query.where((t) => t.isActive.equals(1)); // BooleanConverter: 1 = true
        query.where(
          (t) => t.isDeleted.equals(0),
        ); // BooleanConverter: 0 = false
      }

      if (search != null && search.isNotEmpty) {
        query.where((t) => t.name.like('%$search%'));
      }

      // Order by name
      query.orderBy([(t) => OrderingTerm.asc(t.name)]);

      final results = await query.get();
      return Success(results);
    } catch (e, s) {
      return Failure(
        StorageException('Error fetching tags', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<TagDetails>> update(TagUpdate data) async {
    try {
      // Build update companion dynamically
      final companion = TagTableCompanion(
        id: Value(data.id),
        name: data.name != null ? Value(data.name!) : const Value.absent(),
        description: data.description != null
            ? Value(data.description)
            : const Value.absent(),
        color: data.color != null ? Value(data.color) : const Value.absent(),
        isActive: data.isActive != null
            ? Value(data.isActive!)
            : const Value.absent(),
        isDeleted: data.isDeleted != null
            ? Value(data.isDeleted!)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      final result = await (db.update(
        db.tagTable,
      )..where((t) => t.id.equals(data.id))).writeReturning(companion);

      if (result.isEmpty) {
        return Failure(StorageException('Tag not found'));
      }

      return Success(result.first);
    } catch (e, s) {
      return Failure(
        StorageException('Error updating tag', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      final companion = TagTableCompanion(
        id: Value(id),
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      );

      final affectedRows = await (db.update(
        db.tagTable,
      )..where((t) => t.id.equals(id))).write(companion);

      if (affectedRows == 0) {
        return Failure(StorageException('Tag not found'));
      }

      return const Success(null);
    } catch (e, s) {
      return Failure(
        StorageException('Error deleting tag', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<void>> restore(String id) async {
    try {
      final companion = TagTableCompanion(
        id: Value(id),
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      );

      final affectedRows = await (db.update(
        db.tagTable,
      )..where((t) => t.id.equals(id))).write(companion);

      if (affectedRows == 0) {
        return Failure(StorageException('Tag not found'));
      }

      return const Success(null);
    } catch (e, s) {
      return Failure(
        StorageException('Error restoring tag', stackTrace: s),
      );
    }
  }
}
