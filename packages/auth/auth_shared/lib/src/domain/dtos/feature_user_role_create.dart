import '../../authorization/feature_user_role_enum.dart' as feature_role;

/// DTO para criação de papel de usuário em feature.
///
/// Seguindo entity_patterns.md:
/// - Apenas campos necessários para criação
/// - SEM id (gerado pelo DB)
/// - SEM metadados (createdAt, updatedAt, etc.)
/// - Validação de negócio através de getter isValid
class FeatureUserRoleCreate {
  final String userId;
  final String featureId;
  final feature_role.FeatureUserRole role;

  const FeatureUserRoleCreate({
    required this.userId,
    required this.featureId,
    required this.role,
  });

  /// Valida se os dados estão corretos para criação.
  bool get isValid => userId.isNotEmpty && featureId.isNotEmpty;

  @override
  String toString() =>
      'FeatureUserRoleCreate(userId: $userId, featureId: $featureId, role: $role)';
}
