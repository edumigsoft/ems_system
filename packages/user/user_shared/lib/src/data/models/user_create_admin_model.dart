import 'package:core_shared/core_shared.dart';
import 'package:open_api_shared/open_api_shared.dart';
import '../../domain/dtos/user_create_admin.dart';

/// Model de serialização JSON para [UserCreateAdmin].
///
/// Seguindo entity_patterns.md:
/// - Model contém o DTO (campo `dto`)
/// - Métodos `fromJson`, `toJson`, `toDomain`, `fromDomain`
/// - Nenhuma lógica de negócio
@apiModel
@Model(
  name: 'UserCreateAdminModel',
  description: 'Model de serialização JSON para UserCreateAdmin',
)
class UserCreateAdminModel {
  @Property(description: 'DTO de criação administrativa de usuário')
  final UserCreateAdmin dto;

  const UserCreateAdminModel(this.dto);

  /// Deserializa de JSON para Model.
  factory UserCreateAdminModel.fromJson(Map<String, dynamic> json) {
    // Parse role from string to enum
    UserRole role = UserRole.user; // default
    if (json['role'] != null) {
      try {
        role = UserRole.values.byName(json['role'] as String);
      } catch (_) {
        // Se role inválido, usa default
        role = UserRole.user;
      }
    }

    return UserCreateAdminModel(
      UserCreateAdmin(
        name: json['name'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
        role: role,
        phone: json['phone'] as String?,
      ),
    );
  }

  /// Serializa para JSON.
  Map<String, dynamic> toJson() => {
    'name': dto.name,
    'email': dto.email,
    'username': dto.username,
    'role': dto.role.name,
    if (dto.phone != null) 'phone': dto.phone,
  };

  /// Converte para DTO de domínio.
  UserCreateAdmin toDomain() => dto;

  /// Cria model a partir de DTO.
  factory UserCreateAdminModel.fromDomain(UserCreateAdmin create) =>
      UserCreateAdminModel(create);
}
