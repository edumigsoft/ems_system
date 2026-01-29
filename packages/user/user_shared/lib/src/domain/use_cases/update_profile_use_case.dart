import 'package:core_shared/core_shared.dart';
import '../repositories/user_repository.dart';
import '../entities/user_details.dart';
import '../dtos/user_update.dart';

class UpdateProfileUseCase {
  final UserRepository _repository;

  UpdateProfileUseCase({required UserRepository repository})
    : _repository = repository;

  Future<Result<UserDetails>> execute(
    String currentUserId,
    UserUpdate dto,
  ) {
    return _repository.update(currentUserId, dto);
  }
}
