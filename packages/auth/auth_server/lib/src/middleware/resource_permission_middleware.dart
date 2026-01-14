import 'package:core_shared/core_shared.dart';
import 'package:shelf/shelf.dart';
import 'package:auth_shared/auth_shared.dart';
import '../service/resource_permission_service.dart';

/// Middleware de permissão de recursos.
class ResourcePermissionMiddleware {
  final ResourcePermissionService _service;

  ResourcePermissionMiddleware(this._service);

  /// Requer permissão específica em um recurso.
  ///
  /// O [resourceType] deve ser fixo.
  /// O [resourceIdExtractor] extrai o ID do recurso do request (ex: URL param).
  Middleware requirePermission(
    String resourceType,
    ResourcePermission permission,
    String Function(Request) resourceIdExtractor,
  ) {
    return (Handler innerHandler) {
      return (Request request) async {
        final authContext = request.context['authContext'] as AuthContext?;

        if (authContext == null) {
          return Response.forbidden('Not authenticated');
        }

        // Admin tem acesso total (opcional, dependendo da regra de negócio)
        if (authContext.role == UserRole.admin) {
          return innerHandler(request);
        }

        final resourceId = resourceIdExtractor(request);

        final hasPermission = await _service.checkPermission(
          userId: authContext.userId,
          resourceType: resourceType,
          resourceId: resourceId,
          minPermission: permission,
        );

        if (!hasPermission) {
          return Response.forbidden('Insufficient resource permissions');
        }

        return innerHandler(request);
      };
    };
  }
}
