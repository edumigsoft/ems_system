import 'dart:convert';
import 'package:auth_server/auth_server.dart' show AuthMiddleware;
import 'package:auth_shared/auth_shared.dart' show AuthContext;
import 'package:core_server/core_server.dart' show Routes;
import 'package:core_shared/core_shared.dart'
    show DependencyInjector, StorageException;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:tag_shared/tag_shared.dart'
    show
        TagDetailsModel,
        TagCreateModel,
        TagUpdateModel,
        TagCreateValidator,
        TagUpdateValidator,
        TagRepository;

/// Rotas de gerenciamento de tags.
///
/// **Endpoints Públicos (autenticado):**
/// - GET /tags - Listar tags
/// - GET /tags/:id - Buscar tag por ID
/// - POST /tags - Criar tag
/// - PUT /tags/:id - Atualizar tag
/// - DELETE /tags/:id - Soft delete de tag
/// - POST /tags/:id/restore - Restaurar tag deletada
class TagRoutes extends Routes {
  final TagRepository tagRepository;
  final AuthMiddleware authMiddleware;
  final DependencyInjector di;
  final String _backendBaseApi;

  TagRoutes(
    this.tagRepository,
    this.authMiddleware,
    this.di, {
    required String backendBaseApi,
  }) : _backendBaseApi = backendBaseApi,
       super(security: true);

  @override
  String get path => '$_backendBaseApi/tags';

  @override
  Router get router {
    final router = Router();

    // Todas as rotas requerem autenticação
    final authPipeline = Pipeline().addMiddleware(authMiddleware.verifyJwt);

    router.get(
      '/',
      authPipeline.addHandler(_getAllTags),
    );

    router.get(
      '/<id>',
      authPipeline.addHandler((req) => _getTagById(req, req.params['id']!)),
    );

    router.post(
      '/',
      authPipeline.addHandler(_createTag),
    );

    router.put(
      '/<id>',
      authPipeline.addHandler((req) => _updateTag(req, req.params['id']!)),
    );

    router.delete(
      '/<id>',
      authPipeline.addHandler((req) => _deleteTag(req, req.params['id']!)),
    );

    router.post(
      '/<id>/restore',
      authPipeline.addHandler((req) => _restoreTag(req, req.params['id']!)),
    );

    return router;
  }

  /// GET /tags - Retrieves all tags with optional filters.
  Future<Response> _getAllTags(Request request) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final params = request.url.queryParameters;
      final activeOnly = params['active_only'] != 'false'; // Default true
      final search = params['search'];

      final result = await tagRepository.getAll(
        activeOnly: activeOnly,
        search: search,
      );

      return result.when(
        success: (tags) {
          final models = tags
              .map((tag) => TagDetailsModel.fromDomain(tag).toJson())
              .toList();
          return Response.ok(
            jsonEncode(models),
            headers: {'Content-Type': 'application/json'},
          );
        },
        failure: (exception) {
          return Response.internalServerError(
            body: jsonEncode({'error': 'Failed to fetch tags'}),
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

  /// GET /tags/:id - Retrieves a tag by ID.
  Future<Response> _getTagById(Request request, String id) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (id.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'Tag ID is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final result = await tagRepository.getById(id);

    return result.when(
      success: (tag) {
        final model = TagDetailsModel.fromDomain(tag);
        return Response.ok(
          jsonEncode(model.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      },
      failure: (exception) {
        if (exception is StorageException) {
          return Response.notFound(
            jsonEncode({'error': 'Tag not found'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to fetch tag'}),
          headers: {'Content-Type': 'application/json'},
        );
      },
    );
  }

  /// POST /tags - Creates a new tag.
  Future<Response> _createTag(Request request) async {
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

      // Deserialize and validate
      final createModel = TagCreateModel.fromJson(json);
      final createDto = createModel.toDomain();

      // Server-side validation
      final validator = TagCreateValidator();
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

      final result = await tagRepository.create(createDto);

      return result.when(
        success: (tag) {
          final model = TagDetailsModel.fromDomain(tag);
          return Response(
            201,
            body: jsonEncode(model.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        },
        failure: (exception) {
          return Response.internalServerError(
            body: jsonEncode({'error': 'Failed to create tag'}),
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

  /// PUT /tags/:id - Updates a tag.
  Future<Response> _updateTag(Request request, String id) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (id.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'Tag ID is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      // Ensure ID from URL
      json['id'] = id;
      final updateModel = TagUpdateModel.fromJson(json);
      final updateDto = updateModel.toDomain();

      // Server-side validation
      final validator = TagUpdateValidator();
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

      final result = await tagRepository.update(updateDto);

      return result.when(
        success: (tag) {
          final model = TagDetailsModel.fromDomain(tag);
          return Response.ok(
            jsonEncode(model.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        },
        failure: (exception) {
          if (exception is StorageException) {
            return Response.notFound(
              jsonEncode({'error': 'Tag not found'}),
              headers: {'Content-Type': 'application/json'},
            );
          }
          return Response.internalServerError(
            body: jsonEncode({'error': 'Failed to update tag'}),
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

  /// DELETE /tags/:id - Soft deletes a tag.
  Future<Response> _deleteTag(Request request, String id) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (id.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'Tag ID is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final result = await tagRepository.delete(id);

    return result.when(
      success: (_) {
        return Response.ok(
          jsonEncode({'message': 'Tag deleted successfully'}),
          headers: {'Content-Type': 'application/json'},
        );
      },
      failure: (exception) {
        if (exception is StorageException) {
          return Response.notFound(
            jsonEncode({'error': 'Tag not found'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to delete tag'}),
          headers: {'Content-Type': 'application/json'},
        );
      },
    );
  }

  /// POST /tags/:id/restore - Restores a soft-deleted tag.
  Future<Response> _restoreTag(Request request, String id) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (id.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'Tag ID is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final result = await tagRepository.restore(id);

    return result.when(
      success: (_) {
        return Response.ok(
          jsonEncode({'message': 'Tag restored successfully'}),
          headers: {'Content-Type': 'application/json'},
        );
      },
      failure: (exception) {
        if (exception is StorageException) {
          return Response.notFound(
            jsonEncode({'error': 'Tag not found'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to restore tag'}),
          headers: {'Content-Type': 'application/json'},
        );
      },
    );
  }
}
