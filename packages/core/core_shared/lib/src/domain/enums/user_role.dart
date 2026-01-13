/// Roles globais do usuário no sistema.
///
/// Define o nível de acesso base do usuário.
/// Permissões específicas por recurso são tratadas separadamente.
enum UserRole {
  /// Acesso total ao sistema
  admin,

  /// Acesso padrão
  user,

  /// Acesso limitado (não autenticado ou conta pendente)
  guest
  ;

  /// Verifica se esta role tem privilégios de administrador.
  bool get isAdmin => this == UserRole.admin;

  /// Verifica se esta role tem acesso autenticado (não é guest).
  bool get isAuthenticated => this != UserRole.guest;
}
