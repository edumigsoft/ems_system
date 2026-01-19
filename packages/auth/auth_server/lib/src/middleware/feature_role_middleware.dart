import 'package:auth_shared/auth_shared.dart'
    show FeatureUserRoleRepository, FeatureUserRole, AuthContext;
import 'package:shelf/shelf.dart';

/// Middleware genérico para verificação de papéis em features.
///
/// Pode ser usado por qualquer feature (project, finance, etc.).
/// Admin/Owner global bypassa verificações de feature.
class FeatureRoleMiddleware {
  final FeatureUserRoleRepository _repository;

  FeatureRoleMiddleware(this._repository);

  /// Requer papel mínimo em uma feature.
  ///
  /// [minRole]: Papel mínimo necessário
  /// [featureIdExtractor]: Função que extrai o featureId do request (ex: de params)
  ///
  /// Exemplo de uso:
  /// ```dart
  /// router.get(
  ///   '/projects/<projectId>/members',
  ///   Pipeline()
  ///     .addMiddleware(middleware.requireFeatureRole(
  ///       FeatureUserRole.viewer,
  ///       (req) => req.params['projectId']!,
  ///     ))
  ///     .addHandler(_listMembers),
  /// );
  /// ```
  Middleware requireFeatureRole(
    FeatureUserRole minRole,
    String Function(Request) featureIdExtractor,
  ) {
    return (Handler innerHandler) {
      return (Request request) async {
        final authContext = request.context['authContext'] as AuthContext?;

        if (authContext == null) {
          return Response.forbidden('Not authenticated');
        }

        // Global admin/owner bypass feature-specific checks
        if (authContext.role.isAdmin) {
          return innerHandler(request);
        }

        final featureId = featureIdExtractor(request);

        final result = await _repository.hasRole(
          userId: authContext.userId,
          featureId: featureId,
          minRole: minRole,
        );

        return result.when(
          success: (hasRole) {
            if (!hasRole) {
              return Response.forbidden(
                'Insufficient permissions for this feature',
              );
            }
            return innerHandler(request);
          },
          failure: (error) => Response.internalServerError(
            body: 'Permission check failed: ${error.toString()}',
          ),
        );
      };
    };
  }
}
