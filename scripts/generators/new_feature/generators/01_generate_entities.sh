#!/bin/bash

# ============================================================================
# 01_generate_entities.sh - Gera entidades de domínio puras
# ============================================================================
#
# Responsabilidade: Gera entidades de domínio (domain entities) SEM campo 'id'.
#
# Regras Arquiteturais:
# - Entity NUNCA deve ter campo 'id' (é responsabilidade de *Details)
# - Entity NÃO deve ter serialização JSON
# - Entity NÃO deve ter dependências externas
# - Deve implementar operator== e hashCode
#
# Uso:
#   ./01_generate_entities.sh
#
# Inputs interativos:
#   - Nome da feature (ex: book)
#   - Nome da entidade (ex: Book)
#   - Campos (ex: title:String,isbn:String,publishYear:int)
#
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"
source "$SCRIPT_DIR/common/templates_engine.sh"

# ============================================================================
# Início do Script
# ============================================================================

echo "=================================================="
echo "  Gerador de Entidades de Domínio (Entity)"
echo "=================================================="
echo ""

# ============================================================================
# 1. Coleta de Informações
# ============================================================================

progress "Coletando informações..."

# Feature name
ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" "Nome da feature" || exit 1

# Entity name
ask "Nome da entidade (PascalCase)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

# Campos
info "Informe os campos da entidade (formato: nome:Tipo,nome2:Tipo2)"
info "Exemplo: title:String,isbn:String,publishYear:int"
ask "Campos" FIELDS

# Valida campos
validate_fields "$FIELDS" || exit 1

# Valida que não tem 'id'
validate_entity_no_id "$FIELDS" || exit 1

# ============================================================================
# 2. Preparação
# ============================================================================

progress "Preparando geração..."

# Nomes derivados
FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENTITY_SNAKE=$(to_snake_case "$ENTITY_NAME")
ENTITY_PASCAL="$ENTITY_NAME"

# Paths
ROOT=$(get_project_root)
CORE_PATH=$(get_core_package_path "$FEATURE_SNAKE")
ENTITY_FILE="$CORE_PATH/lib/src/domain/entities/${ENTITY_SNAKE}.dart"

# Verifica se pacote core existe
validate_package_exists "$FEATURE_SNAKE" "core" || exit 1

# Verifica se arquivo já existe
validate_file_not_exists "$ENTITY_FILE" || exit 1

# ============================================================================
# 3. Geração do Código
# ============================================================================

progress "Gerando Entity: $ENTITY_PASCAL..."

# Cria diretório se necessário
ensure_dir "$(dirname "$ENTITY_FILE")"

# Gera conteúdo
FIELD_DECLARATIONS=$(generate_field_declarations "$FIELDS" "  ")
CONSTRUCTOR_PARAMS=$(generate_constructor_params "$FIELDS" "    " "true")
COPY_WITH=$(generate_copy_with "$ENTITY_PASCAL" "$FIELDS" "  ")
EQUALS_OPERATOR=$(generate_equals_operator "$ENTITY_PASCAL" "$FIELDS" "  ")
HASH_CODE=$(generate_hash_code "$FIELDS" "  ")
TO_STRING=$(generate_to_string "$ENTITY_PASCAL" "$FIELDS" "  ")

# Gera arquivo
cat > "$ENTITY_FILE" <<EOF
/// Entidade de domínio representando $ENTITY_PASCAL.
///
/// Entidades são objetos de domínio puros que contêm apenas lógica de negócio.
/// - NÃO devem ter campo 'id' (é responsabilidade de ${ENTITY_PASCAL}Details)
/// - NÃO devem ter serialização JSON (é responsabilidade de ${ENTITY_PASCAL}Model)
/// - NÃO devem ter dependências externas
class $ENTITY_PASCAL {
$FIELD_DECLARATIONS
  const $ENTITY_PASCAL({
$CONSTRUCTOR_PARAMS  });

$COPY_WITH

$EQUALS_OPERATOR

$HASH_CODE

$TO_STRING
}
EOF

# ============================================================================
# 4. Finalização
# ============================================================================

success "Entity gerada com sucesso!"
info "Arquivo: $ENTITY_FILE"
echo ""
info "Próximos passos:"
info "  1. Adicionar lógica de negócio à Entity se necessário"
info "  2. Gerar ${ENTITY_PASCAL}Details com: ./02_generate_details.sh"
info "  3. Gerar DTOs com: ./03_generate_dtos.sh"
echo ""

# Atualiza barrel files automaticamente
progress "Atualizando barrel files..."
update_barrel_files "$FEATURE_SNAKE"

# Executa pub get
run_pub_get "$FEATURE_SNAKE"
