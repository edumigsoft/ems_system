import 'package:core_shared/core_shared.dart';
import '../dtos/notebook_create.dart';
import '../dtos/notebook_update.dart';
import '../entities/notebook_details.dart';
import '../enums/notebook_type.dart';

/// Repository interface for notebook operations.
///
/// All methods return [Result] to enable explicit error handling
/// without throwing exceptions (ADR-0001: Result Pattern).
///
/// Implementations:
/// - notebook_client: HTTP client using Retrofit/Dio
/// - notebook_server: Database operations using Drift
abstract class NotebookRepository {
  /// Creates a new notebook.
  ///
  /// Returns [Success] with created [NotebookDetails] or [Failure] with error.
  Future<Result<NotebookDetails>> create(NotebookCreate data);

  /// Retrieves a notebook by its ID.
  ///
  /// Returns [Success] with [NotebookDetails] or [Failure] if not found.
  Future<Result<NotebookDetails>> getById(String id);

  /// Retrieves all notebooks.
  ///
  /// Optional filters:
  /// - [activeOnly]: if true, returns only active notebooks (isActive=true, isDeleted=false)
  /// - [search]: filter by title or content (case-insensitive)
  /// - [projectId]: filter by project
  /// - [parentId]: filter by parent notebook
  /// - [type]: filter by notebook type
  /// - [tags]: filter by tags (notebooks must have all specified tags)
  /// - [overdueOnly]: if true, returns only overdue reminders
  ///
  /// Returns [Success] with list of [NotebookDetails] or [Failure] with error.
  Future<Result<List<NotebookDetails>>> getAll({
    bool activeOnly = true,
    String? search,
    String? projectId,
    String? parentId,
    NotebookType? type,
    List<String>? tags,
    bool overdueOnly = false,
  });

  /// Updates an existing notebook.
  ///
  /// Returns [Success] with updated [NotebookDetails] or [Failure] with error.
  Future<Result<NotebookDetails>> update(NotebookUpdate data);

  /// Soft deletes a notebook (sets isDeleted=true).
  ///
  /// Returns [Success] with void or [Failure] with error.
  Future<Result<void>> delete(String id);

  /// Restores a soft-deleted notebook (sets isDeleted=false).
  ///
  /// Returns [Success] with void or [Failure] with error.
  Future<Result<void>> restore(String id);
}
