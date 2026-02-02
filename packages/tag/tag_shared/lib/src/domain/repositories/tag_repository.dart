import 'package:core_shared/core_shared.dart';
import '../dtos/tag_create.dart';
import '../dtos/tag_update.dart';
import '../entities/tag_details.dart';

/// Repository interface for tag operations.
///
/// All methods return [Result] to enable explicit error handling
/// without throwing exceptions (ADR-0001: Result Pattern).
///
/// Implementations:
/// - tag_client: HTTP client using Retrofit/Dio
/// - tag_server: Database operations using Drift
abstract class TagRepository {
  /// Creates a new tag.
  ///
  /// Returns [Success] with created [TagDetails] or [Failure] with error.
  Future<Result<TagDetails>> create(TagCreate data);

  /// Retrieves a tag by its ID.
  ///
  /// Returns [Success] with [TagDetails] or [Failure] if not found.
  Future<Result<TagDetails>> getById(String id);

  /// Retrieves all tags.
  ///
  /// Optional filters:
  /// - [activeOnly]: if true, returns only active tags (isActive=true, isDeleted=false)
  /// - [search]: filter by name (case-insensitive)
  ///
  /// Returns [Success] with list of [TagDetails] or [Failure] with error.
  Future<Result<List<TagDetails>>> getAll({
    bool activeOnly = true,
    String? search,
  });

  /// Updates an existing tag.
  ///
  /// Returns [Success] with updated [TagDetails] or [Failure] with error.
  Future<Result<TagDetails>> update(TagUpdate data);

  /// Soft deletes a tag (sets isDeleted=true).
  ///
  /// Returns [Success] with void or [Failure] with error.
  Future<Result<void>> delete(String id);

  /// Restores a soft-deleted tag (sets isDeleted=false).
  ///
  /// Returns [Success] with void or [Failure] with error.
  Future<Result<void>> restore(String id);
}
