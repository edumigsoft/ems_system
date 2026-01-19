import 'package:core_shared/core_shared.dart' show Result, Failure, Success;

import '../dtos/generate_tokens_dto.dart';
import '../security_service.dart';

/// Gera tokens de acesso (access token) e atualização (refresh token).
///
/// O [securityService] é utilizado para assinar os tokens.
/// Os parâmetros de duração e identificação do usuário são fornecidos via [params].
///
/// Retorna uma tupla contendo `(accessToken, refreshToken)`.
Future<Result<(String access, String refresh)>> generateTokens({
  required SecurityService<dynamic> securityService,
  required GenerateTokensDto params,
}) async {
  final claims = {
    'user_id': params.id,
    'email': params.email,
    'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'exp':
        DateTime.now().add(params.accessDuration).millisecondsSinceEpoch ~/
        1000,
  };

  final accessResult = await securityService.generateToken(
    claims,
    'accessToken',
  );

  switch (accessResult) {
    case Failure(error: final e):
      return Failure(e);
    case Success(value: final accessToken):
      claims['exp'] =
          DateTime.now().add(params.refreshDuration).millisecondsSinceEpoch ~/
          1000;
      claims['refresh'] = true;

      final refreshResult = await securityService.generateToken(
        claims,
        'refreshToken',
      );

      switch (refreshResult) {
        case Failure(error: final e):
          return Failure(e);
        case Success(value: final refreshToken):
          return Success((accessToken, refreshToken));
      }
  }
}
