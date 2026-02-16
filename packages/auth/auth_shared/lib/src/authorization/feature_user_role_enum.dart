/// Papéis específicos por contexto de feature.
///
/// Define o nível de acesso de um usuário dentro de uma feature específica
/// (projeto, empresa, workspace, etc.).
///
/// **IMPORTANTE:** Usuários com [UserRole.admin] ou [UserRole.owner] fazem
/// BYPASS automático das verificações de FeatureUserRole e têm acesso total
/// a todas as features.
///
/// A hierarquia segue níveis numéricos (5 > 4 > 3 > 2 > 1), permitindo
/// comparações diretas usando operadores (>=, >, <=, <).
enum FeatureUserRole {
  /// **Owner - Controle Total no Contexto da Feature**
  ///
  /// Tem controle total sobre o contexto da feature.
  ///
  /// **Permissões:**
  /// - Pode editar, excluir e gerenciar membros e configurações
  /// - Pode conceder ou revogar papéis dentro do contexto
  /// - Tem precedência sobre todos os outros papéis no contexto
  /// - Pode transferir ownership para outro usuário
  ///
  /// **Exemplo:** Dono de um projeto ou workspace
  owner(5),

  /// **Admin - Gerenciamento no Contexto**
  ///
  /// Tem permissões de gerenciamento dentro do contexto.
  ///
  /// **Permissões:**
  /// - Pode editar, excluir e gerenciar membros e configurações
  /// - Pode conceder ou revogar papéis (exceto owner)
  /// - Pode gerenciar conteúdo e recursos
  ///
  /// **Restrições:**
  /// - NÃO pode alterar papéis de owner
  /// - NÃO pode transferir ownership
  ///
  /// **Exemplo:** Administrador de um projeto
  admin(4),

  /// **Manager - Gerenciamento Limitado**
  ///
  /// Pode gerenciar recursos e membros com permissões limitadas.
  ///
  /// **Permissões:**
  /// - Pode editar conteúdo e atribuir tarefas
  /// - Pode gerenciar recursos dentro do escopo permitido
  /// - Pode visualizar informações de membros
  ///
  /// **Restrições:**
  /// - NÃO pode excluir membros ou alterar configurações críticas
  /// - NÃO pode alterar papéis de admin ou owner
  /// - Permissões limitadas de gerenciamento
  ///
  /// **Exemplo:** Coordenador de tarefas ou gerente de área
  manager(3),

  /// **Member - Leitura e Contribuição**
  ///
  /// Pode ler e contribuir com conteúdo.
  ///
  /// **Permissões:**
  /// - Pode criar e editar tarefas ou itens
  /// - Pode comentar e colaborar
  /// - Pode acessar conteúdo compartilhado
  ///
  /// **Restrições:**
  /// - NÃO pode gerenciar membros ou configurações
  /// - NÃO pode excluir recursos importantes
  /// - Acesso limitado a edição de conteúdo próprio
  ///
  /// **Exemplo:** Colaborador do projeto ou membro da equipe
  member(2),

  /// **Viewer - Apenas Visualização**
  ///
  /// Apenas visualiza o conteúdo do contexto.
  ///
  /// **Permissões:**
  /// - Pode visualizar conteúdo e informações
  /// - Pode acessar relatórios e dashboards (read-only)
  ///
  /// **Restrições:**
  /// - NÃO pode editar, excluir ou gerenciar nada
  /// - NÃO pode criar ou modificar conteúdo
  /// - Acesso somente leitura
  ///
  /// **Exemplo:** Observador, stakeholder ou auditor
  viewer(1)
  ;

  final int level;
  const FeatureUserRole(this.level);

  bool operator >=(FeatureUserRole other) => level >= other.level;
  bool operator >(FeatureUserRole other) => level > other.level;
  bool operator <=(FeatureUserRole other) => level <= other.level;
  bool operator <(FeatureUserRole other) => level < other.level;

  /// Verifica se esta role é owner.
  bool get isOwner => this == FeatureUserRole.owner;

  /// Verifica se esta role tem privilégios de administrador (ou superior).
  bool get isAdmin => this >= FeatureUserRole.admin;

  /// Verifica se esta role pode gerenciar recursos (ou superior).
  bool get canManage => this >= FeatureUserRole.manager;

  /// Verifica se esta role pode contribuir com conteúdo (ou superior).
  bool get canContribute => this >= FeatureUserRole.member;
}
