/// Constantes de API para User.
///
/// Centraliza todos os paths de endpoints relacionados a usuários.
class UserConstants {
  UserConstants._();

  // ========== Base Paths ==========
  /// Base path para todas as rotas de usuários
  static const String basePath = '/users';

  // ========== Absolute Paths (para Retrofit/Client) ==========

  // Public endpoints
  /// GET/PUT /users/me - Perfil do usuário atual
  static const String profile = '/users/me';

  // Admin endpoints
  /// GET /users - Lista todos os usuários (paginado)
  static const String listUsers = '/users';

  /// GET /users/:id - Busca usuário por ID (Retrofit format)
  static const String getUserById = '/users/{id}';

  /// POST /users - Cria novo usuário (admin)
  static const String createUser = '/users';

  /// PUT /users/:id - Atualiza usuário (admin, Retrofit format)
  static const String updateUser = '/users/{id}';

  /// DELETE /users/:id - Soft delete de usuário (Retrofit format)
  static const String deleteUser = '/users/{id}';

  // Password management
  /// POST /users/:id/force-password-change - Força mudança de senha (Retrofit)
  static const String forcePasswordChange = '/users/{id}/force-password-change';

  /// POST /users/:id/reset-password - Inicia reset de senha (Retrofit)
  static const String resetPassword = '/users/{id}/reset-password';

  // ========== Relative Paths (para Shelf Router) ==========

  /// GET/PUT /me - Perfil (relativo)
  static const String profilePath = '/me';

  /// GET / - Lista usuários (relativo)
  static const String listUsersPath = '/';

  /// GET/PUT/DELETE `/<id>` - Operações por ID (relativo, Shelf format)
  static const String userByIdPath = '/<id>';

  /// POST `/<id>/force-password-change` (relativo, Shelf)
  static const String forcePasswordChangePath = '/<id>/force-password-change';

  /// POST `/<id>/reset-password` (relativo, Shelf)
  static const String resetPasswordPath = '/<id>/reset-password';

  // ========== Helpers ==========

  /// Retorna /users/{id} (formato Retrofit)
  static String userByIdRetrofit(String id) => '/users/$id';

  /// Retorna /users/{id}/force-password-change
  static String forcePasswordChangeRetrofit(String id) =>
      '/users/$id/force-password-change';

  /// Retorna /users/{id}/reset-password
  static String resetPasswordRetrofit(String id) => '/users/$id/reset-password';
}
