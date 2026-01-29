import 'package:core_shared/core_shared.dart';
import '../repositories/user_repository.dart';

class ResetPasswordUseCase {
  final UserRepository _repository;

  ResetPasswordUseCase({required UserRepository repository})
    : _repository = repository;

  Future<Result<void>> execute(String id) {
    return _repository.setMustChangePassword(id, true);
  }
}
