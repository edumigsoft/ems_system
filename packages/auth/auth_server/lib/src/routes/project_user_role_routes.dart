import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:core_server/core_server.dart';
import 'package:core_shared/core_shared.dart';
import 'package:auth_shared/auth_shared.dart';

import '../service/project_user_role_service.dart';

/// Rotas de gerenciamento de papéis de usuário em projetos.
///
/// Exemplo de implementação de rotas para feature-specific user roles.
class ProjectUserRoleRoutes extends Routes {
  final ProjectUserRoleService _service;
  final String _backendBaseApi;

  ProjectUserRoleRoutes(this._service, {required String backendBaseApi})
    : _backendBaseApi = backendBaseApi,
      super(security: true); // Requer autenticação

  @override
  String get path => '$_backendBaseApi/projects';

  @override
  Router get router {
    final router = Router();

    // Adicionar membro ao projeto (requer manager)
    router.post('/<projectId>/members', _addMember);

    // Remover membro do projeto (requer manager)
    router.delete('/<projectId>/members/<userId>', _removeMember);

    // Listar membros do projeto (requer viewer)
    router.get('/<projectId>/members', _listMembers);

    // Obter papel de um usuário específico (requer viewer)
    router.get('/<projectId>/members/<userId>', _getUserRole);

    // Atualizar papel de um membro (requer manager)
    router.patch('/<projectId>/members/<userId>', _updateMember);

    return router;
  }

