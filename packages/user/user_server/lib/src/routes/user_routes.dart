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
/// **Endpoints Públicos (autenticado):**
/// - GET /users/me - Perfil do usuário autenticado
/// - PUT /users/me - Atualizar perfil próprio
///
/// **Endpoints Administrativos (admin ou owner):**
/// - GET /users - Listar usuários
/// - GET /users/:id - Buscar usuário por ID
/// - PUT /users/:id - Atualizar usuário (com restrições de hierarquia)
///
/// **Endpoints Restritos (apenas owner):**
/// - DELETE /users/:id - Soft delete de usuário
///
/// **Hierarquia de Permissões:**
/// - Owner (nível 4): Acesso total, incluindo:
///   - Conceder role de owner a outros usuários
///   - Modificar outros owners
///   - Deletar qualquer usuário (incluindo outros owners)
///
/// - Admin (nível 3): Acesso administrativo, exceto:
///   - NÃO pode conceder role de owner
///   - NÃO pode modificar owners
///   - NÃO pode deletar nenhum usuário
class UserRoutes extends Routes {
  final UserRepository userRepository;
  final AuthMiddleware authMiddleware;
  final DependencyInjector di;
  final String _backendBaseApi;

  UserRoutes(
    this.userRepository,
    this.authMiddleware,
    this.di, {
    required String backendBaseApi,
  }) : _backendBaseApi = backendBaseApi,
       super(security: true);

  /// Lazy getter para AuthService (resolve dependência circular).
  ///
  /// AuthService é inicializado depois de UserRoutes, então não pode
  /// ser injetado via construtor. Usamos lazy resolution via DI.
  AuthService get _authService => di.get<AuthService>();

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

    // Criação de usuários (apenas owner)
    final ownerMiddleware = authMiddleware.requireRole(UserRole.owner);

    router.post(
      '/',
      Pipeline().addMiddleware(ownerMiddleware).addHandler(_createUser),
    );

    // Gerenciamento de senha (admin+)
    router.post(
      '/<id>/force-password-change',
      Pipeline()
          .addMiddleware(adminMiddleware)
          .addHandler((req) => _forcePasswordChange(req, req.params['id']!)),
    );

