import 'package:auth_shared/auth_shared.dart';
import 'package:core_shared/core_shared.dart';

import '../repository/resource_permission_repository.dart';

/// Serviço de gestão de permissões de recursos.
class ResourcePermissionService {
  final ResourcePermissionRepository _repo;

  ResourcePermissionService(this._repo);

  /// Verifica se o usuário tem a permissão mínima necessária.
  ///
  /// Retorna true se:
  /// 1. Usuário tem a permissão exata SOLICITADA
  /// 2. OU Usuário tem permissão superior (hierarquia)
  Future<bool> checkPermission({
    required String userId,
    required String resourceType,
    required String resourceId,
    required ResourcePermission minPermission,
  }) async {
    final permission = await _repo.getPermission(
      userId: userId,
      resourceType: resourceType,
      resourceId: resourceId,
    );

    if (permission == null) return false;
    return permission.satisfies(minPermission);
  }

  /// Concede permissão a um usuário.
  Future<Result<Unit>> grantPermission({
    required String userId,
    required String resourceType,
    required String resourceId,
    required ResourcePermission permission,
  }) async {
    try {
      await _repo.grantPermission(
        userId: userId,
        resourceType: resourceType,
        resourceId: resourceId,
        permission: permission,
      );
      return successOfUnit();
    } catch (e) {
      return Failure(Exception('Erro ao conceder permissão: $e'));
    }
  }

  /// Revoga permissão de um usuário.
  Future<Result<Unit>> revokePermission({
    required String userId,
    required String resourceType,
    required String resourceId,
  }) async {
    try {
      await _repo.revokePermission(
        userId: userId,
        resourceType: resourceType,
        resourceId: resourceId,
      );
      return successOfUnit();
    } catch (e) {
      return Failure(Exception('Erro ao revogar permissão: $e'));
    }
  }
}
