import 'package:open_api_shared/open_api_shared.dart';
import 'package:user_shared/user_shared.dart';

/// Par de tokens JWT (access + refresh).
@Model(name: 'TokenPair', description: 'Par de tokens JWT (access + refresh)')
class TokenPair {
  @Property(description: 'Token de acesso')
  final String accessToken;

  @Property(description: 'Token de refresh')
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
@Model(
  name: 'AuthResponse',
  description: 'Resposta de autenticação bem-sucedida',
)
class AuthResponse {
  @Property(description: 'Par de tokens')
  final TokenPair tokens;

  @Property(description: 'Detalhes do usuário')
  final UserDetails user;

  @Property(description: 'Tempo de expiração (segundos)')
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
@Model(name: 'RefreshResponse', description: 'Resposta de refresh de token')
class RefreshResponse {
  @Property(description: 'Novos tokens')
  final TokenPair tokens;

  @Property(description: 'Tempo de expiração (segundos)')
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
