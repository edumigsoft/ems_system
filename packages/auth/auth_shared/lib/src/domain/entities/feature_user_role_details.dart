import 'package:core_shared/core_shared.dart';
import '../../authorization/feature_user_role.dart';
import '../../authorization/feature_user_role_enum.dart' as feature_role;

/// Papel de usuário em feature com metadados completos de persistência.
///
/// Implementa BaseDetails conforme ADR-0006 para sincronização com
/// DriftTableMixinPostgres. Segue entity_patterns.md:
/// - Implementa BaseDetails
/// - createdAt e updatedAt são DateTime (non-nullable)
/// - Compõe a Entity pura (campo `data`)
/// - Getters de conveniência para campos da Entity
/// - SEM serialização (responsabilidade de *Model)
class FeatureUserRoleDetails implements BaseDetails {
  @override
  final String id;

  @override
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  @override
  final bool isDeleted;

  @override
  final bool isActive;

  final FeatureUserRole data;

  const FeatureUserRoleDetails({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isActive = true,
    required this.data,
  });

  /// Constructor de conveniência que cria a entity composta internamente.
  FeatureUserRoleDetails.create({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isActive = true,
    required String userId,
    required String featureId,
    required feature_role.FeatureUserRole role,
  }) : data = FeatureUserRole(
          userId: userId,
          featureId: featureId,
          role: role,
        );

  // Getters de conveniência para campos da entity
  String get userId => data.userId;
  String get featureId => data.featureId;
  feature_role.FeatureUserRole get role => data.role;

  FeatureUserRoleDetails copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isActive,
    String? userId,
    String? featureId,
    feature_role.FeatureUserRole? role,
  }) {
    return FeatureUserRoleDetails(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isActive: isActive ?? this.isActive,
      data: data.copyWith(
        userId: userId,
        featureId: featureId,
        role: role,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeatureUserRoleDetails &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          data == other.data;

  @override
  int get hashCode => Object.hash(id, data);

  @override
  String toString() =>
      'FeatureUserRoleDetails(id: $id, userId: $userId, featureId: $featureId, role: $role, isActive: $isActive, isDeleted: $isDeleted)';
}
