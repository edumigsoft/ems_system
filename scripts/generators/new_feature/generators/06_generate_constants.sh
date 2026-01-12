#!/bin/bash

# ============================================================================
# 06_generate_constants.sh - Gera Constants (rotas + validações)
# ============================================================================
#
# Responsabilidade: Gera constants compartilhadas entre server e validações.
#
# Conteúdo:
# - Constants de rotas (Shelf e OpenAPI)
# - RegExp de validação compartilhadas
# - Mensagens de erro compartilhadas
# - Limites e constraints
#
# Localização: packages/{feature}/{feature}_shared/lib/src/constants/
#
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=================================================="
echo "  Gerador de Constants"
echo "=================================================="
echo ""

progress "Coletando informações..."

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome da entidade (plural, ex: books)" ENTITY_PLURAL
validate_name "$ENTITY_PLURAL" || exit 1

# Preparação
FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ROOT=$(get_project_root)
SHARED_PATH=$(get_shared_package_path "$FEATURE_SNAKE")
CONSTANTS_DIR="$SHARED_PATH/lib/src/constants"
CONSTANTS_FILE="$CONSTANTS_DIR/${FEATURE_SNAKE}_constants.dart"

validate_package_exists "$FEATURE_SNAKE" "shared" || exit 1
ensure_dir "$CONSTANTS_DIR"

progress "Gerando ${FEATURE_NAME} constants..."

cat > "$CONSTANTS_FILE" <<EOF
// ============================================================================
// ROTAS
// ============================================================================

/// Caminho base da API
const String ${ENTITY_PLURAL}Path = '/$ENTITY_PLURAL';

/// Rotas para operações CRUD

// GET All
const String ${ENTITY_PLURAL}PathGetAll = '/';

// GET By ID (Shelf format)
const String ${ENTITY_PLURAL}PathById = '/<id>';
// GET By ID (OpenAPI format)
const String ${ENTITY_PLURAL}PathByIdOpenApi = '/{id}';

// POST Create
const String ${ENTITY_PLURAL}PathCreate = '/';

// PUT Update (Shelf format)
const String ${ENTITY_PLURAL}PathUpdate = '/<id>';
// PUT Update (OpenAPI format)
const String ${ENTITY_PLURAL}PathUpdateOpenApi = '/{id}';

// DELETE (Shelf format)
const String ${ENTITY_PLURAL}PathDelete = '/<id>';
// DELETE (OpenAPI format)
const String ${ENTITY_PLURAL}PathDeleteOpenApi = '/{id}';

// ============================================================================
// VALIDAÇÕES COMPARTILHADAS
// ============================================================================

// Adicionar RegExp de validação compartilhadas
// Exemplo:
// final RegExp emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
// const String emailInvalidMessage = 'Email inválido';

// Adicionar limites e constraints
// Exemplo:
// const int nameMinLength = 3;
// const int nameMaxLength = 100;
// const String nameMinLengthMessage = 'Nome deve ter no mínimo 3 caracteres';
EOF

success "Constants geradas!"
info "Arquivo: $CONSTANTS_FILE"
echo ""
warn "Lembre-se de:"
info "  1. Adicionar RegExp de validação específicas"
info "  2. Adicionar mensagens de erro compartilhadas"
info "  3. Importar as constants em Routes: import 'package:${FEATURE_SNAKE}_shared/${FEATURE_SNAKE}_shared.dart';"
info "  4. Usar as constants nos DTOs e Zard Validators"

# Atualiza barrel files automaticamente
progress "Atualizando barrel files..."
update_barrel_files "$FEATURE_SNAKE"
