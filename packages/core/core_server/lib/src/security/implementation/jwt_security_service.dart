import '../security_service.dart';
import 'package:core_shared/core_shared.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';

class JWTSecurityService with Loggable implements SecurityService<JWT> {
  final String _jwtKey;

  JWTSecurityService({required String jwtKey}) : _jwtKey = jwtKey {
    logger.info('Created object ${DateTime.now().microsecondsSinceEpoch}');
  }

  @override
  /// Middleware de autorização que extrai e valida token JWT do header.
  ///
  /// Processa o header 'Authorization' Bearer, valida o token e adiciona
  /// o JWT decodificado ao contexto da requisição para uso posterior.
  Middleware get authorization {
    return (Handler handler) {
      return (Request req) async {
        final String? authorizationHeader = req.headers['Authorization'];
        JWT? jwt;

        if (authorizationHeader != null &&
            authorizationHeader.startsWith('Bearer ')) {
          final String token = authorizationHeader.substring(7);
          final result = await verifyToken(token, 'accessToken');
          if (result case Success(value: final validJwt)) {
            jwt = validJwt;
          }
        }

        final request = req.change(context: {'jwt': jwt});

        return handler(request);
      };
    };
  }

  @override
  Future<Result<String>> generateToken(
    Map<String, dynamic> claims,
    String audience,
  ) async {
    try {
      final jwt = JWT(claims, audience: Audience.one(audience));
      final String token = jwt.sign(SecretKey(_jwtKey));
      return Success(token);
    } catch (e) {
      return Failure(Exception('Failed to generate token: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getPayload(String token) async {
    try {
      final jwt = JWT.verify(
        token,
        SecretKey(_jwtKey),
        checkExpiresIn: false,
        checkHeaderType: false,
        checkNotBefore: false,
      );
      return Success(jwt.payload as Map<String, dynamic>);
    } catch (e) {
      return Failure(Exception('Failed to get payload: $e'));
    }
  }

  @override
  Future<Result<JWT>> verifyToken(String token, String audience) async {
    try {
      final jwt = JWT.verify(
        token,
        SecretKey(_jwtKey),
        audience: Audience.one(audience),
      );
      return Success(jwt);
    } on JWTInvalidException catch (e) {
      return Failure(Exception(e.message));
    } on JWTExpiredException catch (e) {
      return Failure(Exception(e.message));
    } on JWTNotActiveException catch (e) {
      return Failure(Exception(e.message));
    } on JWTUndefinedException catch (e) {
      return Failure(Exception(e.message));
    } catch (e) {
      return Failure(Exception('Token verification failed: $e'));
    }
  }

  @override
  Middleware get verifyJWT => createMiddleware(
    requestHandler: (Request req) {
      if (req.context['jwt'] == null) {
        return Response.forbidden('Not Authorized');
      }

      return null;
    },
  );
}
