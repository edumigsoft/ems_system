import 'package:core_shared/core_shared.dart';
import '../dtos/tag_update.dart';
import '../entities/tag_details.dart';
import '../repositories/tag_repository.dart';

/// Use case for updating an existing tag.
class UpdateTagUseCase {
  final TagRepository _repository;

  /// Creates an UpdateTagUseCase instance.
  const UpdateTagUseCase(this._repository);

  /// Executes the use case to update a tag.
  ///
  /// Returns [Success] with updated [TagDetails] or [Failure] with error.
  Future<Result<TagDetails>> call(TagUpdate data) async {
    // Validate that there are changes to apply
    if (!data.hasChanges) {
      return Failure(Exception('No changes to apply'));
    }

    return await _repository.update(data);
  }
}
