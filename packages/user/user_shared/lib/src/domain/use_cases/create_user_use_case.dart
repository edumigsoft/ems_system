import 'package:core_shared/core_shared.dart';
import '../repositories/user_repository.dart';
import '../entities/user_details.dart';
import '../dtos/user_create_admin.dart';

class CreateUserUseCase {
  final UserRepository _repository;

  CreateUserUseCase({required UserRepository repository})
    : _repository = repository;

  Future<Result<UserDetails>> execute(UserCreateAdmin dto) {
    return _repository.createByAdmin(dto);
  }
}
