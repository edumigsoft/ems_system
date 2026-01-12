import 'package:core_shared/core_shared.dart';
import 'package:shelf/shelf.dart';

int expiresIn({int timeSeconds = 0, int timeMinutes = 0, int timeDays = 0}) {
  int seconds = 0;

  if (timeSeconds > 0) {
    seconds = timeSeconds;
  } else if (timeMinutes > 0) {
    seconds = timeMinutes * 60;
  } else if (timeDays > 0) {
    seconds = timeDays * 86400;
  }

  final expiresDate = DateTime.now().add(Duration(seconds: seconds));
  final expiresIn = Duration(
    milliseconds: expiresDate.millisecondsSinceEpoch,
  ).inSeconds;

  return expiresIn;
}

abstract class SecurityService<T> {
  /// Middleware de autorização para proteger rotas.
  ///
  /// Valida tokens JWT e verifica permissões antes de permitir
  /// acesso aos endpoints protegidos.
  Middleware get authorization;

  Future<Result<String>> generateToken(
    Map<String, dynamic> claims,
    String audience,
  );
  Future<Result<Map<String, dynamic>>> getPayload(String token);

  /// Middleware de verificação de token JWT.
  ///
  /// Valida e decodifica tokens JWT, lançando exceção se inválido
  /// ou expirado.
  Middleware get verifyJWT;

  Future<Result<T>> verifyToken(String token, String audience);
}
