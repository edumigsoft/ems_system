#!/bin/bash

# ============================================================================
# 03_generate_dtos.sh - Gera DTOs (Create e Update)
# ============================================================================
#
# Responsabilidade: Gera DTOs puros com validações usando constants.
#
# Regras Arquiteturais:
# - *Create: SEM id, SEM timestamps, campos required
# - *Update: id required, outros campos optional, inclui isActive e deleted
# - Validações devem usar constants compartilhadas
# - NÃO deve ter serialização JSON
#
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"
source "$SCRIPT_DIR/common/templates_engine.sh"

echo "=================================================="
echo "  Gerador de DTOs (Create e Update)"
echo "=================================================="
echo ""

progress "Coletando informações..."

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome da entidade (PascalCase)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

info "Informe os campos editáveis (sem id, sem timestamps)"
ask "Campos" FIELDS
validate_fields "$FIELDS" || exit 1
validate_create_no_timestamps "$FIELDS" || exit 1

# Preparação
FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENTITY_SNAKE=$(to_snake_case "$ENTITY_NAME")
ROOT=$(get_project_root)
SHARED_PATH=$(get_shared_package_path "$FEATURE_SNAKE")
DTO_DIR="$SHARED_PATH/lib/src/domain/dtos"
CREATE_FILE="$DTO_DIR/${ENTITY_SNAKE}_create.dart"
UPDATE_FILE="$DTO_DIR/${ENTITY_SNAKE}_update.dart"

validate_package_exists "$FEATURE_SNAKE" "shared" || exit 1
ensure_dir "$DTO_DIR"

# ============================================================================
# Gera Create DTO
# ============================================================================

progress "Gerando ${ENTITY_NAME}Create..."

FIELD_DECLARATIONS=$(generate_field_declarations "$FIELDS" "  ")
CONSTRUCTOR_PARAMS=$(generate_constructor_params "$FIELDS" "    " "true")

cat > "$CREATE_FILE" <<EOF
/// DTO para criação de $ENTITY_NAME.
///
/// - NÃO tem campo 'id' (gerado automaticamente)
/// - NÃO tem timestamps (gerenciados automaticamente)
/// - Validações usam constants compartilhadas
class ${ENTITY_NAME}Create {
$FIELD_DECLARATIONS
  const ${ENTITY_NAME}Create({
$CONSTRUCTOR_PARAMS
  });

  // Validação de negócio
  bool get isValid {
    // Implementar validação usando constants
    return true;
  }
  
  String? validate() {
    // Implementar validações usando constants compartilhadas
    // Ex: if (name.isEmpty) return nameRequiredMessage;
    return null;
  }
}
EOF

success "Create DTO gerada!"

# ============================================================================
# Gera Update DTO
# ============================================================================

progress "Gerando ${ENTITY_NAME}Update..."

# Gera campos opcionais para Update
IFS=',' read -ra FIELD_ARRAY <<< "$FIELDS"
UPDATE_DECLARATIONS="  final String id;  // ✅ Required\n"
UPDATE_PARAMS="    required this.id,\n"

for field in "${FIELD_ARRAY[@]}"; do
  field=$(echo "$field" | xargs)
  field_name=$(get_field_name "$field")
  field_type=$(get_field_type "$field")
  
  UPDATE_DECLARATIONS+="  final $field_type? $field_name;  // ✅ Optional\n"
  UPDATE_PARAMS+="    this.$field_name,\n"
done

UPDATE_DECLARATIONS+="  final bool? isActive;  // ✅ Controle\n"
UPDATE_DECLARATIONS+="  final bool? isDeleted;   // ✅ Soft delete\n"
UPDATE_PARAMS+="    this.isActive,\n"
UPDATE_PARAMS+="    this.isDeleted,\n"

# Gera verificação hasChanges - cada campo em uma linha separada
HAS_CHANGES_LINES=()
for i in "${!FIELD_ARRAY[@]}"; do
  field=$(echo "${FIELD_ARRAY[$i]}" | xargs)
  field_name=$(get_field_name "$field")
  
  HAS_CHANGES_LINES+=("$field_name != null")
done
HAS_CHANGES_LINES+=("isActive != null")
HAS_CHANGES_LINES+=("isDeleted != null")

# Formata hasChanges com quebras de linha corretas
FORMATTED_HAS_CHANGES="      "
for i in "${!HAS_CHANGES_LINES[@]}"; do
  if [[ $i -eq 0 ]]; then
    FORMATTED_HAS_CHANGES+="${HAS_CHANGES_LINES[$i]}"
  else
    FORMATTED_HAS_CHANGES+=" ||
      ${HAS_CHANGES_LINES[$i]}"
  fi
done

cat > "$UPDATE_FILE" <<EOF
/// DTO para atualização de $ENTITY_NAME.
///
/// - Campo 'id' é required
/// - Outros campos são optional (atualização parcial)
/// - Inclui isActive e isDeleted para controle
class ${ENTITY_NAME}Update {
$(echo -e "$UPDATE_DECLARATIONS")
  ${ENTITY_NAME}Update({
$(echo -e "$UPDATE_PARAMS")
  });
  
  bool get hasChanges => 
$FORMATTED_HAS_CHANGES;
  
  String? validate() {
    if (id.isEmpty) return 'ID é obrigatório';
    if (!hasChanges) return 'Nenhuma alteração fornecida';
    
    // Validações usando constants
    return null;
  }
}
EOF

success "Update DTO gerada!"
echo ""
info "Arquivos criados:"
info "  - $CREATE_FILE"
info "  - $UPDATE_FILE"
echo ""
info "Próximos passos:"
info "  1. Adicionar validações usando constants em validate()"
info "  2. Gerar Models com: ./04_generate_models.sh"
info "  3. Gerar Constants com: ./06_generate_constants.sh"

# Atualiza barrel files automaticamente
progress "Atualizando barrel files..."
update_barrel_files "$FEATURE_SNAKE"

# Executa pub get
run_pub_get "$FEATURE_SNAKE"
