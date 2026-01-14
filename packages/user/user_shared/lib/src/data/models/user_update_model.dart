import 'package:open_api_shared/open_api_shared.dart';
import '../../domain/dtos/user_update.dart';

/// Model de serialização JSON para [UserUpdate].
///
/// Seguindo entity_patterns.md:
/// - Model contém o DTO (campo `dto`)
/// - Métodos `fromJson`, `toJson`, `toDomain`, `fromDomain`
/// - Nenhuma lógica de negócio
@apiModel
@Model(
  name: 'UserUpdateModel',
  description: 'Model de serialização JSON para UserUpdate',
)
class UserUpdateModel {
  @Property(description: 'DTO de atualização de usuário')
  final UserUpdate dto;

  const UserUpdateModel(this.dto);

  /// Deserializa de JSON para Model.
  factory UserUpdateModel.fromJson(Map<String, dynamic> json) {
    return UserUpdateModel(
      UserUpdate(
        id: json['id'] as String,
        name: json['name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        phone: json['phone'] as String?,
        isActive: json['is_active'] as bool?,
        isDeleted: json['is_deleted'] as bool?,
      ),
    );
  }

  /// Serializa para JSON.
  Map<String, dynamic> toJson() => {
        'id': dto.id,
        if (dto.name != null) 'name': dto.name,
        if (dto.avatarUrl != null) 'avatar_url': dto.avatarUrl,
        if (dto.phone != null) 'phone': dto.phone,
        if (dto.isActive != null) 'is_active': dto.isActive,
        if (dto.isDeleted != null) 'is_deleted': dto.isDeleted,
      };

  /// Converte para DTO de domínio.
  UserUpdate toDomain() => dto;

  /// Cria model a partir de DTO.
  factory UserUpdateModel.fromDomain(UserUpdate update) =>
      UserUpdateModel(update);
}
