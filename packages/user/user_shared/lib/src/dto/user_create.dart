/// DTO para criação de usuário.
///
/// Contém apenas os campos necessários para criar um novo usuário.
/// A validação é feita via CoreValidator separado.
class UserCreate {
  final String name;
  final String email;
  final String username;
  final String password;
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
