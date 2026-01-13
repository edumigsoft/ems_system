import 'package:core_shared/core_shared.dart';

/// Payload do token JWT.
///
/// Contém as claims do token para validação e identificação do usuário.
class TokenPayload {
  /// ID do usuário.
  final String sub;

  /// Email do usuário.
  final String email;

  /// Role global do usuário.
  final UserRole role;

  /// Data de emissão (issued at).
  final DateTime iat;

  /// Data de expiração.
  final DateTime exp;

  /// Identificador único do token (para refresh token tracking).
  final String? jti;

  const TokenPayload({
    required this.sub,
    required this.email,
    required this.role,
    required this.iat,
    required this.exp,
    this.jti,
  });

  /// Verifica se o token está expirado.
  bool get isExpired => DateTime.now().isAfter(exp);

  /// Verifica se o token expira em menos de [duration].
  bool expiresWithin(Duration duration) {
    return DateTime.now().add(duration).isAfter(exp);
  }

  Map<String, dynamic> toJson() => {
    'sub': sub,
    'email': email,
    'role': role.name,
    'iat': iat.millisecondsSinceEpoch ~/ 1000,
    'exp': exp.millisecondsSinceEpoch ~/ 1000,
    if (jti != null) 'jti': jti,
  };

  factory TokenPayload.fromJson(Map<String, dynamic> json) => TokenPayload(
    sub: json['sub'] as String,
    email: json['email'] as String,
    role: _parseRole(json['role'] as String?),
    iat: DateTime.fromMillisecondsSinceEpoch((json['iat'] as int) * 1000),
    exp: DateTime.fromMillisecondsSinceEpoch((json['exp'] as int) * 1000),
    jti: json['jti'] as String?,
  );

  static UserRole _parseRole(String? role) {
    if (role == null) return UserRole.user;
    return UserRole.values.firstWhere(
      (r) => r.name == role,
      orElse: () => UserRole.user,
    );
  }
}
