import 'package:core_shared/core_shared.dart';
import 'package:open_api_shared/open_api_shared.dart';
import '../../domain/entities/user_details.dart';

/// Model de serialização JSON para [UserDetails].
///
/// Seguindo entity_patterns.md:
/// - Model contém a entity (campo `entity`)
/// - Métodos `fromJson`, `toJson`, `toDomain`, `fromDomain`
/// - SEM dependências de code generation
@apiModel
@Model(
  name: 'UserDetailsModel',
  description: 'Model de serialização JSON para UserDetails',
)
class UserDetailsModel {
  @Property(description: 'Entidade de detalhes do usuário')
  final UserDetails entity;

  const UserDetailsModel(this.entity);

  /// Deserializa de JSON para Model.
  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      UserDetails.create(
        id: json['id'] as String,
        isDeleted: json['is_deleted'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        name: json['name'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
        role: _parseRole(json['role'] as String?),
        emailVerified: json['email_verified'] as bool? ?? false,
        avatarUrl: json['avatar_url'] as String?,
        phone: json['phone'] as String?,
      ),
    );
  }

  /// Serializa para JSON.
  Map<String, dynamic> toJson() => {
    'id': entity.id,
    'is_deleted': entity.isDeleted,
    'is_active': entity.isActive,
    'created_at': entity.createdAt.toIso8601String(),
    'updated_at': entity.updatedAt.toIso8601String(),
    'name': entity.name,
    'email': entity.email,
    'username': entity.username,
    'role': entity.role.name,
    'email_verified': entity.emailVerified,
    'avatar_url': entity.avatarUrl,
    'phone': entity.phone,
  };

  /// Converte para entity de domínio.
  UserDetails toDomain() => entity;

  /// Cria model a partir de entity.
  factory UserDetailsModel.fromDomain(UserDetails details) =>
      UserDetailsModel(details);

  static UserRole _parseRole(String? role) {
    if (role == null) return UserRole.user;
    return UserRole.values.firstWhere(
      (r) => r.name == role,
      orElse: () => UserRole.user,
    );
  }
}
