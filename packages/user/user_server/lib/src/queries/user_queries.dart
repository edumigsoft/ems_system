import 'package:drift/drift.dart';
import 'package:core_shared/core_shared.dart' show UserRole;
import 'package:user_shared/user_shared.dart'
    show UserDetails, UserCreate, UserCreateAdmin, UserUpdate;
import '../database/tables/users_table.dart';
import '../database/user_database.dart';

part 'user_queries.g.dart';

@DriftAccessor(tables: [Users])
class UserQueries extends DatabaseAccessor<UserDatabase>
    with _$UserQueriesMixin {
  UserQueries(super.db);

  /// Busca usuário por ID.
  Future<UserDetails?> getById(String id) async {
    final result = await (select(
      users,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return result;
  }

  /// Busca usuário por email.
  Future<UserDetails?> getByEmail(String email) async {
    final result = await (select(
      users,
    )..where((t) => t.email.equals(email))).getSingleOrNull();
    return result;
  }

  /// Busca usuário por username.
  Future<UserDetails?> getByUsername(String username) async {
    final result = await (select(
      users,
    )..where((t) => t.username.equals(username))).getSingleOrNull();
    return result;
  }

  /// Lista todos os usuários com filtros opcionais.
  Future<List<UserDetails>> getAll({
    required int limit,
    required int offset,
    String? roleFilter,
    String? search,
  }) async {
    final query = select(users);

    // Aplicar filtro de role
    if (roleFilter != null) {
      try {
        final roleEnum = UserRole.values.byName(roleFilter);
        query.where((t) => t.role.equals(roleEnum.name));
      } catch (_) {
        // Role inválida, retorna vazio
        return [];
      }
    }

    // Aplicar filtro de busca
    if (search != null && search.isNotEmpty) {
      query.where(
        (t) =>
            t.name.contains(search) |
            t.email.contains(search) |
            t.username.contains(search),
      );
    }

    // Aplicar paginação
    query.limit(limit, offset: offset);

    return await query.get();
  }

  /// Conta o total de usuários com filtros opcionais.
  Future<int> getTotalCount({
    String? roleFilter,
    String? search,
  }) async {
    final query = selectOnly(users);

    // Aplicar filtro de role
    if (roleFilter != null) {
      try {
        final roleEnum = UserRole.values.byName(roleFilter);
        query.where(users.role.equals(roleEnum.name));
      } catch (_) {
        // Role inválida, retorna 0
        return 0;
      }
    }

    // Aplicar filtro de busca
    if (search != null && search.isNotEmpty) {
      query.where(
        users.name.contains(search) |
            users.email.contains(search) |
            users.username.contains(search),
      );
    }

    query.addColumns([users.id.count()]);

    final result = await query.getSingle();
    return result.read(users.id.count()) ?? 0;
  }

  /// Insere um novo usuário (registro normal).
  Future<UserDetails?> insertUser(UserCreate dto) async {
    final companion = UsersCompanion.insert(
      email: dto.email,
      name: dto.name,
      username: dto.username,
    );

    final row = await into(users).insertReturning(companion);
    return row;
  }

  /// Insere um novo usuário criado por admin.
  Future<UserDetails?> insertUserByAdmin(UserCreateAdmin dto) async {
    final companion = UsersCompanion.insert(
      email: dto.email,
      name: dto.name,
      username: dto.username,
      role: Value(dto.role),
      phone: Value(dto.phone),
      mustChangePassword: const Value(true),
    );

    final row = await into(users).insertReturning(companion);
    return row;
  }

  /// Atualiza um usuário (campos editáveis pelo próprio usuário).
  Future<UserDetails?> updateUser(String id, UserUpdate dto) async {
    final companion = UsersCompanion(
      name: dto.name != null ? Value(dto.name!) : const Value.absent(),
      avatarUrl: dto.avatarUrl != null
          ? Value(dto.avatarUrl)
          : const Value.absent(),
      phone: dto.phone != null ? Value(dto.phone) : const Value.absent(),
    );

    final query = update(users)..where((t) => t.id.equals(id));
    final rows = await query.writeReturning(companion);

    return rows.isEmpty ? null : rows.first;
  }

  /// Atualiza campos admin-only de um usuário.
  Future<UserDetails?> updateUserByAdmin(
    String id, {
    UserRole? role,
    bool? emailVerified,
    bool? isActive,
  }) async {
    final companion = UsersCompanion(
      role: role != null ? Value(role) : const Value.absent(),
      emailVerified: emailVerified != null
          ? Value(emailVerified)
          : const Value.absent(),
      isActive: isActive != null ? Value(isActive) : const Value.absent(),
    );

    final query = update(users)..where((t) => t.id.equals(id));
    final rows = await query.writeReturning(companion);

    return rows.isEmpty ? null : rows.first;
  }

  /// Soft delete de um usuário.
  Future<void> deleteUser(String id) async {
    await (update(users)..where((t) => t.id.equals(id))).write(
      const UsersCompanion(isDeleted: Value(true)),
    );
  }

  /// Define se o usuário deve mudar a senha no próximo login.
  Future<void> setMustChangePassword(String id, bool value) async {
    await (update(users)..where((t) => t.id.equals(id))).write(
      UsersCompanion(mustChangePassword: Value(value)),
    );
  }

  /// Verifica se um email já existe.
  Future<bool> emailExists(String email) async {
    final result = await (select(
      users,
    )..where((t) => t.email.equals(email))).getSingleOrNull();
    return result != null;
  }

  /// Verifica se um username já existe.
  Future<bool> usernameExists(String username) async {
    final result = await (select(
      users,
    )..where((t) => t.username.equals(username))).getSingleOrNull();
    return result != null;
  }
}
