import 'package:core_shared/core_shared.dart';
import '../repositories/user_repository.dart';
import '../entities/user_details.dart';

class GetProfileUseCase {
  final UserRepository _repository;

  GetProfileUseCase({required UserRepository repository})
    : _repository = repository;

  Future<Result<UserDetails>> execute(String currentUserId) {
    return _repository.findById(currentUserId);
  }
}
