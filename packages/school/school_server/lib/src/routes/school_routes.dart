import 'dart:convert';

import 'package:core_server/core_server.dart';
import 'package:open_api_shared/open_api_shared.dart' as open;
import 'package:school_shared/school_shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' hide Route;

@open.api
@open.Route(
  path: schoolsPath,
  tag: 'Schools',
  description: 'Operações relacionadas a Schools',
)
class SchoolRoutes extends Routes with Loggable {
  final String _backendBaseApi;
  final SchoolRepository _repository;

  SchoolRoutes({
    required String backendBaseApi,
    required SchoolRepository repository,
    required super.security,
  }) : _backendBaseApi = backendBaseApi,
       _repository = repository;

  @override
  String get path => '$_backendBaseApi$schoolsPath';

  @override
  Router get router {
    final router = Router();

    router.get(schoolsPathById, getById);

    router.get(schoolsPathGetAll, getAll);

    router.post(schoolsPathCreate, create);

    router.put(schoolsPathUpdate, update);

    router.delete(schoolsPathDelete, delete);

    return router;
  }

  @open.Get(
    path: schoolsPathGetAll,
    summary: 'Obter lista de todas as escolas',
    description: 'Retorna uma lista com todas as escolas cadastradas',
  )
  @open.Response(
    statusCode: 200,
    description: 'Lista de Schools',
    returns: SchoolDetails,
  )
  Future<Response> getAll(Request request) async {
    // final permission = PermissionHelper.checkPermission(
    //   request,
    //   owner: true,
    //   admin: true,
    //   manager: true,
    //   teacher: true,
    //   aoe: true,
    // );
    // if (permission != null) {
    //   return permission;
    // }

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
        mapper: (a) => SchoolDetailsModel.fromDomain(a).toJson(),
      ),
    );
  }

  @open.Get(
    path: schoolsPathByIdOpenApi,
    summary: 'Obter School pelo id',
    description: 'Retorna uma School pelo id',
  )
  @open.PathParam(name: 'id')
  @open.Response(statusCode: 200, description: 'School', returns: SchoolDetails)
  Future<Response> getById(Request request, String id) async {
    // final permission = PermissionHelper.checkPermission(
    //   request,
    //   owner: true,
    //   admin: true,
    //   manager: true,
    //   teacher: true,
    //   aoe: true,
    // );
    // if (permission != null) {
    //   return permission;
    // }

    final result = await _repository.getById(id);

    return HttpResponseHelper.toResponse(
      result,
      onSuccess: (school) => SchoolDetailsModel.fromDomain(school).toJson(),
    );
  }

  @open.Post(
    path: schoolsPathCreate,
    summary: 'Criar uma nova escola',
    description: 'Cria uma nova escola no sistema',
  )
  @open.Response(
    statusCode: 201,
    description: 'School criada com sucesso',
    returns: SchoolDetails,
  )
  @open.Response(
    statusCode: 400,
    description: 'Dados inválidos',
    returns: String,
  )
  Future<Response> create(Request request) async {
    // final permission = PermissionHelper.checkPermission(
    //   request,
    //   owner: true,
    //   admin: true,
    // );
    // if (permission != null) {
    //   return permission;
    // }

    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      final schoolCreateModel = SchoolCreateModel.fromJson(data);
      // fromDomain is not available in SchoolCreate (pure), but toDomain is available in Model.
      // Wait, repository.create expects SchoolCreate.
      // So use schoolCreateModel.toDomain().
      final schoolCreate = schoolCreateModel.toDomain();

      final result = await _repository.create(schoolCreate);

      return HttpResponseHelper.toResponse(
        result,
        successCode: 201,
        onSuccess: (school) => SchoolDetailsModel.fromDomain(school).toJson(),
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
    path: schoolsPathUpdateOpenApi,
    summary: 'Atualizar uma escola existente',
    description: 'Atualiza os dados de uma escola pelo ID',
  )
  @open.PathParam(name: 'id')
  @open.Body()
  @open.Response(
    statusCode: 200,
    description: 'School atualizada com sucesso',
    returns: SchoolDetails,
  )
  @open.Response(
    statusCode: 400,
    description: 'Dados inválidos',
    returns: String,
  )
  @open.Response(
    statusCode: 404,
    description: 'School não encontrada',
    returns: String,
  )
  Future<Response> update(Request request, String id) async {
    // final permission = PermissionHelper.checkPermission(
    //   request,
    //   owner: true,
    //   admin: true,
    // );
    // if (permission != null) {
    //   return permission;
    // }

    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      final schoolRequestModel = SchoolDetailsModel.fromJson(data);
      final schoolRequest = schoolRequestModel.toDomain();

      final schoolDetails = SchoolDetails(
        id: id,
        isDeleted: schoolRequest.isDeleted,
        isActive: schoolRequest.isActive,
        createdAt: schoolRequest.createdAt,
        name: schoolRequest.name,
        address: schoolRequest.address,
        phone: schoolRequest.phone,
        email: schoolRequest.email,
        cie: schoolRequest.cie,
        updatedAt: schoolRequest.updatedAt,
      );

      final result = await _repository.update(schoolDetails);

      return HttpResponseHelper.toResponse(
        result,
        onSuccess: (school) => SchoolDetailsModel.fromDomain(school).toJson(),
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
    path: schoolsPathDeleteOpenApi,
    summary: 'Deleta uma escola existente',
    description: 'Deleta os dados de uma escola pelo ID',
  )
  @open.PathParam(name: 'id')
  @open.Body()
  @open.Response(
    statusCode: 200,
    description: 'School deletada com sucesso',
    returns: String,
  )
  @open.Response(
    statusCode: 400,
    description: 'Dados inválidos',
    returns: String,
  )
  @open.Response(
    statusCode: 404,
    description: 'School não encontrada',
    returns: String,
  )
  Future<Response> delete(Request request, String id) async {
    // final permission = PermissionHelper.checkPermission(
    //   request,
    //   owner: true,
    //   admin: true,
    // );
    // if (permission != null) {
    //   return permission;
    // }

    try {
      final result = await _repository.delete(id);

      return HttpResponseHelper.toResponse(
        result,
        onSuccess: (_) => {'message': 'Deleted School $id'},
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
