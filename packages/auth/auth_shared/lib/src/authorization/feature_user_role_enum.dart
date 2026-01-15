/// Papéis específicos por contexto de feature.
///
/// Define o nível de acesso de um usuário dentro de uma feature específica
/// (projeto, empresa, etc.). Hierarquia: owner > admin > manager > member > viewer
enum FeatureUserRole {
  /// Controle total sobre o contexto da feature
  owner(5),

  /// Permissões de gerenciamento (exceto funções de owner)
  admin(4),

  /// Pode gerenciar recursos e membros com permissões limitadas
  manager(3),

  /// Pode ler e contribuir com conteúdo
  member(2),

  /// Apenas visualiza o conteúdo do contexto
  viewer(1);

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
