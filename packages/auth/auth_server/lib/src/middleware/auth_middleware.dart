import 'package:shelf/shelf.dart';
import 'package:core_shared/core_shared.dart';
import 'package:auth_shared/auth_shared.dart';

/// Middleware de autenticação JWT.
///
/// Valida tokens JWT e popula o `AuthContext` no request.
class AuthMiddleware {
  /// Verifica e valida o token JWT no header Authorization.
  ///
  /// Popula `request.context['authContext']` com [AuthContext] se válido.
  Middleware verifyJwt() {
    return (Handler innerHandler) {
      return (Request request) async {
        final authorization = request.headers['authorization'];

        if (authorization == null || !authorization.startsWith('Bearer ')) {
          return Response(
            401,
            body: '{"error": "Missing or invalid authorization header"}',
            headers: {'Content-Type': 'application/json'},
          );
        }

        final token = authorization.substring(7);

        try {
          // TODO: Implementar validação real do JWT usando SecurityService
          // Por enquanto, stub que retorna erro
          final payload = _decodeToken(token);

          if (payload == null || payload.isExpired) {
            return Response(
              401,
              body: '{"error": "Token expired or invalid"}',
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
          return Response(
            401,
            body: '{"error": "Invalid token"}',
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

  /// Decodifica o token JWT (stub - será implementado com SecurityService).
  TokenPayload? _decodeToken(String token) {
    // TODO: Implementar usando SecurityService.verifyToken()
    // Por enquanto retorna null
    return null;
  }
}
