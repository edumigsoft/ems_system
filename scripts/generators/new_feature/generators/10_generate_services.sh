#!/bin/bash

# ============================================================================
# 10_generate_services.sh - Gera Retrofit Service
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=============================================="
echo "  Gerador de Retrofit Service"
echo "=============================================="
echo ""

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome da entidade (PascalCase)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

ask "Nome da entidade (plural)" ENTITY_PLURAL
validate_name "$ENTITY_PLURAL" || exit 1

FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENTITY_SNAKE=$(to_snake_case "$ENTITY_NAME")
ROOT=$(get_project_root)
CLIENT_PATH=$(get_client_package_path "$FEATURE_SNAKE")
SERVICE_FILE="$CLIENT_PATH/lib/src/services/${ENTITY_SNAKE}_service.dart"

validate_package_exists "$FEATURE_SNAKE" "client" || exit 1
ensure_dir "$(dirname "$SERVICE_FILE")"

progress "Gerando ${ENTITY_NAME}Service..."

cat > "$SERVICE_FILE" <<EOF
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:${FEATURE_SNAKE}_shared/${FEATURE_SNAKE}_shared.dart';

part '${ENTITY_SNAKE}_service.g.dart';

/// Service Retrofit para $ENTITY_NAME.
@RestApi()
abstract class ${ENTITY_NAME}Service {
  factory ${ENTITY_NAME}Service(Dio dio, {String baseUrl}) = _${ENTITY_NAME}Service;

  @GET('/$ENTITY_PLURAL')
  Future<List<${ENTITY_NAME}DetailsModel>> getAll({
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  @GET('/$ENTITY_PLURAL/{id}')
  Future<${ENTITY_NAME}DetailsModel> getById(@Path('id') String id);

  @POST('/$ENTITY_PLURAL')
  Future<${ENTITY_NAME}DetailsModel> create(
    @Body() ${ENTITY_NAME}CreateModel data,
  );

  @PUT('/$ENTITY_PLURAL/{id}')
  Future<${ENTITY_NAME}DetailsModel> update(
    @Path('id') String id,
    @Body() ${ENTITY_NAME}UpdateModel data,
  );

  @DELETE('/$ENTITY_PLURAL/{id}')
  Future<void> delete(@Path('id') String id);
}
EOF

success "Service gerada!"

# Atualiza barrel files automaticamente
progress "Atualizando barrel files do client..."
update_client_barrel_files "$FEATURE_SNAKE"

echo ""
warn "Lembre-se de:"
info "  1. Executar build_runner no pacote client"
info "  2. Registrar service no DI module"
