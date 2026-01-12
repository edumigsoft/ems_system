#!/bin/bash

# ===================================================================
# 05_generate_converters.sh - Gera ModelConverters
# ============================================================================
#
# Responsabilidade: Gera ModelConverter para conversão Model ↔ Domain.
#
# Padrão ModelConverter<TModel, TDomain>:
# - Centraliza lógica de conversão
# - Facilita testes e reutilização
# - Obrigatório para todo Model
#
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=================================================="
echo "  Gerador de ModelConverter"
echo "=================================================="
echo ""

progress "Coletando informações..."

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome da entidade (PascalCase)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

ask "Tipo de Model (details/create)" MODEL_TYPE


# Preparação
FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENTITY_SNAKE=$(to_snake_case "$ENTITY_NAME")
ROOT=$(get_project_root)
SHARED_PATH=$(get_shared_package_path "$FEATURE_SNAKE")
CONVERTER_DIR="$SHARED_PATH/lib/src/data/converters"
CONVERTER_FILE="$CONVERTER_DIR/${ENTITY_SNAKE}_${MODEL_TYPE}_converter.dart"

validate_package_exists "$FEATURE_SNAKE" "shared" || exit 1
ensure_dir "$CONVERTER_DIR"

progress "Gerando ${ENTITY_NAME}${MODEL_TYPE^}Converter..."

MODEL_CLASS="${ENTITY_NAME}${MODEL_TYPE^}Model"
DOMAIN_CLASS="${ENTITY_NAME}${MODEL_TYPE^}"

# Define Imports baseados no tipo
if [[ "$MODEL_TYPE" == "details" ]]; then
  IMPORT_DOMAIN="import '../../domain/entities/${ENTITY_SNAKE}_details.dart';"
  DOMAIN_CLASS="${ENTITY_NAME}Details"
elif [[ "$MODEL_TYPE" == "create" ]]; then
  IMPORT_DOMAIN="import '../../domain/dtos/${ENTITY_SNAKE}_create.dart';"
  DOMAIN_CLASS="${ENTITY_NAME}Create"
elif [[ "$MODEL_TYPE" == "update" ]]; then
  IMPORT_DOMAIN="import '../../domain/dtos/${ENTITY_SNAKE}_update.dart';"
  DOMAIN_CLASS="${ENTITY_NAME}Update"
fi

cat > "$CONVERTER_FILE" <<EOF
$IMPORT_DOMAIN
import 'package:core_shared/core_shared.dart';
import '../models/${ENTITY_SNAKE}_${MODEL_TYPE}_model.dart';

/// Conversor para $DOMAIN_CLASS ↔ $MODEL_CLASS.
///
/// Centraliza lógica de conversão entre Model e Domain.
class ${ENTITY_NAME}${MODEL_TYPE^}Converter implements ModelConverter<$MODEL_CLASS, $DOMAIN_CLASS> {
  
  const ${ENTITY_NAME}${MODEL_TYPE^}Converter();
  
  @override
  $DOMAIN_CLASS toDomain($MODEL_CLASS model) => model.toDomain();
  
  @override
  $MODEL_CLASS fromDomain($DOMAIN_CLASS domain) => 
      $MODEL_CLASS.fromDomain(domain);
}
EOF

success "ModelConverter gerada!"
info "Arquivo: $CONVERTER_FILE"
echo ""
info "Uso no Repository:"
info "  final converter = const ${ENTITY_NAME}${MODEL_TYPE^}Converter();"
info "  final domain = converter.toDomain(model);"

# Atualiza barrel files automaticamente
progress "Atualizando barrel files..."
update_barrel_files "$FEATURE_SNAKE"
