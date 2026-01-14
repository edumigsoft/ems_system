import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:core_server/core_server.dart';
import 'package:core_shared/core_shared.dart';
import 'package:auth_server/auth_server.dart';
import 'package:auth_shared/auth_shared.dart';
import 'package:user_shared/user_shared.dart';

import '../../user_server.dart';

/// Rotas de gerenciamento de usuários.
///
/// Endpoints:
/// - GET /users/me - Perfil do usuário autenticado
/// - PUT /users/me - Atualizar perfil próprio
/// - GET /users - Listar usuários (admin)
/// - GET /users/:id - Buscar usuário por ID (admin)
/// - PUT /users/:id - Atualizar usuário (admin)
/// - DELETE /users/:id - Soft delete de usuário (admin)
class UserRoutes extends Routes {
  final UserRepository userRepository;
  final AuthMiddleware authMiddleware;
  final String _backendBaseApi;

  UserRoutes(
    this.userRepository,
    this.authMiddleware, {
    required String backendBaseApi,
  }) : _backendBaseApi = backendBaseApi,
       super(security: true);

  @override
  String get path => '$_backendBaseApi/users';

  @override
  Router get router {
    final router = Router();

    // Perfil do usuário autenticado (qualquer usuário autenticado)
    // Aplica middleware de autenticação JWT
    router.get(
      '/me',
      Pipeline().addMiddleware(authMiddleware.verifyJwt).addHandler(_getMe),
    );
    router.put(
      '/me',
      Pipeline().addMiddleware(authMiddleware.verifyJwt).addHandler(_updateMe),
    );

    // Administração de usuários (apenas admin)
    final adminMiddleware = authMiddleware.requireRole(UserRole.admin);

    router.get(
      '/',
      Pipeline().addMiddleware(adminMiddleware).addHandler(_listUsers),
    );

    router.get(
      '/<id>',
      Pipeline()
          .addMiddleware(adminMiddleware)
          .addHandler((req) => _getUserById(req, req.params['id']!)),
    );

    router.put(
      '/<id>',
      Pipeline()
          .addMiddleware(adminMiddleware)
          .addHandler((req) => _updateUser(req, req.params['id']!)),
    );

    router.delete(
      '/<id>',
      Pipeline()
          .addMiddleware(adminMiddleware)
          .addHandler((req) => _deleteUser(req, req.params['id']!)),
    );

    return router;
  }

  /// GET /users/me - Retorna o perfil do usuário autenticado.
  Future<Response> _getMe(Request request) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Not authenticated'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final result = await userRepository.findById(authContext.userId);

    if (result case Success(value: final user)) {
      final model = UserDetailsModel.fromDomain(user);
      return Response.ok(
        jsonEncode(model.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      // Retorna 401 para forçar o logout no cliente (via interceptor)
      // pois o token pertence a um usuário que não existe mais na base.
      return Response(
        401,
        body: jsonEncode({'error': 'User not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// PUT /users/me - Atualiza o perfil do usuário autenticado.
  Future<Response> _updateMe(Request request) async {
    // Implementar
    return Response.ok(
      '{"message": "Not implemented yet"}',
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// GET /users - Lista todos os usuários (admin only).
  Future<Response> _listUsers(Request request) async {
    // Implementar - verificar role admin
    return Response.ok(
      '{"message": "Not implemented yet"}',
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// GET /users/:id - Busca usuário por ID (admin only).
  Future<Response> _getUserById(Request request, String id) async {
    // Implementar
    return Response.ok(
      '{"message": "Not implemented yet"}',
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// PUT /users/:id - Atualiza usuário (admin only).
  Future<Response> _updateUser(Request request, String id) async {
    // Implementar
    return Response.ok(
      '{"message": "Not implemented yet"}',
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// DELETE /users/:id - Soft delete de usuário (admin only).
  Future<Response> _deleteUser(Request request, String id) async {
    // Implementar
    return Response.ok(
      '{"message": "Not implemented yet"}',
      headers: {'Content-Type': 'application/json'},
    );
  }
}
