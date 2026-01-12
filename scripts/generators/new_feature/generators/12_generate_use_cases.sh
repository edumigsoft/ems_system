#!/bin/bash

# ============================================================================
# 12_generate_use_cases.sh - Gera Use Cases CRUD
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=============================================="
echo "  Gerador de Use Cases"
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
SHARED_PATH=$(get_shared_package_path "$FEATURE_SNAKE")
UC_DIR="$SHARED_PATH/lib/src/domain/use_cases"

validate_package_exists "$FEATURE_SNAKE" "shared" || exit 1
ensure_dir "$UC_DIR"

progress "Gerando Use Cases CRUD para $ENTITY_NAME..."

# Get All
cat > "$UC_DIR/${ENTITY_SNAKE}_get_all_use_case.dart" <<EOF
import 'package:core_shared/core_shared.dart';
import '../../../${FEATURE_SNAKE}_shared.dart';

/// Use case para obter lista de ${ENTITY_NAME}s.
class ${ENTITY_NAME}GetAllUseCase {
  final ${ENTITY_NAME}Repository repository;

  ${ENTITY_NAME}GetAllUseCase(this.repository);

  Future<Result<List<${ENTITY_NAME}Details>>> call({
    int? limit,
    int? offset,
  }) async {
    return repository.getAll(limit: limit, offset: offset);
  }
}
EOF

# Get By ID
cat > "$UC_DIR/${ENTITY_SNAKE}_get_by_id_use_case.dart" <<EOF
import 'package:core_shared/core_shared.dart';
import '../../../${FEATURE_SNAKE}_shared.dart';

/// Use case para obter $ENTITY_NAME por ID.
class ${ENTITY_NAME}GetByIdUseCase {
  final ${ENTITY_NAME}Repository repository;

  ${ENTITY_NAME}GetByIdUseCase(this.repository);

  Future<Result<${ENTITY_NAME}Details>> call(String id) async {
    return repository.getById(id);
  }
}
EOF

# Create
cat > "$UC_DIR/${ENTITY_SNAKE}_create_use_case.dart" <<EOF
import 'package:core_shared/core_shared.dart';
import '../../../${FEATURE_SNAKE}_shared.dart';

/// Use case para criar $ENTITY_NAME.
class ${ENTITY_NAME}CreateUseCase {
  final ${ENTITY_NAME}Repository repository;

  ${ENTITY_NAME}CreateUseCase(this.repository);

  Future<Result<${ENTITY_NAME}Details>> call(${ENTITY_NAME}Create data) async {
    return repository.create(data);
  }
}
EOF

# Update
cat > "$UC_DIR/${ENTITY_SNAKE}_update_use_case.dart" <<EOF
import 'package:core_shared/core_shared.dart';
import '../../../${FEATURE_SNAKE}_shared.dart';

/// Use case para atualizar $ENTITY_NAME.
class ${ENTITY_NAME}UpdateUseCase {
  final ${ENTITY_NAME}Repository repository;

  ${ENTITY_NAME}UpdateUseCase(this.repository);

  Future<Result<${ENTITY_NAME}Details>> call(${ENTITY_NAME}Update data) async {
    return repository.update(data);
  }
}
EOF

# Delete
cat > "$UC_DIR/${ENTITY_SNAKE}_delete_use_case.dart" <<EOF
import 'package:core_shared/core_shared.dart';
import '../../../${FEATURE_SNAKE}_shared.dart';

/// Use case para deletar $ENTITY_NAME.
class ${ENTITY_NAME}DeleteUseCase {
  final ${ENTITY_NAME}Repository repository;

  ${ENTITY_NAME}DeleteUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    return repository.delete(id);
  }
}
EOF

# Atualiza barrel files automaticamente
progress "Atualizando barrel files..."
update_barrel_files "$FEATURE_SNAKE"

success "Use Cases CRUD geradas com sucesso!"
info "Arquivos criados:"
info "  - ${ENTITY_SNAKE}_get_all_use_case.dart"
info "  - ${ENTITY_SNAKE}_get_by_id_use_case.dart"
info "  - ${ENTITY_SNAKE}_create_use_case.dart"
info "  - ${ENTITY_SNAKE}_update_use_case.dart"
info "  - ${ENTITY_SNAKE}_delete_use_case.dart"

# Executa pub get
run_pub_get "$FEATURE_SNAKE"
