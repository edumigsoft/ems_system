import 'package:core_shared/core_shared.dart';
import '../repositories/tag_repository.dart';

/// Use case for soft deleting a tag.
///
/// This sets the isDeleted flag to true without removing the tag from the database.
class DeleteTagUseCase {
  final TagRepository _repository;

  /// Creates a DeleteTagUseCase instance.
  const DeleteTagUseCase(this._repository);

  /// Executes the use case to soft delete a tag.
  ///
  /// Returns [Success] with void or [Failure] with error.
  Future<Result<void>> call(String id) async {
    return await _repository.delete(id);
  }
}
