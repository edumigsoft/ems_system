import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:core_server/core_server.dart' show AuthRequired;
import 'package:shelf/shelf.dart';

class AuthRequiredImpl extends AuthRequired {
  // final UserRepository _userRepository;

  AuthRequiredImpl({
    required super.secret,
    // required UserRepository userRepository,
  }); // : _userRepository = userRepository;

  @override
  Middleware getMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        final authHeader = request.headers['authorization'];

        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response.unauthorized(
            jsonEncode({'error': 'Acesso negado. Token ausente ou inválido.'}),
            headers: {'content-type': 'application/json'},
          );
        }

        // final token = authHeader.substring(7);

        try {
          // final jwt = JWT.verify(token, SecretKey(secret));
          // final payload = jwt.payload as Map;
          // final userId = payload['user_id'] as String;

          // Verifica se o usuário existe e está ativo via repositório
          // final result = await _userRepository.getById(userId);

          // if (result is! Success<UserDetails>) {
          //   return Response.unauthorized(
          //     jsonEncode({
          //       'error': 'Usuário não encontrado ou erro na validação.',
          //     }),
          //     headers: {'content-type': 'application/json'},
          //   );
          // }

          // final userDetails = result.value;

          // if (!userDetails.isActive || userDetails.deleted) {
          //   return Response.unauthorized(
          //     jsonEncode({'error': 'Usuário inativo ou excluído.'}),
          //     headers: {'content-type': 'application/json'},
          //   );
          // }

          final authenticatedRequest = request.change(
            context: {
              // 'user_details': userDetails,
              // 'userRoles': userDetails.roles.map((e) => e.name).toList(),
            },
          );

          return handler(authenticatedRequest);
        } on JWTExpiredException {
          return Response.unauthorized(
            jsonEncode({'error': 'Token expirado'}),
            headers: {'content-type': 'application/json'},
          );
        } on JWTException {
          return Response.unauthorized(
            jsonEncode({'error': 'Token inválido'}),
            headers: {'content-type': 'application/json'},
          );
        } catch (e) {
          return Response.internalServerError(
            body: jsonEncode({'error': 'Erro interno ao validar token'}),
            headers: {'content-type': 'application/json'},
          );
        }
      };
    };
  }
}
