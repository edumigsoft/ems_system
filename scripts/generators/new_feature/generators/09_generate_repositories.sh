#!/bin/bash

# ============================================================================
# 09_generate_repositories.sh - Gera Repository interface + implementações
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

# Flags de controle
INTERFACE_ONLY=false
IMPLEMENTATION_ONLY=false

# Parse de argumentos opcionais
while [[ $# -gt 0 ]]; do
  case "$1" in
    --interface-only) INTERFACE_ONLY=true; shift ;;
    --implementation-only) IMPLEMENTATION_ONLY=true; shift ;;
    *) break ;; # Para de processar flags quando encontrar algo que não é flag
  esac
done

echo "=============================================="
echo "  Gerador de Repositories"
echo "=============================================="
echo ""

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome da entidade (PascalCase)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENTITY_SNAKE=$(to_snake_case "$ENTITY_NAME")
ROOT=$(get_project_root)
SHARED_PATH=$(get_shared_package_path "$FEATURE_SNAKE")
CLIENT_PATH=$(get_client_package_path "$FEATURE_SNAKE")
SERVER_PATH=$(get_server_package_path "$FEATURE_SNAKE")

validate_package_exists "$FEATURE_SNAKE" "shared" || exit 1

# ============================================================================
# 1. Generation Interface (Shared)
# ============================================================================
if [ "$IMPLEMENTATION_ONLY" != "true" ]; then
  # Interface no _shared
  REPO_INTERFACE="$SHARED_PATH/lib/src/domain/repositories/${ENTITY_SNAKE}_repository.dart"
  ensure_dir "$(dirname "$REPO_INTERFACE")"

  progress "Gerando ${ENTITY_NAME}Repository interface..."

  cat > "$REPO_INTERFACE" <<EOF
import 'package:core_shared/core_shared.dart';
import '../entities/${ENTITY_SNAKE}_details.dart';
import '../dtos/${ENTITY_SNAKE}_create.dart';
import '../dtos/${ENTITY_SNAKE}_update.dart';

/// Repository para operações CRUD de $ENTITY_NAME.
abstract class ${ENTITY_NAME}Repository {
  Future<Result<List<${ENTITY_NAME}Details>>> getAll({int? limit, int? offset});
  Future<Result<${ENTITY_NAME}Details>> getById(String id);
  Future<Result<${ENTITY_NAME}Details>> create(${ENTITY_NAME}Create data);
  Future<Result<${ENTITY_NAME}Details>> update(${ENTITY_NAME}Update data);
  Future<Result<void>> delete(String id);
}
EOF

  success "Repository interface gerada!"
fi

# ============================================================================
# 2. Client Implementation
# ============================================================================
if [ "$INTERFACE_ONLY" != "true" ]; then
  # Client implementation
  if validate_package_exists "$FEATURE_SNAKE" "client" 2>/dev/null; then
    CLIENT_REPO="$CLIENT_PATH/lib/src/repositories/${ENTITY_SNAKE}_repository_client.dart"
    ensure_dir "$(dirname "$CLIENT_REPO")"
    
    progress "Gerando ${ENTITY_NAME}RepositoryClient..."
    
    cat > "$CLIENT_REPO" <<EOF
import 'package:core_shared/core_shared.dart';
import 'package:core_client/core_client.dart';
import 'package:${FEATURE_SNAKE}_shared/${FEATURE_SNAKE}_shared.dart';
import '../services/${ENTITY_SNAKE}_service.dart';

/// Implementação client do ${ENTITY_NAME}Repository.
class ${ENTITY_NAME}RepositoryClient extends BaseRepositoryLocal 
    implements ${ENTITY_NAME}Repository {
  final ${ENTITY_NAME}Service _service;
  final ${ENTITY_NAME}DetailsConverter _converter = 
      const ${ENTITY_NAME}DetailsConverter();

  ${ENTITY_NAME}RepositoryClient(this._service);

  @override
  Future<Result<List<${ENTITY_NAME}Details>>> getAll({
    int? limit,
    int? offset,
  }) async {
    return executeListRequest(
      request: () => _service.getAll(limit: limit, offset: offset),
      context: 'get all ${ENTITY_PLURAL}',
      mapper: _converter.toDomain,
    );
  }

  @override
  Future<Result<${ENTITY_NAME}Details>> getById(String id) async {
    return executeRequest(
      request: () => _service.getById(id),
      context: 'get ${ENTITY_NAME} by id',
      mapper: _converter.toDomain,
    );
  }

  @override
  Future<Result<${ENTITY_NAME}Details>> create(${ENTITY_NAME}Create data) async {
    return executeRequest(
      request: () async {
        final model = ${ENTITY_NAME}CreateModel.fromDomain(data);
        return _service.create(model);
      },
      context: 'create ${ENTITY_NAME}',
      mapper: _converter.toDomain,
    );
  }

  @override
  Future<Result<${ENTITY_NAME}Details>> update(${ENTITY_NAME}Update data) async {
    return executeRequest(
      request: () async {
        final model = ${ENTITY_NAME}UpdateModel.fromDomain(data);
        return _service.update(data.id, model);
      },
      context: 'update ${ENTITY_NAME}',
      mapper: _converter.toDomain,
    );
  }

  @override
  Future<Result<void>> delete(String id) async {
    return executeVoidRequest(
      request: () => _service.delete(id),
      context: 'delete ${ENTITY_NAME}',
    );
  }
}
EOF
    
    success "RepositoryClient gerada!"
  fi
fi

# Atualiza barrel files automaticamente
progress "Atualizando barrel files..."
update_barrel_files "$FEATURE_SNAKE"

# Atualiza barrel files do client se client repo foi gerado
if [ "$INTERFACE_ONLY" != "true" ] && validate_package_exists "$FEATURE_SNAKE" "client" 2>/dev/null; then
  update_client_barrel_files "$FEATURE_SNAKE"
fi

success "Repository gerada com sucesso!"
if [ "$INTERFACE_ONLY" != "true" ]; then
  info "Próximo: Gerar Service com ./10_generate_services.sh"
fi

# Executa pub get
run_pub_get "$FEATURE_SNAKE"

