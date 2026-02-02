import 'package:core_shared/core_shared.dart';
import '../dtos/tag_create.dart';
import '../entities/tag_details.dart';
import '../repositories/tag_repository.dart';

/// Use case for creating a new tag.
///
/// Delegates to [TagRepository.create] and returns the result directly.
/// Additional business validations can be added here before calling the repository.
class CreateTagUseCase {
  final TagRepository _repository;

  /// Creates a CreateTagUseCase instance.
  const CreateTagUseCase(this._repository);

  /// Executes the use case to create a tag.
  ///
  /// Returns [Success] with created [TagDetails] or [Failure] with error.
  Future<Result<TagDetails>> call(TagCreate data) async {
    // Additional business validations could be added here
    // For now, delegate directly to repository
    return await _repository.create(data);
  }
}
