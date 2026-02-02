import 'package:core_shared/core_shared.dart';
import '../repositories/user_repository.dart';
import '../entities/user_details.dart';

class GetAllUsersUseCase {
  final UserRepository _repository;

  GetAllUsersUseCase({required UserRepository repository})
    : _repository = repository;

  Future<Result<PaginatedResult<UserDetails>>> execute({
    required int limit,
    required int offset,
    String? search,
    String? roleFilter,
  }) {
    return _repository.findAll(
      limit: limit,
      offset: offset,
      search: search,
      roleFilter: roleFilter,
    );
  }
}
