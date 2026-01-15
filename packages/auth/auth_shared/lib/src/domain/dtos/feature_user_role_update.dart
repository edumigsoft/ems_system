import '../../authorization/feature_user_role_enum.dart' as feature_role;

/// DTO para atualização de papel de usuário em feature.
///
/// Seguindo entity_patterns.md:
/// - Campo `id` obrigatório
/// - Todos os outros campos opcionais (update parcial)
/// - Inclui `isActive` e `isDeleted` para controle
/// - NÃO inclui `createdAt` ou `updatedAt` (auto-gerenciados)
/// - Getter `hasChanges` para validação
class FeatureUserRoleUpdate {
  final String id;
  final feature_role.FeatureUserRole? role;
  final bool? isActive;
  final bool? isDeleted;

  const FeatureUserRoleUpdate({
    required this.id,
    this.role,
    this.isActive,
    this.isDeleted,
  });

  /// Verifica se há alguma mudança a ser aplicada.
  bool get hasChanges => role != null || isActive != null || isDeleted != null;

  @override
  String toString() =>
      'FeatureUserRoleUpdate(id: $id, role: $role, isActive: $isActive, isDeleted: $isDeleted)';
}
