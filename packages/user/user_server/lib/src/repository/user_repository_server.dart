import 'package:drift/drift.dart';
import 'package:core_shared/core_shared.dart'
    show Failure, StorageException, Result, UserRole, Success;
import 'package:user_shared/user_shared.dart'
    show
        UserDetails,
        UserCreate,
        UserCreateAdmin,
        UserUpdate,
        PaginatedResult,
        UserRepository;

import '../database/user_database.dart';

class UserRepositoryServer implements UserRepository {
  final UserDatabase db;

  UserRepositoryServer(this.db);

  @override
  Future<Result<UserDetails>> findById(String id) async {
    try {
      final result = await (db.select(
        db.users,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (result == null) {
        return Failure(StorageException('User not found'));
      }
      return Success(result);
    } catch (e, s) {
      return Failure(StorageException('Error finding user', stackTrace: s));
    }
  }

  @override
  Future<Result<UserDetails>> findByEmail(String email) async {
    try {
      final result = await (db.select(
        db.users,
      )..where((t) => t.email.equals(email))).getSingleOrNull();

      if (result == null) {
        return Failure(StorageException('User not found'));
      }
      return Success(result);
    } catch (e, s) {
      return Failure(
        StorageException('Error finding user by email', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<UserDetails>> findByUsername(String username) async {
    try {
      final result = await (db.select(
        db.users,
      )..where((t) => t.username.equals(username))).getSingleOrNull();

      if (result == null) {
        return Failure(StorageException('User not found'));
      }
      return Success(result);
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
      // Validar role se fornecida
      UserRole? roleEnum;
      if (roleFilter != null) {
        try {
          roleEnum = UserRole.values.byName(roleFilter);
        } catch (_) {
          // Role inválida, retorna vazio
          return Success(
            PaginatedResult<UserDetails>(
              items: [],
              total: 0,
              page: (offset ~/ limit) + 1,
              limit: limit,
            ),
          );
        }
      }

      // Query base para buscar dados
      final baseQuery = db.select(db.users);

      // Aplicar filtros
      if (roleEnum != null) {
        baseQuery.where((t) => t.role.equals(roleEnum!.name));
      }

      if (search != null && search.isNotEmpty) {
        baseQuery.where(
          (t) =>
              t.name.contains(search) |
              t.email.contains(search) |
              t.username.contains(search),
        );
      }

      // Buscar todos os resultados para contar
      // NOTA: Para otimização futura, considere usar customStatement com COUNT(*)
      final allResults = await baseQuery.get();
      final totalCount = allResults.length;

      // Se total é 0, retorna vazio
      if (totalCount == 0) {
        return Success(
          PaginatedResult<UserDetails>(
            items: [],
            total: 0,
            page: (offset ~/ limit) + 1,
            limit: limit,
          ),
        );
      }

      // Aplicar paginação manualmente nos resultados
      final startIndex = offset;
      final endIndex = (offset + limit).clamp(0, totalCount);
      final items = allResults.sublist(
        startIndex.clamp(0, totalCount),
        endIndex,
      );

      return Success(
        PaginatedResult<UserDetails>(
          items: items,
          total: totalCount,
          page: (offset ~/ limit) + 1,
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
      final companion = UsersCompanion.insert(
        email: dto.email,
        name: dto.name,
        username: dto.username,
      );

      final row = await db.into(db.users).insertReturning(companion);
      return Success(row);
    } catch (e, s) {
      return Failure(StorageException('Error creating user', stackTrace: s));
    }
  }

  @override
  Future<Result<UserDetails>> createByAdmin(UserCreateAdmin dto) async {
    try {
      final companion = UsersCompanion.insert(
        email: dto.email,
        name: dto.name,
        username: dto.username,
        role: Value(dto.role),
        phone: Value(dto.phone),
        mustChangePassword: const Value(true),
      );

      final row = await db.into(db.users).insertReturning(companion);
      return Success(row);
    } catch (e, s) {
      return Failure(StorageException('Error creating user', stackTrace: s));
    }
  }

  @override
  Future<Result<UserDetails>> update(String id, UserUpdate dto) async {
    try {
      final companion = UsersCompanion(
        name: dto.name != null ? Value(dto.name!) : const Value.absent(),
        avatarUrl: dto.avatarUrl != null
            ? Value(dto.avatarUrl)
            : const Value.absent(),
        phone: dto.phone != null ? Value(dto.phone) : const Value.absent(),
      );

      final query = db.update(db.users)..where((t) => t.id.equals(id));
      final rows = await query.writeReturning(companion);

      if (rows.isEmpty) {
        return Failure(StorageException('User not found'));
      }
      return Success(rows.first);
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
      final companion = UsersCompanion(
        role: role != null ? Value(role) : const Value.absent(),
        emailVerified: emailVerified != null
            ? Value(emailVerified)
            : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
      );

      final query = db.update(db.users)..where((t) => t.id.equals(id));
      final rows = await query.writeReturning(companion);

      if (rows.isEmpty) {
        return Failure(StorageException('User not found'));
      }
      return Success(rows.first);
    } catch (e, s) {
      return Failure(
        StorageException('Error updating user by admin', stackTrace: s),
      );
    }
  }

  @override
  Future<Result<void>> softDelete(String id) async {
    try {
      final query = db.update(db.users)..where((t) => t.id.equals(id));
      await query.write(const UsersCompanion(isDeleted: Value(true)));
      return Success(null);
    } catch (e, s) {
      return Failure(StorageException('Error deleting user', stackTrace: s));
    }
  }

  @override
  Future<Result<void>> setMustChangePassword(String userId, bool value) async {
    try {
      final query = db.update(db.users)..where((t) => t.id.equals(userId));
      await query.write(UsersCompanion(mustChangePassword: Value(value)));
      return Success(null);
    } catch (e, s) {
      return Failure(
        StorageException('Error setting mustChangePassword', stackTrace: s),
      );
    }
  }

  @override
  Future<bool> emailExists(String email) async {
    final query = db.select(db.users)..where((t) => t.email.equals(email));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  @override
  Future<bool> usernameExists(String username) async {
    final query = db.select(db.users)
      ..where((t) => t.username.equals(username));
    final result = await query.getSingleOrNull();
    return result != null;
  }
}
