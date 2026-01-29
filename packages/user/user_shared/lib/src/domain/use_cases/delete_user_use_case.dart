import 'package:core_shared/core_shared.dart';
import '../repositories/user_repository.dart';

class DeleteUserUseCase {
  final UserRepository _repository;

  DeleteUserUseCase({required UserRepository repository})
    : _repository = repository;

  Future<Result<void>> execute(String id) {
    return _repository.softDelete(id);
  }
}
