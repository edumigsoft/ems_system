import 'package:open_api_shared/open_api_shared.dart';

/// DTO para criação de usuário.
///
/// Contém apenas os campos necessários para criar um novo usuário.
/// A validação é feita via CoreValidator separado.
@apiModel
@Model(name: 'UserCreate', description: 'DTO para criação de usuário')
class UserCreate {
  @Property(description: 'Nome completo', required: true)
  final String name;

  @Property(description: 'Email do usuário', required: true)
  final String email;

  @Property(description: 'Nome de usuário (único)', required: true)
  final String username;

  @Property(description: 'Senha (min 8 car)', required: true)
  final String password;

  @Property(description: 'Telefone (opcional)')
  final String? phone;

  const UserCreate({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'username': username,
    'password': password,
    if (phone != null) 'phone': phone,
  };

  factory UserCreate.fromJson(Map<String, dynamic> json) => UserCreate(
    name: json['name'] as String,
    email: json['email'] as String,
    username: json['username'] as String,
    password: json['password'] as String,
    phone: json['phone'] as String?,
  );

  /// Validação básica de presença.
  bool get isValid =>
      name.isNotEmpty &&
      email.isNotEmpty &&
      username.isNotEmpty &&
      password.length >= 8;
}
