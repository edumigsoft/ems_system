import 'package:open_api_shared/open_api_shared.dart';

/// Request de login com email e senha.
@apiModel
@Model(name: 'LoginRequest', description: 'Request de login com email e senha')
class LoginRequest {
  @Property(description: 'Email do usuário', required: true)
  final String email;

  @Property(description: 'Senha do usuário', required: true)
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    email: json['email'] as String,
    password: json['password'] as String,
  );

  /// Validação básica de presença.
  bool get isValid => email.isNotEmpty && password.isNotEmpty;
}

/// Request de registro de novo usuário.
/// Request de registro de novo usuário.
@Model(
  name: 'RegisterRequest',
  description: 'Request de registro de novo usuário',
)
@apiModel
class RegisterRequest {
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

  const RegisterRequest({
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

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      RegisterRequest(
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

/// Request de reset de senha.
/// Request de reset de senha.
@Model(name: 'PasswordResetRequest', description: 'Request de reset de senha')
@apiModel
class PasswordResetRequest {
  @Property(description: 'Email cadastrado', required: true)
  final String email;

  const PasswordResetRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      PasswordResetRequest(email: json['email'] as String);
}

/// Confirmação de reset de senha com token.
/// Confirmação de reset de senha com token.
@Model(
  name: 'PasswordResetConfirm',
  description: 'Confirmação de reset de senha com token',
)
@apiModel
class PasswordResetConfirm {
  @Property(description: 'Token recebido por email', required: true)
  final String token;

  @Property(description: 'Nova senha', required: true)
  final String newPassword;

  const PasswordResetConfirm({required this.token, required this.newPassword});

  Map<String, dynamic> toJson() => {
    'token': token,
    'new_password': newPassword,
  };

  factory PasswordResetConfirm.fromJson(Map<String, dynamic> json) =>
      PasswordResetConfirm(
        token: json['token'] as String,
        newPassword: json['new_password'] as String,
      );

  bool get isValid => token.isNotEmpty && newPassword.length >= 8;
}
