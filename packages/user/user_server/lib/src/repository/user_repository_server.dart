import 'package:core_shared/core_shared.dart'
    show Failure, StorageException, Result, UserRole, Success, PaginatedResult;
import 'package:user_shared/user_shared.dart'
    show UserDetails, UserCreate, UserCreateAdmin, UserUpdate, UserRepository;

import '../queries/user_queries.dart';

class UserRepositoryServer implements UserRepository {
  final UserQueries _queries;

  const UserRepositoryServer(this._queries);

  @override
  Future<Result<UserDetails>> getCurrentProfile() async {
    // No servidor, não há conceito de "usuário atual" pois não há sessão.
    // Use findById() com o ID do usuário obtido do token JWT.
    return Failure(
      StorageException(
        'getCurrentProfile() not applicable on server. Use findById() instead.',
      ),
    );
  }

  @override
  Future<Result<UserDetails>> findById(String id) async {
    try {
      final user = await _queries.getById(id);
      if (user == null) {
        return Failure(StorageException('User not found'));
      }
      return Success(user);
    } catch (e, s) {
      return Failure(StorageException('Error finding user', stackTrace: s));
    }
  }

  @override
  Future<Result<UserDetails>> findByEmail(String email) async {
    try {
      final user = await _queries.getByEmail(email);
      if (user == null) {
        return Failure(StorageException('User not found'));
      }
      return Success(user);
    } catch (e, s) {
      return Failure(
        StorageException('Error finding user by email', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<UserDetails>> findByUsername(String username) async {
    try {
      final user = await _queries.getByUsername(username);
      if (user == null) {
        return Failure(StorageException('User not found'));
      }
      return Success(user);
    } catch (e, s) {
      return Failure(
        StorageException('Error finding user by username', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<PaginatedResult<UserDetails>>> findAll({
    required int limit,
    required int offset,
    String? roleFilter,
    String? search,
  }) async {
    try {
      // Buscar items da página atual
      final items = await _queries.getAll(
        limit: limit,
        offset: offset,
        roleFilter: roleFilter,
        search: search,
      );

      // Buscar total count
      final totalCount = await _queries.getTotalCount(
        roleFilter: roleFilter,
        search: search,
      );

      return Success(
        PaginatedResult.fromOffset(
          items: items,
          total: totalCount,
          offset: offset,
          limit: limit,
        ),
      );
    } catch (e, s) {
      return Failure(StorageException('Error listing users', stackTrace: s));
    }
  }

  @override
  Future<Result<UserDetails>> create(UserCreate dto) async {
    try {
      final user = await _queries.insertUser(dto);
      if (user == null) {
        return Failure(StorageException('Error creating user'));
      }
      return Success(user);
    } catch (e, s) {
      return Failure(StorageException('Error creating user', stackTrace: s));
    }
  }

  @override
  Future<Result<UserDetails>> createByAdmin(UserCreateAdmin dto) async {
    try {
      final user = await _queries.insertUserByAdmin(dto);
      if (user == null) {
        return Failure(StorageException('Error creating user'));
      }
      return Success(user);
    } catch (e, s) {
      return Failure(StorageException('Error creating user', stackTrace: s));
    }
  }

  @override
  Future<Result<UserDetails>> update(String id, UserUpdate dto) async {
    try {
      final user = await _queries.updateUser(id, dto);
      if (user == null) {
        return Failure(StorageException('User not found'));
      }
      return Success(user);
    } catch (e, s) {
      return Failure(StorageException('Error updating user', stackTrace: s));
    }
  }

  @override
  Future<Result<UserDetails>> updateByAdmin(
    String id, {
    UserRole? role,
    bool? emailVerified,
    bool? isActive,
  }) async {
    try {
      final user = await _queries.updateUserByAdmin(
        id,
        role: role,
        emailVerified: emailVerified,
        isActive: isActive,
      );
      if (user == null) {
        return Failure(StorageException('User not found'));
      }
      return Success(user);
    } catch (e, s) {
      return Failure(
        StorageException('Error updating user by admin', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<void>> softDelete(String id) async {
    try {
      await _queries.deleteUser(id);
      return Success(null);
    } catch (e, s) {
      return Failure(StorageException('Error deleting user', stackTrace: s));
    }
  }

  @override
  Future<Result<void>> setMustChangePassword(String userId, bool value) async {
    try {
      await _queries.setMustChangePassword(userId, value);
      return Success(null);
    } catch (e, s) {
      return Failure(
        StorageException('Error setting mustChangePassword', stackTrace: s),
      );
    }
  }

  @override
  Future<bool> emailExists(String email) async {
    return await _queries.emailExists(email);
  }

  @override
  Future<bool> usernameExists(String username) async {
    return await _queries.usernameExists(username);
  }
}
