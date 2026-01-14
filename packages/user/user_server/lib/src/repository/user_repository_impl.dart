import 'package:drift/drift.dart';
import 'package:core_shared/core_shared.dart';
import 'package:user_shared/user_shared.dart';

import '../database/user_database.dart';
import 'user_repository.dart';

// part 'user_repository_impl.g.dart'; // Removido pois não usaramos mais o mixin do accessor

class UserRepositoryImpl implements UserRepository {
  final UserDatabase db;

  UserRepositoryImpl(this.db);

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
  Future<Result<List<UserDetails>>> findAll({
    int? limit,
    int? offset,
    String? roleFilter,
    String? search,
  }) async {
    try {
      var query = db.select(db.users);

      if (roleFilter != null) {
        try {
          // O campo 'role' no banco é UserRole graças ao converter
          final roleEnum = UserRole.values.byName(roleFilter);
          query.where((t) => t.role.equals(roleEnum.name));
        } catch (_) {
          // Se a role não existir no enum, não retorna nada
          return Success([]);
        }
      }

      if (search != null) {
        query.where(
          (t) =>
              t.name.contains(search) |
              t.email.contains(search) |
              t.username.contains(search),
        );
      }

      if (limit != null) {
        query.limit(limit, offset: offset);
      }

      final result = await query.get();
      return Success(result);
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
