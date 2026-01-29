import 'dart:convert';

import 'package:auth_server/auth_server.dart' show AuthMiddleware;
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
  final AuthMiddleware _authMiddleware;
  final SchoolDetailsValidator _validator = const SchoolDetailsValidator();

  SchoolRoutes({
    required String backendBaseApi,
    required SchoolRepository repository,
    required AuthMiddleware authMiddleware,
    required super.security,
  }) : _backendBaseApi = backendBaseApi,
       _repository = repository,
       _authMiddleware = authMiddleware;

  @override
  String get path => '$_backendBaseApi$schoolsPath';

  @override
  Router get router {
    final router = Router();

    // Middleware de autenticação JWT (qualquer usuário autenticado)
    final authMiddleware = _authMiddleware.verifyJwt;

    // Middleware para admin+ (admin, owner)
    final adminMiddleware = _authMiddleware.requireRole(UserRole.admin);

    // Middleware para owner apenas
    final ownerMiddleware = _authMiddleware.requireRole(UserRole.owner);

    // Listar escolas - Qualquer usuário autenticado (read-only)
    router.get(
      schoolsPathGetAll,
      Pipeline().addMiddleware(authMiddleware).addHandler(getAll),
    );

    // Buscar escola por ID - Qualquer usuário autenticado (read-only)
    router.get(
      schoolsPathById,
      Pipeline()
          .addMiddleware(authMiddleware)
          .addHandler((req) => getById(req, req.params['id']!)),
    );

    // Criar escola - Admin+
    router.post(
      schoolsPathCreate,
      Pipeline().addMiddleware(adminMiddleware).addHandler(create),
    );

    // Atualizar escola - Admin+
    router.put(
      schoolsPathUpdate,
      Pipeline()
          .addMiddleware(adminMiddleware)
          .addHandler((req) => update(req, req.params['id']!)),
    );

    // Deletar escola - Owner apenas (operação sensível)
    router.delete(
      schoolsPathDelete,
      Pipeline()
          .addMiddleware(ownerMiddleware)
          .addHandler((req) => delete(req, req.params['id']!)),
    );

    return router;
  }

  @open.Get(
    path: schoolsPathGetAll,
    summary: 'Obter lista de todas as escolas',
    description:
        'Retorna uma lista com todas as escolas cadastradas. Requer autenticação (qualquer usuário).',
  )
  @open.Response(
    statusCode: 200,
    description: 'Lista de Schools',
    returns: SchoolDetails,
  )
  Future<Response> getAll(Request request) async {
    logger.info('GET /schools - Listando escolas');

    final queryParams = request.url.queryParameters;
    final limit = queryParams.containsKey('limit')
        ? int.tryParse(queryParams['limit']!)
        : null;
    final offset = queryParams.containsKey('offset')
        ? int.tryParse(queryParams['offset']!)
        : null;
    final search = queryParams['search'];

    final result = await _repository.getAll(
      limit: limit,
      offset: offset,
      search: search,
    );

    return HttpResponseHelper.toResponse(
      result,
      onSuccess: (paginatedResult) => {
        'data': EntityMapper.mapList(
          models: paginatedResult.items,
          mapper: (a) => SchoolDetailsModel.fromDomain(a).toJson(),
        ),
        'total': paginatedResult.total,
        'page': paginatedResult.page,
        'limit': paginatedResult.limit,
        'totalPages': paginatedResult.totalPages,
        'hasNextPage': paginatedResult.hasNextPage,
        'hasPreviousPage': paginatedResult.hasPreviousPage,
      },
    );
  }

  @open.Get(
    path: schoolsPathByIdOpenApi,
    summary: 'Obter School pelo id',
    description:
        'Retorna uma School pelo id. Requer autenticação (qualquer usuário).',
  )
  @open.PathParam(name: 'id')
  @open.Response(statusCode: 200, description: 'School', returns: SchoolDetails)
  Future<Response> getById(Request request, String id) async {
    logger.info('GET /schools/$id - Buscando escola');

    final result = await _repository.getById(id);

    return HttpResponseHelper.toResponse(
      result,
      onSuccess: (school) => SchoolDetailsModel.fromDomain(school).toJson(),
    );
  }

  @open.Post(
    path: schoolsPathCreate,
    summary: 'Criar uma nova escola',
    description:
        'Cria uma nova escola no sistema. Requer permissão de Admin ou superior.',
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
    logger.info('POST /schools - Criando nova escola');

    try {
      final body = await request.readAsString();
      final data = json.decode(body) as Map<String, dynamic>;
      final schoolCreateModel = SchoolCreateModel.fromJson(data);
      final schoolCreate = schoolCreateModel.toDomain();

      // Criar SchoolDetails temporário para validação
      final tempSchool = SchoolDetails.fromData(
        id: 'temp',
        data: School(
          name: schoolCreate.name,
          address: schoolCreate.address,
          phone: schoolCreate.phone,
          email: schoolCreate.email,
          code: schoolCreate.code,
          locationCity: schoolCreate.locationCity,
          locationDistrict: schoolCreate.locationDistrict,
          director: schoolCreate.director,
          status: schoolCreate.status,
        ),
      );

      // Validação server-side
      final validation = _validator.validate(tempSchool);
      if (!validation.isValid) {
        logger.warning(
          'Validação falhou ao criar escola: ${validation.errors}',
        );
        return Response(
          400,
          body: json.encode({
            'error': 'Dados inválidos',
            'details': validation.errors
                .map((e) => {'field': e.field, 'message': e.message})
                .toList(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _repository.create(schoolCreate);

      return HttpResponseHelper.toResponse(
        result,
        successCode: 201,
        onSuccess: (school) {
          logger.info('Escola criada com sucesso: ${school.id}');
          return SchoolDetailsModel.fromDomain(school).toJson();
        },
      );
    } catch (e) {
      logger.severe('Erro ao processar requisição de criação', e);
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
    description:
        'Atualiza os dados de uma escola pelo ID. Requer permissão de Admin ou superior.',
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
    logger.info('PUT /schools/$id - Atualizando escola');

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
        code: schoolRequest.code,
        locationCity: schoolRequest.locationCity,
        locationDistrict: schoolRequest.locationDistrict,
        director: schoolRequest.director,
        status: schoolRequest.status,
        updatedAt: schoolRequest.updatedAt,
      );

      // Validação server-side
      final validation = _validator.validate(schoolDetails);
      if (!validation.isValid) {
        logger.warning(
          'Validação falhou ao atualizar escola: ${validation.errors}',
        );
        return Response(
          400,
          body: json.encode({
            'error': 'Dados inválidos',
            'details': validation.errors
                .map((e) => {'field': e.field, 'message': e.message})
                .toList(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final result = await _repository.update(schoolDetails);

      return HttpResponseHelper.toResponse(
        result,
        onSuccess: (school) {
          logger.info('Escola atualizada com sucesso: ${school.id}');
          return SchoolDetailsModel.fromDomain(school).toJson();
        },
      );
    } catch (e) {
      logger.severe('Erro ao processar requisição de atualização', e);
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
    description:
        'Deleta os dados de uma escola pelo ID (soft delete). Requer permissão de Owner.',
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
    logger.info('DELETE /schools/$id - Deletando escola (owner apenas)');

    try {
      final result = await _repository.delete(id);

      return HttpResponseHelper.toResponse(
        result,
        onSuccess: (_) {
          logger.info('Escola deletada com sucesso: $id');
          return {'message': 'Deleted School $id'};
        },
      );
    } catch (e) {
      logger.severe('Erro ao processar requisição de deleção', e);
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
