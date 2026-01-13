/// Request de login com email e senha.
class LoginRequest {
  final String email;
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
class RegisterRequest {
  final String name;
  final String email;
  final String username;
  final String password;
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
class PasswordResetRequest {
  final String email;

  const PasswordResetRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      PasswordResetRequest(email: json['email'] as String);
}

/// Confirmação de reset de senha com token.
class PasswordResetConfirm {
  final String token;
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
