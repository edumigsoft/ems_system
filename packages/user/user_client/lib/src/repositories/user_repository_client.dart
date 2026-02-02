import 'package:core_client/core_client.dart' show BaseRepositoryLocal, Result;
import 'package:core_shared/core_shared.dart'
    show Failure, Success, PaginatedResult, UserRole, DataException;
import 'package:user_shared/user_shared.dart'
    show
        UserRepository,
        UserDetails,
        UserCreate,
        UserCreateAdmin,
        UserUpdate,
        UserCreateAdminModel,
        UserUpdateModel;

import '../service/user_service.dart';

class UserRepositoryClient extends BaseRepositoryLocal
    implements UserRepository {
  final UserService _service;

  UserRepositoryClient({required UserService service}) : _service = service;

  @override
  Future<Result<UserDetails>> getCurrentProfile() async {
    return executeRequest(
      request: _service.getProfile,
      context: 'fetching current user profile',
      mapper: (model) => model.toDomain(),
    );
  }

  @override
  Future<Result<UserDetails>> findById(String id) async {
    return executeRequest(
      request: () => _service.getUserById(id),
      context: 'fetching user by ID',
      mapper: (model) => model.toDomain(),
    );
  }

  @override
  Future<Result<UserDetails>> findByEmail(String email) async {
    // Usa listUsers com search para encontrar por email
    final result = await executeRequest(
      request: () => _service.listUsers(search: email, limit: 1),
      context: 'fetching user by email',
      mapper: (response) => response,
    );

    return result.flatMap((response) {
      final users = response.data.map((m) => m.toDomain()).toList();
      if (users.isEmpty) {
        return Failure(DataException('User not found'));
      }
      // Verifica se o email é exatamente igual (search pode retornar parciais)
      try {
        final exactMatch = users.firstWhere(
          (u) => u.email.toLowerCase() == email.toLowerCase(),
        );
        return Success(exactMatch);
      } catch (_) {
        return Failure(DataException('User not found'));
      }
    });
  }

  @override
  Future<Result<UserDetails>> findByUsername(String username) async {
    // Usa listUsers com search para encontrar por username
    final result = await executeRequest(
      request: () => _service.listUsers(search: username, limit: 1),
      context: 'fetching user by username',
      mapper: (response) => response,
    );

    return result.flatMap((response) {
      final users = response.data.map((m) => m.toDomain()).toList();
      if (users.isEmpty) {
        return Failure(DataException('User not found'));
      }
      // Verifica se o username é exatamente igual
      try {
        final exactMatch = users.firstWhere(
          (u) => u.username.toLowerCase() == username.toLowerCase(),
        );
        return Success(exactMatch);
      } catch (_) {
        return Failure(DataException('User not found'));
      }
    });
  }

  @override
  Future<Result<PaginatedResult<UserDetails>>> findAll({
    required int limit,
    required int offset,
    String? roleFilter,
    String? search,
  }) async {
    // Converte offset para page (baseado em 1)
    final page = (offset ~/ limit) + 1;

    final result = await executeRequest(
      request: () => _service.listUsers(
        page: page,
        limit: limit,
        role: roleFilter,
        search: search,
      ),
      context: 'listing users',
      mapper: (response) => response,
    );

    return result.map((response) {
      final items = response.data.map((m) => m.toDomain()).toList();
      return PaginatedResult(
        items: items,
        total: response.total,
        page: response.page,
        limit: response.limit,
      );
    });
  }

  @override
  Future<Result<UserDetails>> create(UserCreate dto) async {
    // Não aplicável no client - usuários públicos usam auth/register
    return Failure(
      DataException(
        'Use auth/register endpoint for public user registration',
      ),
    );
  }

  @override
  Future<Result<UserDetails>> createByAdmin(UserCreateAdmin dto) async {
    return executeRequest(
      request: () => _service.createUser(UserCreateAdminModel.fromDomain(dto)),
      context: 'creating user (admin)',
      mapper: (model) => model.toDomain(),
    );
  }

  @override
  Future<Result<UserDetails>> update(String id, UserUpdate dto) async {
    // Assume que se id == 'me' ou current user, usa updateProfile
    // Caso contrário, seria admin update (mas update() é para o próprio usuário)
    return executeRequest(
      request: () => _service.updateProfile(UserUpdateModel.fromDomain(dto)),
      context: 'updating user profile',
      mapper: (model) => model.toDomain(),
    );
  }

  @override
  Future<Result<UserDetails>> updateByAdmin(
    String id, {
    UserRole? role,
    bool? emailVerified,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{};
    if (role != null) data['role'] = role.name;
    if (emailVerified != null) data['emailVerified'] = emailVerified;
    if (isActive != null) data['isActive'] = isActive;

    return executeRequest(
      request: () => _service.updateUserRole(id, data),
      context: 'updating user (admin)',
      mapper: (model) => model.toDomain(),
    );
  }

  @override
  Future<Result<void>> softDelete(String id) async {
    return executeVoidRequest(
      request: () => _service.deactivateUser(id),
      context: 'deactivating user',
    );
  }

  @override
  Future<Result<void>> setMustChangePassword(String userId, bool value) async {
    if (!value) {
      // Não há endpoint para desmarcar mustChangePassword
      return Failure(
        DataException('Cannot unset mustChangePassword from client'),
      );
    }

    return executeVoidRequest(
      request: () => _service.forcePasswordChange(userId),
      context: 'forcing password change',
    );
  }

  @override
  Future<bool> emailExists(String email) async {
    try {
      // Não há endpoint específico, usa listUsers com search
      final result = await _service.listUsers(search: email, limit: 1);
      final users = result.data
          .map((m) => m.toDomain())
          .where((u) => u.email.toLowerCase() == email.toLowerCase());
      return users.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> usernameExists(String username) async {
    try {
      // Não há endpoint específico, usa listUsers com search
      final result = await _service.listUsers(search: username, limit: 1);
      final users = result.data
          .map((m) => m.toDomain())
          .where((u) => u.username.toLowerCase() == username.toLowerCase());
      return users.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
