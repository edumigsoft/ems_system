/// Roles globais do usuário no sistema.
///
/// Define o nível de acesso base do usuário em todo o sistema.
/// Permissões específicas por feature são tratadas via [FeatureUserRole].
///
/// A hierarquia segue níveis numéricos (4 > 3 > 2 > 1), permitindo
/// comparações diretas usando operadores (>=, >, <=, <).
enum UserRole {
  /// **Owner - Acesso Total e Irrestrito**
  ///
  /// Tem acesso total e irrestrito ao sistema.
  ///
  /// **Permissões:**
  /// - Pode gerenciar todos os usuários, configurações e recursos
  /// - Pode sobrepor qualquer restrição de outros papéis
  /// - Pode excluir ou alterar contas de outros owners (se aplicável)
  /// - Bypass automático em verificações de FeatureUserRole
  ///
  /// **Exemplo:** Fundador ou superadministrador da plataforma
  owner(4),

  /// **Admin - Amplas Permissões de Gerenciamento**
  ///
  /// Tem amplas permissões de gerenciamento no sistema.
  ///
  /// **Permissões:**
  /// - Pode gerenciar usuários, configurações e recursos
  /// - Pode conceder ou revogar papéis a outros usuários (exceto owner)
  /// - Bypass automático em verificações de FeatureUserRole
  ///
  /// **Restrições:**
  /// - NÃO pode excluir ou alterar contas de owners
  ///
  /// **Exemplo:** Administrador do sistema
  admin(3),

  /// **Manager - Gerenciamento Limitado**
  ///
  /// Tem permissões de gerenciamento limitado.
  ///
  /// **Permissões:**
  /// - Pode gerenciar recursos e usuários dentro de seu escopo
  ///   (ex: equipe, departamento)
  /// - Pode criar e editar conteúdo em áreas permitidas
  ///
  /// **Restrições:**
  /// - NÃO pode alterar papéis de admin ou owner
  /// - NÃO pode excluir ou alterar dados de outros managers/admins
  /// - Sujeito a verificações de FeatureUserRole (sem bypass)
  ///
  /// **Exemplo:** Gerente de equipe ou projeto
  manager(2),

  /// **User - Usuário Comum**
  ///
  /// Usuário padrão do sistema.
  ///
  /// **Permissões:**
  /// - Pode acessar e modificar apenas seus próprios dados
  /// - Pode acessar recursos compartilhados conforme permissões
  ///
  /// **Restrições:**
  /// - NÃO pode gerenciar outros usuários ou configurações
  /// - Sujeito a verificações de FeatureUserRole (sem bypass)
  ///
  /// **Exemplo:** Colaborador ou membro comum
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
