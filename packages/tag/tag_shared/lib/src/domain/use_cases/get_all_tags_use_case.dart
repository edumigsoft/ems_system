import 'package:core_shared/core_shared.dart';
import '../entities/tag_details.dart';
import '../repositories/tag_repository.dart';

/// Use case for retrieving all tags.
///
/// Supports filtering by active status and search term.
class GetAllTagsUseCase {
  final TagRepository _repository;

  /// Creates a GetAllTagsUseCase instance.
  const GetAllTagsUseCase(this._repository);

  /// Executes the use case to retrieve all tags.
  ///
  /// Parameters:
  /// - [activeOnly]: if true, returns only active tags (default: true)
  /// - [search]: optional search term to filter by name
  ///
  /// Returns [Success] with list of [TagDetails] or [Failure] with error.
  Future<Result<List<TagDetails>>> call({
    bool activeOnly = true,
    String? search,
  }) async {
    return await _repository.getAll(
      activeOnly: activeOnly,
      search: search,
    );
  }
}
