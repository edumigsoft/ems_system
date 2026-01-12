#!/bin/bash

# ============================================================================
# 13_generate_validators.sh - Gera Zard Validators no Core
# ============================================================================
#
# Responsabilidade: Gera validators Zard no pacote Core para reutilização.
#
# Regras Arquiteturais (ADR-0004):
# - Validators devem estar no @core para serem usados por UI, Server e CLI
# - Devem estender Validator<T> (Class-based approach)
# - Um arquivo por Validator (Create/Update)
#
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=============================================="
echo "  Gerador de Zard Validators (Core)"
echo "=============================================="
echo ""

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome da entidade (PascalCase)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENTITY_SNAKE=$(to_snake_case "$ENTITY_NAME")
ROOT=$(get_project_root)
CORE_PATH=$(get_core_package_path "$FEATURE_SNAKE")
VALIDATOR_DIR="$CORE_PATH/lib/src/validators"

validate_package_exists "$FEATURE_SNAKE" "core" || exit 1
ensure_dir "$VALIDATOR_DIR"

progress "Gerando ${ENTITY_NAME}Validators no Core..."

# 1. Create Validator
CREATE_VALIDATOR_FILE="$VALIDATOR_DIR/${ENTITY_SNAKE}_create_validator.dart"
cat > "$CREATE_VALIDATOR_FILE" <<EOF
import 'package:zard/zard.dart';
import '../domain/dtos/${ENTITY_SNAKE}_create.dart';
// import '../constants/${ENTITY_SNAKE}_constants.dart';

/// Validator para criação de $ENTITY_NAME.
class ${ENTITY_NAME}CreateValidator extends Validator<${ENTITY_NAME}Create> {
  const ${ENTITY_NAME}CreateValidator();

  @override
  ValidationResult validate(${ENTITY_NAME}Create value) {
    final List<ValidationError> errors = [];

    // Exemplo de validação:
    // if (value.name.isEmpty) {
    //   errors.add(ValidationError(field: 'name', message: 'Name required'));
    // }
    
    return ValidationResult(errors);
  }
}
EOF

# 2. Update Validator
UPDATE_VALIDATOR_FILE="$VALIDATOR_DIR/${ENTITY_SNAKE}_update_validator.dart"
cat > "$UPDATE_VALIDATOR_FILE" <<EOF
import 'package:zard/zard.dart';
import '../domain/dtos/${ENTITY_SNAKE}_update.dart';
// import '../constants/${ENTITY_SNAKE}_constants.dart';

/// Validator para atualização de $ENTITY_NAME.
class ${ENTITY_NAME}UpdateValidator extends Validator<${ENTITY_NAME}Update> {
  const ${ENTITY_NAME}UpdateValidator();

  @override
  ValidationResult validate(${ENTITY_NAME}Update value) {
    final List<ValidationError> errors = [];

    // Validar ID (obrigatório em updates)
    if (value.id.isEmpty) {
       errors.add(const ValidationError(field: 'id', message: 'ID is required'));
    }

    // Exemplo de validação opcional
    // if (value.name != null && value.name!.isEmpty) {
    //   errors.add(ValidationError(field: 'name', message: 'Name cannot be empty'));
    // }
    
    return ValidationResult(errors);
  }
}
EOF

success "Validators gerados no pacote Core!"
info "Arquivo: $CREATE_VALIDATOR_FILE"
info "Arquivo: $UPDATE_VALIDATOR_FILE"
echo ""

# Adiciona zard se não existir no core
if ! grep -q "zard:" "$CORE_PATH/pubspec.yaml"; then
  progress "Adicionando dependência zard ao core..."
  (cd "$CORE_PATH" && dart pub add zard)
fi

# Atualiza barrel files do core
progress "Atualizando barrel files..."
update_barrel_files "$FEATURE_SNAKE"

run_pub_get "$FEATURE_SNAKE"

echo ""
info "Próximo: Implementar regras de validação nos arquivos gerados."