  /// POST /projects/:projectId/members
  Future<Response> _addMember(Request request) async {
    final projectId = request.params['projectId']!;
    final authContext = request.context['authContext'] as AuthContext;

    try {
      // Verifica se o requisitante pode gerenciar membros
      final canManage = await _service.canManageMembers(
        userId: authContext.userId,
        projectId: projectId,
      );

      if (canManage is Failure || !(canManage as Success).value) {
        return Response.forbidden(
          jsonEncode({'error': 'Insufficient permissions to manage members'}),
        );
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final userId = data['user_id'] as String?;
      final roleStr = data['role'] as String?;

      if (userId == null || roleStr == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing user_id or role'}),
        );
      }

      final role = FeatureUserRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => FeatureUserRole.viewer,
      );

      final result = await _service.grantRole(
        userId: userId,
        projectId: projectId,
        role: role,
      );

      return result.when(
        success: (details) => Response(
          201,
          body: jsonEncode({
            'message': 'Member added successfully',
            'id': details.id,
            'user_id': details.userId,
            'project_id': details.featureId,
            'role': details.role.name,
          }),
          headers: {'Content-Type': 'application/json'},
        ),
        failure: (error) => Response.internalServerError(
          body: jsonEncode({'error': error.toString()}),
        ),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to add member: $e'}),
      );
    }
  }

  /// DELETE /projects/:projectId/members/:userId
  Future<Response> _removeMember(Request request) async {
    final projectId = request.params['projectId']!;
    final userId = request.params['userId']!;
    final authContext = request.context['authContext'] as AuthContext;

    try {
      // Verifica se o requisitante pode gerenciar membros
      final canManage = await _service.canManageMembers(
        userId: authContext.userId,
        projectId: projectId,
      );

      if (canManage is Failure || !(canManage as Success).value) {
        return Response.forbidden(
          jsonEncode({'error': 'Insufficient permissions to manage members'}),
        );
      }

      final result = await _service.revokeRole(
        userId: userId,
        projectId: projectId,
      );

      return result.when(
        success: (_) => Response.ok(
          jsonEncode({'message': 'Member removed successfully'}),
          headers: {'Content-Type': 'application/json'},
        ),
        failure: (error) => Response.internalServerError(
          body: jsonEncode({'error': error.toString()}),
        ),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to remove member: $e'}),
      );
    }
  }

  /// GET /projects/:projectId/members
  Future<Response> _listMembers(Request request) async {
    final projectId = request.params['projectId']!;
    final authContext = request.context['authContext'] as AuthContext;

    try {
      // Verifica se usuário tem pelo menos viewer role
      final userRole = await _service.getUserRole(
        userId: authContext.userId,
        projectId: projectId,
      );

      if (userRole is Failure ||
          (userRole as Success).value == null && !authContext.role.isAdmin) {
        return Response.forbidden(
          jsonEncode({'error': 'Insufficient permissions to view members'}),
        );
      }

      final result = await _service.listMembers(projectId);

      return result.when(
        success: (members) {
          final membersJson = members
              .map(
                (m) => {
                  'id': m.id,
                  'user_id': m.userId,
                  'project_id': m.featureId,
                  'role': m.role.name,
                  'is_active': m.isActive,
                  'created_at': m.createdAt.toIso8601String(),
                },
              )
              .toList();

          return Response.ok(
            jsonEncode({'members': membersJson, 'count': members.length}),
            headers: {'Content-Type': 'application/json'},
          );
        },
        failure: (error) => Response.internalServerError(
          body: jsonEncode({'error': error.toString()}),
        ),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to list members: $e'}),
      );
    }
  }

  /// GET /projects/:projectId/members/:userId
  Future<Response> _getUserRole(Request request) async {
    final projectId = request.params['projectId']!;
    final userId = request.params['userId']!;
    final authContext = request.context['authContext'] as AuthContext;

    try {
      // Verifica se requisitante tem permissão para ver roles
      final requesterRole = await _service.getUserRole(
        userId: authContext.userId,
        projectId: projectId,
      );

      if (requesterRole is Failure ||
          (requesterRole as Success).value == null &&
              !authContext.role.isAdmin) {
        return Response.forbidden(
          jsonEncode({'error': 'Insufficient permissions'}),
        );
      }

      final result = await _service.getUserRole(
        userId: userId,
        projectId: projectId,
      );

      return result.when(
        success: (details) {
          if (details == null) {
            return Response.notFound(
              jsonEncode({'error': 'User role not found'}),
            );
          }

          return Response.ok(
            jsonEncode({
              'id': details.id,
              'user_id': details.userId,
              'project_id': details.featureId,
              'role': details.role.name,
              'is_active': details.isActive,
              'created_at': details.createdAt.toIso8601String(),
            }),
            headers: {'Content-Type': 'application/json'},
          );
        },
        failure: (error) => Response.internalServerError(
          body: jsonEncode({'error': error.toString()}),
        ),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get user role: $e'}),
      );
    }
  }

  /// PATCH /projects/:projectId/members/:userId
  Future<Response> _updateMember(Request request) async {
    final projectId = request.params['projectId']!;
    final userId = request.params['userId']!;
    final authContext = request.context['authContext'] as AuthContext;

    try {
      // Verifica se o requisitante pode gerenciar membros
      final canManage = await _service.canManageMembers(
        userId: authContext.userId,
        projectId: projectId,
      );

      if (canManage is Failure || !(canManage as Success).value) {
        return Response.forbidden(
          jsonEncode({'error': 'Insufficient permissions to manage members'}),
        );
      }

      // Obtém o role atual do usuário alvo
      final currentRole = await _service.getUserRole(
        userId: userId,
        projectId: projectId,
      );

      if (currentRole is Failure || (currentRole as Success).value == null) {
        return Response.notFound(jsonEncode({'error': 'User role not found'}));
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      FeatureUserRole? newRole;
      if (data['role'] != null) {
        final roleStr = data['role'] as String;
        newRole = FeatureUserRole.values.firstWhere(
          (r) => r.name == roleStr,
          orElse: () => FeatureUserRole.viewer,
        );
      }

      final update = FeatureUserRoleUpdate(
        id: (currentRole as Success).value!.id,
        role: newRole,
        isActive: data['is_active'] as bool?,
      );

      final result = await _service.updateRole(update);

      return result.when(
        success: (details) => Response.ok(
          jsonEncode({
            'message': 'Member updated successfully',
            'id': details.id,
            'user_id': details.userId,
            'project_id': details.featureId,
            'role': details.role.name,
            'is_active': details.isActive,
          }),
          headers: {'Content-Type': 'application/json'},
        ),
        failure: (error) => Response.internalServerError(
          body: jsonEncode({'error': error.toString()}),
        ),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update member: $e'}),
      );
    }
  }
}
