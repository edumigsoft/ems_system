#!/bin/bash

# ============================================================================
# 02_generate_details.sh - Gera classes *Details
# ============================================================================
#
# Responsabilidade: Gera classes *Details que IMPLEMENTAM BaseDetails.
#
# Regras Arquiteturais:
# - Details IMPLEMENTA BaseDetails (não estende)
# - Deve ter campo 'data' do tipo Entity
# - Deve ter getters de conveniência para campos da Entity
# - NÃO deve ter serialização JSON (responsabilidade de *Model)
# - createdAt e updatedAt são DateTime NON-NULLABLE
#
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"
source "$SCRIPT_DIR/common/templates_engine.sh"

echo "=================================================="
echo "  Gerador de Details (BaseDetails)"
echo "=================================================="
echo ""

progress "Coletando informações..."

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" "Nome da feature" || exit 1

ask "Nome da entidade (PascalCase)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

info "Informe os campos da entidade (mesmo da Entity)"
ask "Campos" FIELDS
validate_fields "$FIELDS" || exit 1

# Preparação
FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENTITY_SNAKE=$(to_snake_case "$ENTITY_NAME")
ROOT=$(get_project_root)
CORE_PATH=$(get_core_package_path "$FEATURE_SNAKE")
DETAILS_FILE="$CORE_PATH/lib/src/domain/entities/${ENTITY_SNAKE}_details.dart"

validate_package_exists "$FEATURE_SNAKE" "core" || exit 1
validate_file_not_exists "$DETAILS_FILE" || exit 1

progress "Gerando ${ENTITY_NAME}Details..."

ensure_dir "$(dirname "$DETAILS_FILE")"

# Gera código
ENTITY_CONSTRUCTOR_PARAMS=$(generate_entity_details_constructor_params "$FIELDS" "    ")
ENTITY_PARAMS=$(generate_entity_constructor_args "$FIELDS" "         ")
GETTERS=$(generate_convenience_getters "$FIELDS" "data" "  ")
COPYWITH_METHOD=$(generate_details_copy_with "$ENTITY_NAME" "$FIELDS" "  ")
EMPTY_FACTORY=$(generate_details_empty_factory "$ENTITY_NAME" "$FIELDS" "  ")

cat > "$DETAILS_FILE" <<EOF
import 'package:core_shared/core_shared.dart';
import '${ENTITY_SNAKE}.dart';

class ${ENTITY_NAME}Details implements BaseDetails {
  @override
  final String id;
  @override
  final bool isDeleted;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final $ENTITY_NAME data;

  ${ENTITY_NAME}Details({
    required this.id,
    required this.isDeleted,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
$ENTITY_CONSTRUCTOR_PARAMS
  }) : data = $ENTITY_NAME(
$ENTITY_PARAMS
       );

$GETTERS
$EMPTY_FACTORY

$COPYWITH_METHOD
}
EOF

success "Details gerada com sucesso!"
info "Arquivo: $DETAILS_FILE"
echo ""
info "Próximos passos:"
info "  1. Gerar DTOs com: ./03_generate_dtos.sh"
info "  2. Gerar Model com: ./04_generate_models.sh"

# Atualiza barrel files automaticamente
progress "Atualizando barrel files..."
update_barrel_files "$FEATURE_SNAKE"

# Executa pub get
run_pub_get "$FEATURE_SNAKE"
