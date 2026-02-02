import 'package:core_shared/core_shared.dart';
import '../repositories/user_repository.dart';
import '../entities/user_details.dart';
import '../dtos/user_update.dart';

class UpdateUserUseCase {
  final UserRepository _repository;

  UpdateUserUseCase({required UserRepository repository})
    : _repository = repository;

  Future<Result<UserDetails>> execute(String id, UserUpdate dto) {
    return _repository.update(id, dto);
  }
}
