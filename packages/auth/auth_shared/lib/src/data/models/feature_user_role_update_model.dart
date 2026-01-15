import '../../domain/dtos/feature_user_role_update.dart';
import '../../authorization/feature_user_role_enum.dart' as feature_role;

/// Model de serialização para FeatureUserRoleUpdate.
///
/// Responsável exclusivamente por serialização/deserialização JSON.
/// Converte entre snake_case (API/DB) e camelCase (Dart).
class FeatureUserRoleUpdateModel {
  final FeatureUserRoleUpdate dto;

  FeatureUserRoleUpdateModel(this.dto);

  factory FeatureUserRoleUpdateModel.fromJson(Map<String, dynamic> json) {
    feature_role.FeatureUserRole? role;
    if (json['role'] != null) {
      final roleStr = json['role'] as String;
      role = feature_role.FeatureUserRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => feature_role.FeatureUserRole.viewer,
      );
    }

    return FeatureUserRoleUpdateModel(
      FeatureUserRoleUpdate(
        id: json['id'] as String,
        role: role,
        isActive: json['is_active'] as bool?,
        isDeleted: json['is_deleted'] as bool?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': dto.id,
    };

    if (dto.role != null) {
      json['role'] = dto.role!.name;
    }
    if (dto.isActive != null) {
      json['is_active'] = dto.isActive;
    }
    if (dto.isDeleted != null) {
      json['is_deleted'] = dto.isDeleted;
    }

    return json;
  }

  FeatureUserRoleUpdate toDomain() => dto;

  factory FeatureUserRoleUpdateModel.fromDomain(FeatureUserRoleUpdate update) =>
      FeatureUserRoleUpdateModel(update);
}