    router.post(
      '/<id>/reset-password',
      Pipeline()
          .addMiddleware(adminMiddleware)
          .addHandler((req) => _adminResetPassword(req, req.params['id']!)),
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
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Not authenticated'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final updateModel = UserUpdateModel.fromJson(json);
      final updateDto = updateModel.toDomain();

      // Validar DTO
      final validator = UserUpdateValidator();
      final validationResult = validator.validate(updateDto);

      if (!validationResult.isValid) {
        return Response(
          422,
          body: jsonEncode({
            'error': 'Validation failed',
            'details': validationResult.errors
                .map((e) => {'field': e.field, 'message': e.message})
                .toList(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Criar DTO com ID do usuário autenticado
      final updatedDto = UserUpdate(
        id: authContext.userId,
        name: updateDto.name,
        avatarUrl: updateDto.avatarUrl,
        phone: updateDto.phone,
        isActive: updateDto.isActive,
        isDeleted: updateDto.isDeleted,
      );
      final result = await userRepository.update(
        authContext.userId,
        updatedDto,
      );

      return result.when(
        success: (user) {
          final model = UserDetailsModel.fromDomain(user);
          return Response.ok(
            jsonEncode(model.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        },
        failure: (exception) {
          if (exception is DataException) {
            return Response.notFound(
              jsonEncode({'error': exception.message}),
              headers: {'Content-Type': 'application/json'},
            );
          }
          return Response.internalServerError(
            body: jsonEncode({'error': 'Failed to update user'}),
            headers: {'Content-Type': 'application/json'},
          );
        },
      );
    } catch (e) {
      return Response(
        400,
        body: jsonEncode({'error': 'Invalid request body'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /users - Lista todos os usuários (admin only).
  Future<Response> _listUsers(Request request) async {
    // Verificar autenticação (já passou pelo middleware)
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    // Log para debug
    // print('[ListUsers] User: ${authContext.userId}, Role: ${authContext.role}');

    try {
      final queryParams = request.url.queryParameters;

      // Extrair parâmetros de paginação
      final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
      final limitParam = int.tryParse(queryParams['limit'] ?? '50') ?? 50;
      final limit = limitParam.clamp(1, 100); // Máximo 100 por página
      final offset = (page - 1) * limit;

      // Extrair filtros
      final roleFilter = queryParams['role'];
      UserRole? role;
      if (roleFilter != null) {
        try {
          role = UserRole.values.firstWhere((r) => r.name == roleFilter);
        } catch (_) {
          return Response(
            400,
            body: jsonEncode({'error': 'Invalid role filter'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      final search = queryParams['search'];

      // Buscar usuários
      final result = await userRepository.findAll(
        limit: limit,
        offset: offset,
        roleFilter: role?.name,
        search: search,
      );

      return result.when(
        success: (users) {
          final models = users
              .map((u) => UserDetailsModel.fromDomain(u).toJson())
              .toList();
          return Response.ok(
            jsonEncode({
              'data': models,
              'page': page,
              'limit': limit,
              'total': users.length,
            }),
            headers: {'Content-Type': 'application/json'},
          );
        },
        failure: (exception) {
          return Response.internalServerError(
            body: jsonEncode({'error': 'Failed to fetch users'}),
            headers: {'Content-Type': 'application/json'},
          );
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Internal server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /users/:id - Busca usuário por ID (admin only).
  Future<Response> _getUserById(Request request, String id) async {
    if (id.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'User ID is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final result = await userRepository.findById(id);

    return result.when(
      success: (user) {
        final model = UserDetailsModel.fromDomain(user);
        return Response.ok(
          jsonEncode(model.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      },
      failure: (exception) {
        if (exception is DataException) {
          return Response.notFound(
            jsonEncode({'error': 'User not found'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to fetch user'}),
          headers: {'Content-Type': 'application/json'},
        );
      },
    );
  }

  /// PUT /users/:id - Atualiza usuário (admin only).
  Future<Response> _updateUser(Request request, String id) async {
    if (id.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'User ID is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final authContext = request.context['authContext'] as AuthContext;

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      // Extrair campos administrativos opcionais
      final role = json['role'] as String?;
      final emailVerified = json['email_verified'] as bool?;
      final isActive = json['is_active'] as bool?;

      UserRole? userRole;
      if (role != null) {
        try {
          userRole = UserRole.values.firstWhere((r) => r.name == role);
        } catch (_) {
          return Response(
            400,
            body: jsonEncode({'error': 'Invalid role value'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // PROTEÇÃO: Apenas owner pode conceder role de owner
        if (userRole == UserRole.owner && !authContext.role.isOwner) {
          return Response.forbidden(
            jsonEncode({
              'error': 'Only owners can grant owner role',
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      // PROTEÇÃO: Verificar se o usuário alvo existe e seu role atual
      final targetUserResult = await userRepository.findById(id);

      if (targetUserResult case Failure(error: _)) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final targetUser = (targetUserResult as Success<UserDetails>).value;

      // PROTEÇÃO: Apenas owner pode modificar outro owner
      if (targetUser.role == UserRole.owner && !authContext.role.isOwner) {
        return Response.forbidden(
          jsonEncode({
            'error': 'Only owners can modify other owners',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Atualizar via método admin do repositório
      final result = await userRepository.updateByAdmin(
        id,
        role: userRole,
        emailVerified: emailVerified,
        isActive: isActive,
      );

      return result.when(
        success: (user) {
          final model = UserDetailsModel.fromDomain(user);
          return Response.ok(
            jsonEncode(model.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        },
        failure: (exception) {
          if (exception is DataException) {
            return Response.notFound(
              jsonEncode({'error': exception.message}),
              headers: {'Content-Type': 'application/json'},
            );
          }
          return Response.internalServerError(
            body: jsonEncode({'error': 'Failed to update user'}),
            headers: {'Content-Type': 'application/json'},
          );
        },
      );
    } catch (e) {
      return Response(
        400,
        body: jsonEncode({'error': 'Invalid request body'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// DELETE /users/:id - Soft delete de usuário (owner only).
  ///
  /// Apenas owners podem deletar usuários (incluindo outros owners).
  /// Admins NÃO podem deletar ninguém para evitar abuso de privilégios.
  Future<Response> _deleteUser(Request request, String id) async {
    if (id.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'User ID is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final authContext = request.context['authContext'] as AuthContext;

    // PROTEÇÃO: Apenas owner pode deletar usuários
    if (!authContext.role.isOwner) {
      return Response.forbidden(
        jsonEncode({
          'error': 'Only owners can delete users',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    // PROTEÇÃO ADICIONAL: Impedir auto-deleção acidental
    if (id == authContext.userId) {
      return Response(
        400,
        body: jsonEncode({
          'error': 'Cannot delete yourself. Transfer ownership first.',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final result = await userRepository.softDelete(id);

    return result.when(
      success: (_) {
        return Response(204, headers: {'Content-Type': 'application/json'});
      },
      failure: (exception) {
        if (exception is DataException) {
          return Response.notFound(
            jsonEncode({'error': exception.message}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to delete user'}),
          headers: {'Content-Type': 'application/json'},
        );
      },
    );
  }

  /// POST /users - Cria usuário administrativamente (owner only).
  ///
  /// Owner cria usuários sem senha inicial. Sistema gera hash aleatório
  /// e envia email para o usuário definir senha no primeiro acesso.
  Future<Response> _createUser(Request request) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final createModel = UserCreateAdminModel.fromJson(json);
      final createDto = createModel.toDomain();

      // Validar DTO
      final validator = UserCreateAdminValidator();
      final validationResult = validator.validate(createDto);

      if (!validationResult.isValid) {
        return Response(
          422,
          body: jsonEncode({
            'error': 'Validation failed',
            'details': validationResult.errors
                .map((e) => {'field': e.field, 'message': e.message})
                .toList(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // PROTEÇÃO: Apenas owner pode criar owners
      if (createDto.role == UserRole.owner && !authContext.role.isOwner) {
        return Response.forbidden(
          jsonEncode({
            'error': 'Only owners can create owner accounts',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Verificar unicidade de email
      if (await userRepository.emailExists(createDto.email)) {
        return Response(
          409,
          body: jsonEncode({'error': 'Email already exists'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Verificar unicidade de username
      if (await userRepository.usernameExists(createDto.username)) {
        return Response(
          409,
          body: jsonEncode({'error': 'Username already exists'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Criar usuário
      final result = await userRepository.createByAdmin(createDto);

      if (result case Failure(error: _)) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to create user'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = (result as Success<UserDetails>).value;

      // Enviar email de ativação (password reset)
      // Fire and forget - não bloqueia a resposta
      _authService.forgotPassword(user.email);

      // Retornar usuário criado
      final model = UserDetailsModel.fromDomain(user);
      return Response(
        201,
        body: jsonEncode(model.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(
        400,
        body: jsonEncode({'error': 'Invalid request body'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /users/:id/force-password-change - Força mudança de senha (admin+).
  ///
  /// Admin/owner marca usuário para mudar senha no próximo login.
  /// Admins não podem forçar em owners ou outros admins.
  Future<Response> _forcePasswordChange(Request request, String id) async {
    if (id.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'User ID is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final authContext = request.context['authContext'] as AuthContext;

    // Buscar usuário alvo
    final targetUserResult = await userRepository.findById(id);

    if (targetUserResult case Failure(error: _)) {
      return Response.notFound(
        jsonEncode({'error': 'User not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final targetUser = (targetUserResult as Success<UserDetails>).value;

    // PROTEÇÃO: Apenas owner pode forçar mudança em owners
    if (targetUser.role == UserRole.owner && !authContext.role.isOwner) {
      return Response.forbidden(
        jsonEncode({
          'error': 'Only owners can force password change on other owners',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    // PROTEÇÃO: Apenas owner pode forçar mudança em admins
    if (targetUser.role == UserRole.admin && !authContext.role.isOwner) {
      return Response.forbidden(
        jsonEncode({
          'error': 'Only owners can force password change on admins',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    // Definir mustChangePassword
    final result = await userRepository.setMustChangePassword(id, true);

    return result.when(
      success: (_) {
        return Response.ok(
          jsonEncode({
            'message': 'User will be required to change password on next login',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      },
      failure: (exception) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to set password change flag'}),
          headers: {'Content-Type': 'application/json'},
        );
      },
    );
  }

  /// POST /users/:id/reset-password - Inicia reset de senha (admin+).
  ///
  /// Admin/owner envia email de reset de senha para o usuário.
  /// Admins não podem resetar senha de owners.
  Future<Response> _adminResetPassword(Request request, String id) async {
    if (id.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'User ID is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final authContext = request.context['authContext'] as AuthContext;

    // Buscar usuário alvo
    final targetUserResult = await userRepository.findById(id);

    if (targetUserResult case Failure(error: _)) {
      return Response.notFound(
        jsonEncode({'error': 'User not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final targetUser = (targetUserResult as Success<UserDetails>).value;

    // PROTEÇÃO: Apenas owner pode resetar senha de owners
    if (targetUser.role == UserRole.owner && !authContext.role.isOwner) {
      return Response.forbidden(
        jsonEncode({
          'error': 'Only owners can reset password of other owners',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    // Enviar email de reset (reutiliza fluxo existente)
    await _authService.forgotPassword(targetUser.email);

    return Response.ok(
      jsonEncode({'message': 'Password reset email sent to user'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
