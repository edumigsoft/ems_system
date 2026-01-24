import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:tag_shared/tag_shared.dart';
import 'package:postgres/postgres.dart' as pg;

/// Handler for tag REST API endpoints.
///
/// Provides CRUD operations for tags using raw PostgreSQL queries.
/// This approach avoids Drift code generation complexity.
class TagHandler {
  final pg.Connection _conn;

  /// Creates a TagHandler instance.
  TagHandler(this._conn);

  /// Configures routes for tag endpoints.
  Router get router {
    final router = Router();

    router.post('/tags', _createTag);
    router.get('/tags', _getAllTags);
    router.get('/tags/<id>', _getTagById);
    router.put('/tags/<id>', _updateTag);
    router.delete('/tags/<id>', _deleteTag);
    router.post('/tags/<id>/restore', _restoreTag);

    return router;
  }

  /// POST /tags - Creates a new tag.
  Future<Response> _createTag(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      // Deserialize and validate
      final createModel = TagCreateModel.fromJson(json);
      final createDto = createModel.toDomain();

      // Server-side validation
      final validator = TagCreateValidator();
      final validationResult = validator.validate(createDto);

      if (validationResult.isInvalid) {
        return Response(
          400,
          body: jsonEncode({
            'error': 'Validation failed',
            'details': validationResult.errors
                .map((e) => {'field': e.field, 'message': e.message})
                .toList(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Insert into database
      final result = await _conn.execute(
        pg.Sql.named('''
          INSERT INTO tags (name, description, color, usage_count, is_deleted, is_active, created_at, updated_at)
          VALUES (@name, @description, @color, @usageCount, @isDeleted, @isActive, @createdAt, @updatedAt)
          RETURNING id, name, description, color, usage_count, is_deleted, is_active, created_at, updated_at
        '''),
        parameters: {
          'name': createDto.name,
          'description': createDto.description,
          'color': createDto.color,
          'usageCount': 0,
          'isDeleted': false,
          'isActive': true,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
      );

      if (result.isEmpty) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to create tag'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first;
      final details = TagDetails(
        id: row[0] as String,
        isDeleted: row[5] as bool,
        isActive: row[6] as bool,
        createdAt: row[7] as DateTime,
        updatedAt: row[8] as DateTime,
        name: row[1] as String,
        description: row[2] as String?,
        color: row[3] as String?,
        usageCount: row[4] as int,
      );

      final detailsModel = TagDetailsModel(details);
      return Response.ok(
        jsonEncode(detailsModel.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create tag: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /tags - Retrieves all tags with optional filters.
  Future<Response> _getAllTags(Request request) async {
    try {
      final params = request.url.queryParameters;
      final activeOnly = params['active_only'] != 'false'; // Default true
      final search = params['search'];

      final whereConditions = <String>[];
      final parameters = <String, dynamic>{};

      if (activeOnly) {
        whereConditions.add('is_active = @isActive AND is_deleted = @isDeleted');
        parameters['isActive'] = true;
        parameters['isDeleted'] = false;
      }

      if (search != null && search.isNotEmpty) {
        whereConditions.add('name ILIKE @search');
        parameters['search'] = '%$search%';
      }

      final whereClause = whereConditions.isNotEmpty
          ? 'WHERE ${whereConditions.join(' AND ')}'
          : '';

      final result = await _conn.execute(
        pg.Sql.named('''
          SELECT id, name, description, color, usage_count, is_deleted, is_active, created_at, updated_at
          FROM tags
          $whereClause
          ORDER BY name
        '''),
        parameters: parameters,
      );

      final tags = result.map((row) {
        final details = TagDetails(
          id: row[0] as String,
          isDeleted: row[5] as bool,
          isActive: row[6] as bool,
          createdAt: row[7] as DateTime,
          updatedAt: row[8] as DateTime,
          name: row[1] as String,
          description: row[2] as String?,
          color: row[3] as String?,
          usageCount: row[4] as int,
        );
        return TagDetailsModel(details).toJson();
      }).toList();

      return Response.ok(
        jsonEncode(tags),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch tags: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /tags/:id - Retrieves a tag by ID.
  Future<Response> _getTagById(Request request, String id) async {
    try {
      final result = await _conn.execute(
        pg.Sql.named('''
          SELECT id, name, description, color, usage_count, is_deleted, is_active, created_at, updated_at
          FROM tags
          WHERE id = @id
        '''),
        parameters: {'id': id},
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Tag not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first;
      final details = TagDetails(
        id: row[0] as String,
        isDeleted: row[5] as bool,
        isActive: row[6] as bool,
        createdAt: row[7] as DateTime,
        updatedAt: row[8] as DateTime,
        name: row[1] as String,
        description: row[2] as String?,
        color: row[3] as String?,
        usageCount: row[4] as int,
      );

      final model = TagDetailsModel(details);
      return Response.ok(
        jsonEncode(model.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to fetch tag: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// PUT /tags/:id - Updates a tag.
  Future<Response> _updateTag(Request request, String id) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      // Deserialize and validate
      json['id'] = id; // Ensure ID from URL
      final updateModel = TagUpdateModel.fromJson(json);
      final updateDto = updateModel.toDomain();

      // Server-side validation
      final validator = TagUpdateValidator();
      final validationResult = validator.validate(updateDto);

      if (validationResult.isInvalid) {
        return Response(
          400,
          body: jsonEncode({
            'error': 'Validation failed',
            'details': validationResult.errors
                .map((e) => {'field': e.field, 'message': e.message})
                .toList(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Build SET clause dynamically based on provided fields
      final setClauses = <String>[];
      final parameters = <String, dynamic>{'id': id, 'updatedAt': DateTime.now()};

      if (updateDto.name != null) {
        setClauses.add('name = @name');
        parameters['name'] = updateDto.name;
      }
      if (updateDto.description != null) {
        setClauses.add('description = @description');
        parameters['description'] = updateDto.description;
      }
      if (updateDto.color != null) {
        setClauses.add('color = @color');
        parameters['color'] = updateDto.color;
      }
      if (updateDto.isActive != null) {
        setClauses.add('is_active = @isActive');
        parameters['isActive'] = updateDto.isActive;
      }
      if (updateDto.isDeleted != null) {
        setClauses.add('is_deleted = @isDeleted');
        parameters['isDeleted'] = updateDto.isDeleted;
      }

      setClauses.add('updated_at = @updatedAt');

      final result = await _conn.execute(
        pg.Sql.named('''
          UPDATE tags
          SET ${setClauses.join(', ')}
          WHERE id = @id
          RETURNING id, name, description, color, usage_count, is_deleted, is_active, created_at, updated_at
        '''),
        parameters: parameters,
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Tag not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first;
      final details = TagDetails(
        id: row[0] as String,
        isDeleted: row[5] as bool,
        isActive: row[6] as bool,
        createdAt: row[7] as DateTime,
        updatedAt: row[8] as DateTime,
        name: row[1] as String,
        description: row[2] as String?,
        color: row[3] as String?,
        usageCount: row[4] as int,
      );

      final detailsModel = TagDetailsModel(details);
      return Response.ok(
        jsonEncode(detailsModel.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update tag: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// DELETE /tags/:id - Soft deletes a tag.
  Future<Response> _deleteTag(Request request, String id) async {
    try {
      final result = await _conn.execute(
        pg.Sql.named('''
          UPDATE tags
          SET is_deleted = @isDeleted, updated_at = @updatedAt
          WHERE id = @id
        '''),
        parameters: {
          'id': id,
          'isDeleted': true,
          'updatedAt': DateTime.now(),
        },
      );

      if (result.affectedRows == 0) {
        return Response.notFound(
          jsonEncode({'error': 'Tag not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({'message': 'Tag deleted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete tag: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /tags/:id/restore - Restores a soft-deleted tag.
  Future<Response> _restoreTag(Request request, String id) async {
    try {
      final result = await _conn.execute(
        pg.Sql.named('''
          UPDATE tags
          SET is_deleted = @isDeleted, updated_at = @updatedAt
          WHERE id = @id
        '''),
        parameters: {
          'id': id,
          'isDeleted': false,
          'updatedAt': DateTime.now(),
        },
      );

      if (result.affectedRows == 0) {
        return Response.notFound(
          jsonEncode({'error': 'Tag not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({'message': 'Tag restored successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to restore tag: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}

/// Initializes tag module routes in the server.
///
/// Call this function to register tag endpoints in your server router.
void initTagModuleToServer(Router router, pg.Connection conn) {
  final handler = TagHandler(conn);
  router.mount('/tags', handler.router.call);
}
