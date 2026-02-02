import 'package:core_shared/core_shared.dart';
import '../repositories/user_repository.dart';
import '../entities/user_details.dart';

class UpdateUserRoleUseCase {
  final UserRepository _repository;

  UpdateUserRoleUseCase({required UserRepository repository})
    : _repository = repository;

  Future<Result<UserDetails>> execute(String id, UserRole role) {
    return _repository.updateByAdmin(id, role: role);
  }
}
