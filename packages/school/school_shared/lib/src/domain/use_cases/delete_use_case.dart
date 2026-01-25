import 'package:core_shared/core_shared.dart';
import '../repositories/school_repository.dart';

class DeleteUseCase {
  final SchoolRepository _repository;

  DeleteUseCase({required SchoolRepository repository})
    : _repository = repository;

  Future<Result<Unit>> execute(String id) async {
    return await _repository.delete(id);
  }
}
