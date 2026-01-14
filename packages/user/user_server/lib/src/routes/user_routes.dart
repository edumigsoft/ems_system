import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:core_server/core_server.dart';

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

  UserRoutes(this.userRepository) : super(security: true);

  @override
  String get path => '/users';

  @override
  Router get router {
    final router = Router();

    // Perfil do usuário autenticado
    router.get('/me', _getMe);
    router.put('/me', _updateMe);

    // Administração de usuários
    router.get('/', _listUsers);
    router.get('/<id>', _getUserById);
    router.put('/<id>', _updateUser);
    router.delete('/<id>', _deleteUser);

    return router;
  }

  /// GET /users/me - Retorna o perfil do usuário autenticado.
  Future<Response> _getMe(Request request) async {
    // Implementar - extrair userId do AuthContext
    return Response.ok(
      '{"message": "Not implemented yet"}',
      headers: {'Content-Type': 'application/json'},
    );
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
