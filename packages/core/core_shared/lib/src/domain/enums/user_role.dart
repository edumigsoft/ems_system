/// Roles globais do usuário no sistema.
///
/// Define o nível de acesso base do usuário.
/// Permissões específicas por recurso são tratadas separadamente.
enum UserRole {
  /// Acesso supremo (pode deletar usuários e admins)
  owner(4),

  /// Acesso total ao sistema (exceto deleção de usuários)
  admin(3),

  /// Acesso de gerenciamento limitado (gerenciar recursos em seu escopo)
  manager(2),

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

  /// Verifica se esta role tem privilégios de gerenciamento (ou superior).
  bool get isManager => this >= UserRole.manager;
}
