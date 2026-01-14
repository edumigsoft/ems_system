import 'package:open_api_shared/open_api_shared.dart';

/// DTO para atualização de perfil de usuário.
///
/// Contém apenas os campos que o usuário pode atualizar.
/// Campos como email, role e emailVerified são atualizados apenas por admin.
/// A validação é feita via CoreValidator separado.
@apiModel
@Model(
  name: 'UserUpdate',
  description: 'DTO para atualização de perfil de usuário',
)
class UserUpdate {
  @Property(description: 'Nome completo')
  final String? name;

  @Property(description: 'URL do avatar')
  final String? avatarUrl;

  @Property(description: 'Telefone')
  final String? phone;

  const UserUpdate({this.name, this.avatarUrl, this.phone});

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    if (phone != null) 'phone': phone,
  };

  factory UserUpdate.fromJson(Map<String, dynamic> json) => UserUpdate(
    name: json['name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    phone: json['phone'] as String?,
  );

  /// Verifica se há algum campo para atualizar.
  bool get isEmpty => name == null && avatarUrl == null && phone == null;

  /// Verifica se há algum campo para atualizar.
  bool get isNotEmpty => !isEmpty;
}
