import 'package:core_shared/core_shared.dart'
    show Result, UserRole, PaginatedResult;
import '../../../user_shared.dart'
    show UserDetails, UserCreate, UserCreateAdmin, UserUpdate;

/// Repository para operações CRUD de usuários.
///
/// Abstrai o acesso ao banco de dados Drift para a tabela `users`.
abstract class UserRepository {
  /// Busca o perfil do usuário autenticado atual.
  ///
  /// No client, usa o endpoint `/users/me` que identifica o usuário
  /// através do token JWT. No server, requer o ID do usuário atual.
  Future<Result<UserDetails>> getCurrentProfile();

  /// Busca usuário por ID.
  Future<Result<UserDetails>> findById(String id);

  /// Busca usuário por email.
  Future<Result<UserDetails>> findByEmail(String email);

  /// Busca usuário por username.
  Future<Result<UserDetails>> findByUsername(String username);

  /// Lista todos os usuários ativos com paginação.
  ///
  /// Retorna [PaginatedResult] contendo:
  /// - items: Lista de usuários da página atual
  /// - total: Número total de usuários (antes da paginação)
  /// - page: Página atual (calculada a partir do offset)
  /// - limit: Número de itens por página
  Future<Result<PaginatedResult<UserDetails>>> findAll({
    required int limit,
    required int offset,
    String? roleFilter,
    String? search,
  });

  /// Cria um novo usuário.
  Future<Result<UserDetails>> create(UserCreate dto);

  /// Cria um novo usuário administrativamente (sem senha inicial).
  ///
  /// Gera hash aleatório seguro e define mustChangePassword=true.
  /// Usado por owners para criar usuários que receberão email de ativação.
  Future<Result<UserDetails>> createByAdmin(UserCreateAdmin dto);

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

  /// Define se o usuário deve mudar a senha no próximo login.
  ///
  /// Usado quando admin força mudança de senha.
  Future<Result<void>> setMustChangePassword(String userId, bool value);

  /// Verifica se email já existe.
  Future<bool> emailExists(String email);

  /// Verifica se username já existe.
  Future<bool> usernameExists(String username);
}
