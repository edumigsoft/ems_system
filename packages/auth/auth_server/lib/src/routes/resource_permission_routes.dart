import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:core_server/core_server.dart';
import 'package:core_shared/core_shared.dart';
import 'package:auth_shared/auth_shared.dart';

import '../service/resource_permission_service.dart';
import '../middleware/auth_middleware.dart';

/// Rotas para gerenciamento de permissões de recursos.
///
/// Endpoints:
/// - POST /resources/:type/:id/members - Adicionar membro (requer manage)
/// - DELETE /resources/:type/:id/members/:userId - Remover membro (requer manage)
/// - GET /resources/:type/:id/members - Listar membros (requer read)
class ResourcePermissionRoutes extends Routes {
  final ResourcePermissionService permissionService;
  final AuthMiddleware authMiddleware;
  final String _backendBaseApi;

  ResourcePermissionRoutes(
    this.permissionService,
    this.authMiddleware, {
    required String backendBaseApi,
  }) : _backendBaseApi = backendBaseApi,
       super(security: true);

  @override
  String get path => '$_backendBaseApi/resources';

  @override
  Router get router {
    final router = Router();

    // Adicionar membro ao recurso (requer manage)
    router.post('/<type>/<id>/members', _addMember);

    // Remover membro do recurso (requer manage)
    router.delete('/<type>/<id>/members/<userId>', _removeMember);

    // Listar membros do recurso (requer read)
    router.get('/<type>/<id>/members', _listMembers);

    return router;
  }

  /// POST /resources/:type/:id/members
  /// Adiciona membro ao recurso - requer permissão MANAGE
  Future<Response> _addMember(Request request) async {
    final resourceType = request.params['type']!;
    final resourceId = request.params['id']!;
    final authContext = request.context['authContext'] as AuthContext;

    try {
      // 🔒 VALIDAÇÃO DE SEGURANÇA
      // Verifica se usuário atual tem permissão MANAGE no recurso
      final hasManagePermission = await permissionService.checkPermission(
        userId: authContext.userId,
        resourceType: resourceType,
        resourceId: resourceId,
        minPermission: ResourcePermission.manage,
      );

      if (!hasManagePermission && authContext.role != UserRole.admin) {
        return Response.forbidden(
          jsonEncode({
            'error':
                'Você precisa ter permissão "manage" neste recurso para adicionar membros',
          }),
        );
      }

      // ✅ USUÁRIO AUTORIZADO - Processa solicitação
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final newUserId = data['userId'] as String?;
      final permissionStr = data['permission'] as String?;

      if (newUserId == null || permissionStr == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Campos obrigatórios: userId, permission',
          }),
        );
      }

      final permission = ResourcePermission.fromString(permissionStr);
      if (permission == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Permissão inválida. Use: read, write, delete ou manage',
          }),
        );
      }

      // Concede permissão ao novo usuário
      final result = await permissionService.grantPermission(
        userId: newUserId,
        resourceType: resourceType,
        resourceId: resourceId,
        permission: permission,
      );

      return result.when(
        success: (_) => Response.ok(
          jsonEncode({
            'message': 'Membro adicionado com sucesso',
            'userId': newUserId,
            'permission': permission.name,
          }),
        ),
        failure: (error) => Response.internalServerError(
          body: jsonEncode({'error': error.toString()}),
        ),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao adicionar membro: $e'}),
      );
    }
  }

  /// DELETE /resources/:type/:id/members/:userId
  /// Remove membro do recurso - requer permissão MANAGE
  Future<Response> _removeMember(Request request) async {
    final resourceType = request.params['type']!;
    final resourceId = request.params['id']!;
    final userIdToRemove = request.params['userId']!;
    final authContext = request.context['authContext'] as AuthContext;

    try {
      // 🔒 VALIDAÇÃO DE SEGURANÇA
      final hasManagePermission = await permissionService.checkPermission(
        userId: authContext.userId,
        resourceType: resourceType,
        resourceId: resourceId,
        minPermission: ResourcePermission.manage,
      );

      if (!hasManagePermission && authContext.role != UserRole.admin) {
        return Response.forbidden(
          jsonEncode({
            'error':
                'Você precisa ter permissão "manage" neste recurso para remover membros',
          }),
        );
      }

      // ✅ USUÁRIO AUTORIZADO - Remove permissão
      final result = await permissionService.revokePermission(
        userId: userIdToRemove,
        resourceType: resourceType,
        resourceId: resourceId,
      );

      return result.when(
        success: (_) =>
            Response.ok(jsonEncode({'message': 'Membro removido com sucesso'})),
        failure: (error) => Response.internalServerError(
          body: jsonEncode({'error': error.toString()}),
        ),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao remover membro: $e'}),
      );
    }
  }

  /// GET /resources/:type/:id/members
  /// Lista membros do recurso - requer permissão READ
  Future<Response> _listMembers(Request request) async {
    final resourceType = request.params['type']!;
    final resourceId = request.params['id']!;
    final authContext = request.context['authContext'] as AuthContext;

    try {
      // 🔒 VALIDAÇÃO DE SEGURANÇA - Mínimo: READ
      final hasAccess = await permissionService.checkPermission(
        userId: authContext.userId,
        resourceType: resourceType,
        resourceId: resourceId,
        minPermission: ResourcePermission.read,
      );

      if (!hasAccess && authContext.role != UserRole.admin) {
        return Response.forbidden(
          jsonEncode({'error': 'Você não tem acesso a este recurso'}),
        );
      }

      // ✅ USUÁRIO AUTORIZADO - Lista membros
      final members = await permissionService.listMembers(
        resourceType: resourceType,
        resourceId: resourceId,
      );

      final membersJson = members
          .map(
            (m) => {
              'userId': m.userId,
              'permission': m.permission,
              'resourceType': m.resourceType,
              'resourceId': m.resourceId,
            },
          )
          .toList();

      return Response.ok(
        jsonEncode({'members': membersJson, 'count': members.length}),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao listar membros: $e'}),
      );
    }
  }
}
