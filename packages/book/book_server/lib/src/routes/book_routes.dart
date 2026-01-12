import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' hide Route;
import 'package:core_shared/core_shared.dart';
import 'package:core_server/core_server.dart';
import 'package:open_api_shared/open_api_shared.dart' as open;
import 'package:book_shared/book_shared.dart';

@open.api
@open.Route(
  path: booksPath,  // ✅ Constant do _shared
  tag: 'Books',
  description: 'Operações relacionadas a Books',
)
class BookRoutes extends Routes with Loggable {
  final String _backendBaseApi;
  final BookRepository _repository;

  BookRoutes({
    required String backendBaseApi,
    required BookRepository repository,
    required super.security,
  }) : _backendBaseApi = backendBaseApi,
       _repository = repository;

  @override
  String get path => '$_backendBaseApi$booksPath';

  @override
  Router get router {
    final router = Router();
    
    router.get(booksPathById, getById);
    router.get(booksPathGetAll, getAll);
    router.post(booksPathCreate, create);
    router.put(booksPathUpdate, update);
    router.delete(booksPathDelete, delete);
    
    return router;
  }

  @open.Get(
    path: booksPathGetAll,
    summary: 'Obter lista de books',
    description: 'Retorna uma lista com todos os books cadastrados',
  )
  @open.Response(
    statusCode: 200,
    description: 'Lista de Books',
    returns: BookDetails,
  )
  Future<Response> getAll(Request request) async {
    final permission = PermissionHelper.checkPermission(
      request,
      owner: true,
      admin: true,
    );
    if (permission != null) return permission;

    final queryParams = request.url.queryParameters;
    final limit = queryParams.containsKey('limit')
        ? int.tryParse(queryParams['limit']!)
        : null;
    final offset = queryParams.containsKey('offset')
        ? int.tryParse(queryParams['offset']!)
        : null;
        
    final result = await _repository.getAll(limit: limit, offset: offset);

    return HttpResponseHelper.toResponse(
      result,
      onSuccess: (list) => EntityMapper.mapList(
        models: list,
        mapper: (a) => BookDetailsModel.fromDomain(a).toJson(),
      ),
    );
  }
  
  @open.Get(
    path: booksPathByIdOpenApi,
    summary: 'Obter Book pelo ID',
  )
  @open.PathParam(name: 'id')
  @open.Response(statusCode: 200, returns: BookDetails)
  Future<Response> getById(Request request, String id) async {
    final permission = PermissionHelper.checkPermission(
      request,
      owner: true,
      admin: true,
    );
    if (permission != null) return permission;

    final result = await _repository.getById(id);

    return HttpResponseHelper.toResponse(
      result,
      onSuccess: (entity) => BookDetailsModel.fromDomain(entity).toJson(),
    );
  }

  @open.Post(
    path: booksPathCreate,
    summary: 'Criar novo Book',
  )
  @open.Response(statusCode: 201, returns: BookDetails)
  Future<Response> create(Request request) async {
    final permission = PermissionHelper.checkPermission(
      request,
      owner: true,
      admin: true,
    );
    if (permission != null) return permission;

    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      final createModel = BookCreateModel.fromJson(data);
      final createDto = createModel.toDomain();

      final result = await _repository.create(createDto);

      return HttpResponseHelper.toResponse(
        result,
        successCode: 201,
        onSuccess: (entity) => BookDetailsModel.fromDomain(entity).toJson(),
      );
    } catch (e) {
      logger.severe('Erro ao processar requisição', e);
      return Response(
        400,
        body: json.encode({
          'error': 'Invalid request body',
          'details': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  @open.Put(
    path: booksPathUpdateOpenApi,
    summary: 'Atualizar Book',
  )
  @open.PathParam(name: 'id')
  @open.Response(statusCode: 200, returns: BookDetails)
  Future<Response> update(Request request, String id) async {
    final permission = PermissionHelper.checkPermission(
      request,
      owner: true,
      admin: true,
    );
    if (permission != null) return permission;

    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      final updateModel = BookUpdateModel.fromJson(data);
      final updateDto = updateModel.toDomain();

      final result = await _repository.update(updateDto);

      return HttpResponseHelper.toResponse(
        result,
        onSuccess: (entity) => BookDetailsModel.fromDomain(entity).toJson(),
      );
    } catch (e) {
      logger.severe('Erro ao processar requisição', e);
      return Response(
        400,
        body: json.encode({
          'error': 'Invalid request body',
          'details': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  @open.Delete(
    path: booksPathDeleteOpenApi,
    summary: 'Deletar Book',
  )
  @open.PathParam(name: 'id')
  @open.Response(statusCode: 200, returns: String)
  Future<Response> delete(Request request, String id) async {
    final permission = PermissionHelper.checkPermission(
      request,
      owner: true,
      admin: true,
    );
    if (permission != null) return permission;

    try {
      final result = await _repository.delete(id);

      return HttpResponseHelper.toResponse(
        result,
        onSuccess: (_) => {'message': 'Deleted Book $id'},
      );
    } catch (e) {
      logger.severe('Erro ao processar requisição', e);
      return Response(
        400,
        body: json.encode({
          'error': 'Invalid request body',
          'details': e.toString(),
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
