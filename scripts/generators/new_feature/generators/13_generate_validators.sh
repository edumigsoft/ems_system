#!/bin/bash

# ============================================================================
# 13_generate_validators.sh - Gera Zard Validators no Shared
# ============================================================================
#
# Responsabilidade: Gera validators Zard no pacote Shared para reutilização.
#
# Regras Arquiteturais (ADR-0004):
# - Validators devem estar no @shared para serem usados por UI, Server e CLI
# - Devem estender Validator<T> (Class-based approach)
# - Um arquivo por Validator (Create/Update)
#
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=============================================="
echo "  Gerador de Zard Validators (Shared)"
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
VALIDATOR_DIR="$SHARED_PATH/lib/src/validators"

validate_package_exists "$FEATURE_SNAKE" "shared" || exit 1
ensure_dir "$VALIDATOR_DIR"

progress "Gerando ${ENTITY_NAME}Validators no Shared..."

# 1. Create Validator
CREATE_VALIDATOR_FILE="$VALIDATOR_DIR/${ENTITY_SNAKE}_create_validator.dart"
cat > "$CREATE_VALIDATOR_FILE" <<EOF
import 'package:core_shared/core_shared.dart';
import '../domain/dtos/${ENTITY_SNAKE}_create.dart';
// import '../constants/${ENTITY_SNAKE}_constants.dart';

/// Validator para criação de $ENTITY_NAME.
class ${ENTITY_NAME}CreateValidator extends CoreValidator<${ENTITY_NAME}Create> {
  const ${ENTITY_NAME}CreateValidator();

  @override
  CoreValidationResult validate(${ENTITY_NAME}Create value) {
    final List<CoreValidationError> errors = [];

    // Exemplo de validação:
    // if (value.name.isEmpty) {
    //   errors.add(CoreValidationError(field: 'name', message: 'Name required'));
    // }
    
    return CoreValidationResult(isValid: true, errors: errors);
  }
}
EOF

# 2. Update Validator
UPDATE_VALIDATOR_FILE="$VALIDATOR_DIR/${ENTITY_SNAKE}_update_validator.dart"
cat > "$UPDATE_VALIDATOR_FILE" <<EOF
import 'package:core_shared/core_shared.dart';
import '../domain/dtos/${ENTITY_SNAKE}_update.dart';
// import '../constants/${ENTITY_SNAKE}_constants.dart';

/// Validator para atualização de $ENTITY_NAME.
class ${ENTITY_NAME}UpdateValidator extends CoreValidator<${ENTITY_NAME}Update> {
  const ${ENTITY_NAME}UpdateValidator();

  @override
  CoreValidationResult validate(${ENTITY_NAME}Update value) {
    final List<CoreValidationError> errors = [];

    // Validar ID (obrigatório em updates)
    if (value.id.isEmpty) {
       errors.add(const CoreValidationError(field: 'id', message: 'ID is required'));
    }

    // Exemplo de validação opcional
    // if (value.name != null && value.name!.isEmpty) {
    //   errors.add(ValidationError(field: 'name', message: 'Name cannot be empty'));
    // }
    
    return CoreValidationResult(isValid: true, errors: errors);
  }
}
EOF

success "Validators gerados no pacote Shared!"
info "Arquivo: $CREATE_VALIDATOR_FILE"
info "Arquivo: $UPDATE_VALIDATOR_FILE"
echo ""

# Adiciona zard se não existir no shared
if ! grep -q "zard:" "$SHARED_PATH/pubspec.yaml"; then
  progress "Adicionando dependência zard ao shared..."
  (cd "$SHARED_PATH" && dart pub add zard)
fi

# Atualiza barrel files do shared
progress "Atualizando barrel files..."
update_barrel_files "$FEATURE_SNAKE"

run_pub_get "$FEATURE_SNAKE"

echo ""
info "Próximo: Implementar regras de validação nos arquivos gerados."
