import 'package:core_shared/core_shared.dart'
    show UserRole, Failure, Success, Loggable;
import 'package:shelf/shelf.dart';
import 'package:core_server/core_server.dart';
import 'package:auth_shared/auth_shared.dart';

/// Middleware de autenticação e autorização.
class AuthMiddleware with Loggable {
  final SecurityService<dynamic> _securityService;

  AuthMiddleware(this._securityService);

  /// Verifica e valida o token JWT no header Authorization.
  Middleware get verifyJwt {
    return (Handler innerHandler) {
      return (Request request) async {
        final authorization = request.headers['authorization'];
        logger.info(
          '🔐 Authorization header: ${authorization?.substring(0, 30) ?? 'null'}...',
        );

        if (authorization == null || !authorization.startsWith('Bearer ')) {
          logger.warning('❌ Header ausente ou malformado');
          return Response(
            401,
            body: '{"error": "Missing or invalid authorization header"}',
            headers: {'Content-Type': 'application/json'},
          );
        }

        final token = authorization.substring(7);
        logger.info('🎫 Token extraído: ${token.substring(0, 20)}...');

        try {
          // Valida token usando SecurityService
          final result = await _securityService.verifyToken(
            token,
            'ems_system',
          );

          if (result case Failure(error: final error)) {
            logger.warning('❌ Token inválido: $error');
            return Response(
              401,
              body: '{"error": "Invalid token: ${error.toString()}"}',
              headers: {'Content-Type': 'application/json'},
            );
          }

          // Extrai o payload do JWT
          final jwt = (result as Success).value;
          // ignore: avoid_dynamic_calls
          final payloadMap = jwt.payload as Map<String, dynamic>;
          final payload = TokenPayload.fromJson(payloadMap);
          logger.info('✅ Token válido - userId: ${payload.sub}');

          if (payload.isExpired) {
            logger.warning('❌ Token expirado');
            return Response(
              401,
              body: '{"error": "Token expired"}',
              headers: {'Content-Type': 'application/json'},
            );
          }

          final authContext = AuthContext(
            userId: payload.sub,
            email: payload.email,
            role: payload.role,
          );

          final updatedRequest = request.change(
            context: {...request.context, 'authContext': authContext},
          );

          return innerHandler(updatedRequest);
        } catch (e) {
          logger.severe('❌ Erro na validação: $e');
          return Response(
            401,
            body: '{"error": "Token validation failed: $e"}',
            headers: {'Content-Type': 'application/json'},
          );
        }
      };
    };
  }

  /// Requer que o usuário tenha uma role específica.
  Middleware requireRole(UserRole required) {
    return (Handler innerHandler) {
      return (Request request) async {
        final authContext = request.context['authContext'] as AuthContext?;

        if (authContext == null) {
          return Response(
            401,
            body: '{"error": "Not authenticated"}',
            headers: {'Content-Type': 'application/json'},
          );
        }

        if (!authContext.hasRole(required)) {
          return Response(
            403,
            body: '{"error": "Insufficient permissions"}',
            headers: {'Content-Type': 'application/json'},
          );
        }

        return innerHandler(request);
      };
    };
  }

  /// Requer que o usuário tenha uma das roles especificadas.
  Middleware requireAnyRole(List<UserRole> roles) {
    return (Handler innerHandler) {
      return (Request request) async {
        final authContext = request.context['authContext'] as AuthContext?;

        if (authContext == null) {
          return Response(
            401,
            body: '{"error": "Not authenticated"}',
            headers: {'Content-Type': 'application/json'},
          );
        }

        if (!authContext.hasAnyRole(roles)) {
          return Response(
            403,
            body: '{"error": "Insufficient permissions"}',
            headers: {'Content-Type': 'application/json'},
          );
        }

        return innerHandler(request);
      };
    };
  }
}
