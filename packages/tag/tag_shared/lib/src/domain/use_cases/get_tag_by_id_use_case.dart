import 'package:core_shared/core_shared.dart';
import '../entities/tag_details.dart';
import '../repositories/tag_repository.dart';

/// Use case for retrieving a tag by its ID.
class GetTagByIdUseCase {
  final TagRepository _repository;

  /// Creates a GetTagByIdUseCase instance.
  const GetTagByIdUseCase(this._repository);

  /// Executes the use case to retrieve a tag by ID.
  ///
  /// Returns [Success] with [TagDetails] or [Failure] if not found.
  Future<Result<TagDetails>> call(String id) async {
    return await _repository.getById(id);
  }
}
