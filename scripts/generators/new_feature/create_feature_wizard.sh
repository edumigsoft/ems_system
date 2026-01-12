#!/bin/bash

# ============================================================================
# create_feature_wizard.sh - Wizard para criação completa de features
# ============================================================================
#
# Este wizard orquestra a criação de features completas chamando:
# 1. scaffold_feature.sh (estrutura base)
# 2. Geradores modulares (código)
# 3. build_runner (geração de código)
# 4. validate_architecture.sh (validação)
#
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERATORS_DIR="$SCRIPT_DIR/generators"

source "$GENERATORS_DIR/common/utils.sh"
source "$GENERATORS_DIR/common/validators.sh"

echo "=========================================================="
echo "  🚀 Wizard de Criação de Features"
echo "=========================================================="
echo ""
info "✨ Suporta sub-features (ex: finance/billing)"
info "✨ Usa pubspec.yaml.templates com versões fixas"
echo ""

# ============================================================================
# 1. Coleta de Informações
# ============================================================================

progress "Coletando informações da feature..."

ask "Nome da feature (ex: book ou finance/billing)" FEATURE_PATH
validate_name "$(basename "$FEATURE_PATH")" "Feature" || exit 1

# Detecta se é sub-feature
if [[ "$FEATURE_PATH" == *"/"* ]]; then
  PARENT_FEATURE=$(dirname "$FEATURE_PATH")
  FEATURE_NAME=$(basename "$FEATURE_PATH")
  IS_SUBFEATURE=true
  info "✓ Sub-feature detectada: $PARENT_FEATURE/$FEATURE_NAME"
else
  FEATURE_NAME="$FEATURE_PATH"
  IS_SUBFEATURE=false
fi

ask "Título da feature (ex: Book Management)" FEATURE_TITLE

ask "Nome da entidade principal (PascalCase, ex: Book)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

ask "Nome da entidade (plural, ex: books)" ENTITY_PLURAL
validate_name "$ENTITY_PLURAL" || exit 1

info "Informe os campos da entidade (formato: nome:Tipo,nome2:Tipo2)"
info "Exemplo: title:String,isbn:String,publishYear:int"
ask "Campos" FIELDS
validate_fields "$FIELDS" || exit 1
validate_entity_no_id "$FIELDS" || exit 1

info "Quais pacotes deseja criar?"
info "  1. shared (obrigatório)"
info "  2. shared + client"
info "  3. shared + server"  
info "  4. shared + client + server"
info "  5. shared + client + server + ui (completo)"
ask "Opção (1-5)" PACKAGES_OPTION "5"

# Mapeia opção para pacotes
case "$PACKAGES_OPTION" in
  1) PACKAGES="shared" ;;
  2) PACKAGES="shared,client" ;;
  3) PACKAGES="shared,server" ;;
  4) PACKAGES="shared,client,server" ;;
  5) PACKAGES="shared,client,server,ui" ;;
  *) error "Opção inválida"; exit 1 ;;
esac

# ============================================================================
# 2. Scaffold (Estrutura Base)
# ============================================================================

progress "Criando estrutura base com scaffold_feature.sh..."

# O scaffold_feature.sh já suporta sub-features via path (ex: academic/config)
"$SCRIPT_DIR/scaffold_feature.sh" \
  --name "$FEATURE_PATH" \
  --title "$FEATURE_TITLE" \
  --entity "$ENTITY_NAME" \
  --packages "$PACKAGES" \
  --no-prompt

success "Estrutura base criada!"
info "✓ Pubspec.yaml gerado a partir de templates com versões fixas"

# ============================================================================
# 3. Geradores Shared (sempre executados)
# ============================================================================

progress "Gerando código shared..."

# Entity
echo "$FEATURE_NAME
$ENTITY_NAME
$FIELDS" | "$GENERATORS_DIR/01_generate_entities.sh"

# Details
echo "$FEATURE_NAME
$ENTITY_NAME
$FIELDS" | "$GENERATORS_DIR/02_generate_details.sh"

# DTOs
echo "$FEATURE_NAME
$ENTITY_NAME
$FIELDS" | "$GENERATORS_DIR/03_generate_dtos.sh"

# Models
echo "$FEATURE_NAME
$ENTITY_NAME
details
$FIELDS" | "$GENERATORS_DIR/04_generate_models.sh"

echo "$FEATURE_NAME
$ENTITY_NAME
create
$FIELDS" | "$GENERATORS_DIR/04_generate_models.sh"

echo "$FEATURE_NAME
$ENTITY_NAME
update
$FIELDS" | "$GENERATORS_DIR/04_generate_models.sh"

# Constants
echo "$FEATURE_NAME
$ENTITY_PLURAL" | "$GENERATORS_DIR/06_generate_constants.sh"

# Use Cases
echo "$FEATURE_NAME
$ENTITY_NAME
$ENTITY_PLURAL" | "$GENERATORS_DIR/12_generate_use_cases.sh"

# Repository Interface (sempre no shared)
echo "$FEATURE_NAME
$ENTITY_NAME" | "$GENERATORS_DIR/09_generate_repositories.sh" --interface-only

