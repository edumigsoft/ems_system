import 'feature_user_role_enum.dart' as feature_role;

/// Entidade pura representando o papel de um usuário em uma feature específica.
///
/// Esta é uma entidade de domínio pura sem metadados de persistência (sem id,
/// sem timestamps). Seguindo as regras de entity_patterns.md:
/// - Apenas campos essenciais ao negócio
/// - Lógica de domínio através de getters e métodos
/// - SEM id, SEM toJson/fromJson
/// - SEM dependências externas
class FeatureUserRole {
  final String userId;
  final String featureId;
  final feature_role.FeatureUserRole role;

  const FeatureUserRole({
    required this.userId,
    required this.featureId,
    required this.role,
  });

  /// Verifica se o usuário pode gerenciar membros nesta feature.
  bool canManageMembers() => role.canManage;

  /// Verifica se o usuário pode visualizar conteúdo nesta feature.
  bool canViewContent() =>
      role.canContribute || role == feature_role.FeatureUserRole.viewer;

  FeatureUserRole copyWith({
    String? userId,
    String? featureId,
    feature_role.FeatureUserRole? role,
  }) {
    return FeatureUserRole(
      userId: userId ?? this.userId,
      featureId: featureId ?? this.featureId,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeatureUserRole &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          featureId == other.featureId &&
          role == other.role;

  @override
  int get hashCode => Object.hash(userId, featureId, role);

  @override
  String toString() =>
      'FeatureUserRole(userId: $userId, featureId: $featureId, role: $role)';
}

