/// Roles globais do usuário no sistema.
///
/// Define o nível de acesso base do usuário.
/// Permissões específicas por recurso são tratadas separadamente.
enum UserRole {
  /// Acesso supremo (pode deletar usuários e admins)
  owner(3),

  /// Acesso total ao sistema (exceto deleção de usuários)
  admin(2),

  /// Acesso padrão
  user(1)
  ;

  final int level;
  const UserRole(this.level);

  bool operator >=(UserRole other) => level >= other.level;
  bool operator >(UserRole other) => level > other.level;
  bool operator <=(UserRole other) => level <= other.level;
  bool operator <(UserRole other) => level < other.level;

  /// Verifica se esta role tem privilégios de administrador (ou superior).
  bool get isAdmin => this >= UserRole.admin;

  /// Verifica se esta role é owner.
  bool get isOwner => this == UserRole.owner;
}