# Validators (Zard - Shared)
echo "$FEATURE_NAME
$ENTITY_NAME" | "$GENERATORS_DIR/13_generate_validators.sh"

success "Shared gerado!"

# ============================================================================
# 4. Geradores Server (se solicitado)
# ============================================================================

if [[ "$PACKAGES" == *"server"* ]]; then
  progress "Gerando código server..."
  
  # Table
  echo "$FEATURE_NAME
$ENTITY_NAME
$FIELDS" | "$GENERATORS_DIR/07_generate_tables.sh"
  
  # Routes
  echo "$FEATURE_NAME
$ENTITY_NAME
$ENTITY_PLURAL" | "$GENERATORS_DIR/11_generate_routes.sh"
  
  success "Server gerado!"
fi

# ============================================================================
# 5. Geradores Client (se solicitado)
# ============================================================================

if [[ "$PACKAGES" == *"client"* ]]; then
  progress "Gerando código client..."
  
  # Service
  echo "$FEATURE_NAME
$ENTITY_NAME
$ENTITY_PLURAL" | "$GENERATORS_DIR/10_generate_services.sh"
  
  # Repository Implementation
  echo "$FEATURE_NAME
$ENTITY_NAME" | "$GENERATORS_DIR/09_generate_repositories.sh" --implementation-only
  
  success "Client gerado!"
fi

# ============================================================================
# 6. Geradores UI (se solicitado)
# ============================================================================

if [[ "$PACKAGES" == *"ui"* ]]; then
  progress "Gerando código UI..."
    
  # ViewModel
  echo "$FEATURE_NAME
$ENTITY_NAME
$ENTITY_PLURAL" | "$GENERATORS_DIR/15_generate_ui_components.sh"
  
  # Module
  echo "$FEATURE_NAME
$ENTITY_NAME" | "$GENERATORS_DIR/14_generate_ui_module.sh"
  
  # Widgets
  echo "$FEATURE_NAME
$ENTITY_NAME" | "$GENERATORS_DIR/16_generate_ui_widgets.sh"
  
  success "UI gerada!"
fi

# ============================================================================
# 7. Pub Get (instalar dependências)
# ============================================================================

progress "Instalando dependências dos pacotes..."

ROOT=$(get_project_root)

# Shared sempre existe
info "pub get em ${FEATURE_NAME}_shared..."
cd "$ROOT/packages/$FEATURE_NAME/${FEATURE_NAME}_shared"
dart pub get || warn "Erro no pub get shared"

if [[ "$PACKAGES" == *"server"* ]]; then
  info "pub get em ${FEATURE_NAME}_server..."
  cd "$ROOT/packages/$FEATURE_NAME/${FEATURE_NAME}_server"
  dart pub get || warn "Erro no pub get server"
fi

if [[ "$PACKAGES" == *"client"* ]]; then
  info "pub get em ${FEATURE_NAME}_client..."
  cd "$ROOT/packages/$FEATURE_NAME/${FEATURE_NAME}_client"
  dart pub get || warn "Erro no pub get client"
fi

if [[ "$PACKAGES" == *"ui"* ]]; then
  info "pub get em ${FEATURE_NAME}_ui..."
  cd "$ROOT/packages/$FEATURE_NAME/${FEATURE_NAME}_ui"
  dart pub get || warn "Erro no pub get ui"
fi

cd "$ROOT"
success "Dependências instaladas!"

# ============================================================================
# 8. Build Runner (se necessário)
# ============================================================================

if [[ "$PACKAGES" == *"server"* ]] || [[ "$PACKAGES" == *"client"* ]]; then
  progress "Executando build_runner..."
  
  if [[ "$PACKAGES" == *"server"* ]]; then
    info "build_runner em ${FEATURE_NAME}_server..."
    cd "$ROOT/packages/$FEATURE_NAME/${FEATURE_NAME}_server"
    dart run build_runner build --delete-conflicting-outputs || warn "Erro no build_runner server"
  fi
  
  if [[ "$PACKAGES" == *"client"* ]]; then
    info "build_runner em ${FEATURE_NAME}_client..."
    cd "$ROOT/packages/$FEATURE_NAME/${FEATURE_NAME}_client"
    dart run build_runner build --delete-conflicting-outputs || warn "Erro no build_runner client"
  fi
  
  cd "$ROOT"
  success "Build runner concluído!"
fi

# ============================================================================
# 9. Validação
# ============================================================================

if confirm "Deseja executar validate_architecture.sh?"; then
  progress "Validando arquitetura..."
  
  "$SCRIPT_DIR/validate_architecture.sh" || warn "Avisos encontrados na validação"
  
  success "Validação concluída!"
fi

# ============================================================================
# 10. Finalização
# ============================================================================

echo ""
echo "=========================================================="
success "✅ Feature '$FEATURE_NAME' criada com sucesso!"
echo "=========================================================="
echo ""
info "Próximos passos:"
info "  1. Revisar código gerado"
info "  2. Adicionar lógica de negócio específica"
info "  3. Implementar validações customizadas em Constants"
info "  4. Completar UI pages e widgets"
info "  5. Executar testes"
echo ""
info "Localização: packages/$FEATURE_NAME/"
echo ""
