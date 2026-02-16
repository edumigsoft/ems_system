import '../../domain/dtos/feature_user_role_create.dart';
import '../../authorization/feature_user_role_enum.dart' as feature_role;

/// Model de serialização para FeatureUserRoleCreate.
///
/// Responsável exclusivamente por serialização/deserialização JSON.
/// Converte entre snake_case (API/DB) e camelCase (Dart).
class FeatureUserRoleCreateModel {
  final FeatureUserRoleCreate dto;

  FeatureUserRoleCreateModel(this.dto);

  factory FeatureUserRoleCreateModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String;
    final role = feature_role.FeatureUserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => feature_role.FeatureUserRole.viewer,
    );

    return FeatureUserRoleCreateModel(
      FeatureUserRoleCreate(
        userId: json['user_id'] as String,
        featureId: json['feature_id'] as String,
        role: role,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': dto.userId,
    'feature_id': dto.featureId,
    'role': dto.role.name,
  };

  FeatureUserRoleCreate toDomain() => dto;

  factory FeatureUserRoleCreateModel.fromDomain(FeatureUserRoleCreate create) =>
      FeatureUserRoleCreateModel(create);
}
