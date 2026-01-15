import '../../domain/entities/feature_user_role_details.dart';
import '../../authorization/feature_user_role_enum.dart' as feature_role;

/// Model de serialização para FeatureUserRoleDetails.
///
/// Responsável exclusivamente por serialização/deserialização JSON.
/// Converte entre snake_case (API/DB) e camelCase (Dart).
class FeatureUserRoleDetailsModel {
  final FeatureUserRoleDetails entity;

  FeatureUserRoleDetailsModel(this.entity);

  factory FeatureUserRoleDetailsModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String;
    final role = feature_role.FeatureUserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => feature_role.FeatureUserRole.viewer,
    );

    return FeatureUserRoleDetailsModel(
      FeatureUserRoleDetails.create(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        isDeleted: json['is_deleted'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        userId: json['user_id'] as String,
        featureId: json['feature_id'] as String,
        role: role,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': entity.id,
        'created_at': entity.createdAt.toIso8601String(),
        'updated_at': entity.updatedAt.toIso8601String(),
        'is_deleted': entity.isDeleted,
        'is_active': entity.isActive,
        'user_id': entity.userId,
        'feature_id': entity.featureId,
        'role': entity.role.name,
      };

  FeatureUserRoleDetails toDomain() => entity;

  factory FeatureUserRoleDetailsModel.fromDomain(FeatureUserRoleDetails details) =>
      FeatureUserRoleDetailsModel(details);
}
