import 'package:user_shared/user_shared.dart';

/// Par de tokens JWT (access + refresh).
class TokenPair {
  final String accessToken;
  final String refreshToken;

  const TokenPair({required this.accessToken, required this.refreshToken});

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
  );
}

/// Resposta de autenticação bem-sucedida.
class AuthResponse {
  final TokenPair tokens;
  final UserDetails user;
  final int expiresIn;

  const AuthResponse({
    required this.tokens,
    required this.user,
    required this.expiresIn,
  });

  Map<String, dynamic> toJson() => {
    'tokens': tokens.toJson(),
    'user': UserDetailsModel.fromDomain(user).toJson(),
    'expires_in': expiresIn,
  };

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    tokens: TokenPair.fromJson(json['tokens'] as Map<String, dynamic>),
    user: UserDetailsModel.fromJson(
      json['user'] as Map<String, dynamic>,
    ).toDomain(),
    expiresIn: json['expires_in'] as int,
  );
}

/// Resposta de refresh de token.
class RefreshResponse {
  final TokenPair tokens;
  final int expiresIn;

  const RefreshResponse({required this.tokens, required this.expiresIn});

  Map<String, dynamic> toJson() => {
    'tokens': tokens.toJson(),
    'expires_in': expiresIn,
  };

  factory RefreshResponse.fromJson(Map<String, dynamic> json) =>
      RefreshResponse(
        tokens: TokenPair.fromJson(json['tokens'] as Map<String, dynamic>),
        expiresIn: json['expires_in'] as int,
      );
}
