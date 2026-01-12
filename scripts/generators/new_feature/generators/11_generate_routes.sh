#!/bin/bash

# ============================================================================
# 11_generate_routes.sh - Gera Shelf Routes (NÃO handlers)
# ============================================================================
#
# Responsabilidade: Gera Routes que ESTENDEM Routes do core_server.
#
# Regras Arquiteturais:
# - Extends Routes (não handler genérico)
# - Usa mixin Loggable
# - Usa constants de rotas do _shared
# - Anotações OpenAPI
#
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=================================================="
echo "  Gerador de Shelf Routes"
echo "=================================================="
echo ""

progress "Coletando informações..."

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome da entidade (PascalCase)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

ask "Nome da entidade (plural, ex: books)" ENTITY_PLURAL
validate_name "$ENTITY_PLURAL" || exit 1

# Preparação
FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENTITY_SNAKE=$(to_snake_case "$ENTITY_NAME")
ROOT=$(get_project_root)
SERVER_PATH=$(get_server_package_path "$FEATURE_SNAKE")
ROUTES_DIR="$SERVER_PATH/lib/src/routes"
ROUTES_FILE="$ROUTES_DIR/${ENTITY_SNAKE}_routes.dart"

validate_package_exists "$FEATURE_SNAKE" "server" || exit 1
ensure_dir "$ROUTES_DIR"

progress "Gerando ${ENTITY_NAME}Routes..."

# Nomes de constants
UPPER_PLURAL=$(echo "$ENTITY_PLURAL" | sed 's/_//g')

cat > "$ROUTES_FILE" <<EOF
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' hide Route;
import 'package:core_shared/core_shared.dart';
import 'package:core_server/core_server.dart';
import 'package:open_api_shared/open_api_shared.dart' as open;
import 'package:${FEATURE_SNAKE}_shared/${FEATURE_SNAKE}_shared.dart';

@open.api
@open.Route(
  path: ${ENTITY_PLURAL}Path,  // ✅ Constant do _shared
  tag: '${ENTITY_NAME}s',
  description: 'Operações relacionadas a ${ENTITY_NAME}s',
)
class ${ENTITY_NAME}Routes extends Routes with Loggable {
  final String _backendBaseApi;
  final ${ENTITY_NAME}Repository _repository;

  ${ENTITY_NAME}Routes({
    required String backendBaseApi,
    required ${ENTITY_NAME}Repository repository,
    required super.security,
  }) : _backendBaseApi = backendBaseApi,
       _repository = repository;

  @override
  String get path => '\$_backendBaseApi\$${ENTITY_PLURAL}Path';

  @override
  Router get router {
    final router = Router();
    
    router.get(${ENTITY_PLURAL}PathById, getById);
    router.get(${ENTITY_PLURAL}PathGetAll, getAll);
    router.post(${ENTITY_PLURAL}PathCreate, create);
    router.put(${ENTITY_PLURAL}PathUpdate, update);
    router.delete(${ENTITY_PLURAL}PathDelete, delete);
    
    return router;
  }

  @open.Get(
    path: ${ENTITY_PLURAL}PathGetAll,
    summary: 'Obter lista de ${ENTITY_PLURAL}',
    description: 'Retorna uma lista com todos os ${ENTITY_PLURAL} cadastrados',
  )
  @open.Response(
    statusCode: 200,
    description: 'Lista de ${ENTITY_NAME}s',
    returns: ${ENTITY_NAME}Details,
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
        mapper: (a) => ${ENTITY_NAME}DetailsModel.fromDomain(a).toJson(),
      ),
    );
  }
  
  @open.Get(
    path: ${ENTITY_PLURAL}PathByIdOpenApi,
    summary: 'Obter ${ENTITY_NAME} pelo ID',
  )
  @open.PathParam(name: 'id')
  @open.Response(statusCode: 200, returns: ${ENTITY_NAME}Details)
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
      onSuccess: (entity) => ${ENTITY_NAME}DetailsModel.fromDomain(entity).toJson(),
    );
  }

  @open.Post(
    path: ${ENTITY_PLURAL}PathCreate,
    summary: 'Criar novo ${ENTITY_NAME}',
  )
  @open.Response(statusCode: 201, returns: ${ENTITY_NAME}Details)
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
      final createModel = ${ENTITY_NAME}CreateModel.fromJson(data);
      final createDto = createModel.toDomain();

      final result = await _repository.create(createDto);

      return HttpResponseHelper.toResponse(
        result,
        successCode: 201,
        onSuccess: (entity) => ${ENTITY_NAME}DetailsModel.fromDomain(entity).toJson(),
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
    path: ${ENTITY_PLURAL}PathUpdateOpenApi,
    summary: 'Atualizar ${ENTITY_NAME}',
  )
  @open.PathParam(name: 'id')
  @open.Response(statusCode: 200, returns: ${ENTITY_NAME}Details)
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
      final updateModel = ${ENTITY_NAME}UpdateModel.fromJson(data);
      final updateDto = updateModel.toDomain();

      final result = await _repository.update(updateDto);

      return HttpResponseHelper.toResponse(
        result,
        onSuccess: (entity) => ${ENTITY_NAME}DetailsModel.fromDomain(entity).toJson(),
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
    path: ${ENTITY_PLURAL}PathDeleteOpenApi,
    summary: 'Deletar ${ENTITY_NAME}',
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
        onSuccess: (_) => {'message': 'Deleted ${ENTITY_NAME} \$id'},
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
EOF

success "Routes gerada com sucesso!"
info "Arquivo: $ROUTES_FILE"

# Atualiza barrel files automaticamente
progress "Atualizando barrel files do server..."
update_server_barrel_files "$FEATURE_SNAKE"

echo ""
warn "Lembre-se de:"
info "  1. Importar as constants de rotas"
info "  2. Registrar as routes no servidor principal"
