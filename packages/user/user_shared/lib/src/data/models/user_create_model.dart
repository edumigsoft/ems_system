import 'package:open_api_shared/open_api_shared.dart';
import '../../domain/dtos/user_create.dart';

/// Model de serialização JSON para [UserCreate].
///
/// Seguindo entity_patterns.md:
/// - Model contém o DTO (campo `dto`)
/// - Métodos `fromJson`, `toJson`, `toDomain`, `fromDomain`
/// - Nenhuma lógica de negócio
@apiModel
@Model(
  name: 'UserCreateModel',
  description: 'Model de serialização JSON para UserCreate',
)
class UserCreateModel {
  @Property(description: 'DTO de criação de usuário')
  final UserCreate dto;

  const UserCreateModel(this.dto);

  /// Deserializa de JSON para Model.
  factory UserCreateModel.fromJson(Map<String, dynamic> json) {
    return UserCreateModel(
      UserCreate(
        name: json['name'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
        password: json['password'] as String,
        phone: json['phone'] as String?,
      ),
    );
  }

  /// Serializa para JSON.
  Map<String, dynamic> toJson() => {
        'name': dto.name,
        'email': dto.email,
        'username': dto.username,
        'password': dto.password,
        if (dto.phone != null) 'phone': dto.phone,
      };

  /// Converte para DTO de domínio.
  UserCreate toDomain() => dto;

  /// Cria model a partir de DTO.
  factory UserCreateModel.fromDomain(UserCreate create) =>
      UserCreateModel(create);
}
