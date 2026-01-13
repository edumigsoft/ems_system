import 'package:core_shared/core_shared.dart';
import 'package:user_shared/user_shared.dart';

/// Repository para operações CRUD de usuários.
///
/// Abstrai o acesso ao banco de dados Drift para a tabela `users`.
abstract class UserRepository {
  /// Busca usuário por ID.
  Future<Result<UserDetails>> findById(String id);

  /// Busca usuário por email.
  Future<Result<UserDetails>> findByEmail(String email);

  /// Busca usuário por username.
  Future<Result<UserDetails>> findByUsername(String username);

  /// Lista todos os usuários ativos.
  Future<Result<List<UserDetails>>> findAll({
    int? limit,
    int? offset,
    String? roleFilter,
    String? search,
  });

  /// Cria um novo usuário.
  Future<Result<UserDetails>> create(UserCreate dto);

  /// Atualiza um usuário existente.
  Future<Result<UserDetails>> update(String id, UserUpdate dto);

  /// Atualiza campos admin-only (role, emailVerified, isActive).
  Future<Result<UserDetails>> updateByAdmin(
    String id, {
    UserRole? role,
    bool? emailVerified,
    bool? isActive,
  });

  /// Soft delete de usuário.
  Future<Result<void>> softDelete(String id);

  /// Verifica se email já existe.
  Future<bool> emailExists(String email);

  /// Verifica se username já existe.
  Future<bool> usernameExists(String username);
}
