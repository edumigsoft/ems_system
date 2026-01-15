#!/bin/bash
# Script de validação de arquitetura do EMS System
# Verifica conformidade com ADR-0005 e padrões estabelecidos

# Cores para output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Modo verboso (padrão: desligado para performance)
VERBOSE=false
if [[ "$1" == "-v" ]] || [[ "$1" == "--verbose" ]]; then
    VERBOSE=true
fi

# Pacotes a serem ignorados na validação
EXCLUDED_PACKAGES=(
    "zard_form"
)

# Contadores
ERRORS=0
WARNINGS=0
SUCCESS=0

# Diretório raiz do projeto
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║            Validação de Arquitetura - EMS System           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Função para reportar erro
report_error() {
    echo -e "${RED}❌ ERRO: $1${NC}"
    ((ERRORS++))
}

# Função para reportar warning
report_warning() {
    echo -e "${YELLOW}⚠️  AVISO: $1${NC}"
    ((WARNINGS++))
}

# Função para reportar sucesso
report_success() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${GREEN}✅ $1${NC}"
    fi
    ((SUCCESS++))
}

# Função para verificar estrutura de pacote core
validate_core_package_structure() {
    local package_path=$1
    local package_name=$(basename "$package_path")
    
    echo -e "\n${BLUE}Validando estrutura de $package_name...${NC}"
    
    # Verificar estrutura Domain/Data
    if [ -d "$package_path/lib/src/domain" ] && [ -d "$package_path/lib/src/data" ]; then
        report_success "$package_name: Estrutura Domain/Data presente"
        
        # Verificar subpastas do domain
        local domain_ok=true
        [ ! -d "$package_path/lib/src/domain/entities" ] && report_warning "$package_name: Falta pasta domain/entities" && domain_ok=false
        [ ! -d "$package_path/lib/src/domain/repositories" ] && report_warning "$package_name: Falta pasta domain/repositories" && domain_ok=false
        
        # Verificar subpastas do data
        [ ! -d "$package_path/lib/src/data/models" ] && report_warning "$package_name: Falta pasta data/models"
        
        $domain_ok && report_success "$package_name: Estrutura de domain completa"
    else
        report_error "$package_name: Estrutura Domain/Data NÃO encontrada (ADR-0005 violado)"
    fi
}

# Função para verificar arquivos obrigatórios
validate_required_files() {
    local package_path=$1
    local package_name=$(basename "$package_path")
    
    echo -e "\n${BLUE}Validando arquivos obrigatórios de $package_name...${NC}"
    
    # README.md
    if [ -f "$package_path/README.md" ]; then
        report_success "$package_name: README.md presente"
    else
        report_warning "$package_name: README.md ausente"
    fi
    
    # CHANGELOG.md
    if [ -f "$package_path/CHANGELOG.md" ]; then
        report_success "$package_name: CHANGELOG.md presente"
    else
        report_warning "$package_name: CHANGELOG.md ausente"
    fi
    
    # pubspec.yaml
    if [ -f "$package_path/pubspec.yaml" ]; then
        report_success "$package_name: pubspec.yaml presente"
    else
        report_error "$package_name: pubspec.yaml AUSENTE (crítico)"
    fi
    
    # analysis_options.yaml
    if [ -f "$package_path/analysis_options.yaml" ]; then
        report_success "$package_name: analysis_options.yaml presente"
        
        # Verificar se importa o arquivo correto
        if grep -q "include.*analysis_options" "$package_path/analysis_options.yaml"; then
            report_success "$package_name: Importa analysis_options da raiz"
        else
            report_warning "$package_name: Não importa analysis_options da raiz"
        fi
    else
        report_error "$package_name: analysis_options.yaml AUSENTE (crítico)"
    fi
}

# Função para verificar entidades puras (sem fromJson/toJson)
validate_pure_entities() {
    local package_path=$1
    local package_name=$(basename "$package_path")
    
    if [ ! -d "$package_path/lib/src/domain/entities" ]; then
        return
    fi
    
    echo -e "\n${BLUE}Validando pureza das entidades de $package_name...${NC}"
    
    local entities_with_json=0
    local entities_with_id=0
    
    for entity_file in "$package_path/lib/src/domain/entities"/*.dart; do
        if [ -f "$entity_file" ]; then
            local entity_name=$(basename "$entity_file")
            
            # Pular arquivos *_details.dart (esses DEVEM ter id)
            if [[ "$entity_name" =~ _details\.dart$ ]] || [[ "$entity_name" =~ Details\.dart$ ]]; then
                continue
            fi
            
            # Verificar se contém fromJson ou toJson
            if grep -q "fromJson\|toJson" "$entity_file"; then
                report_error "$package_name: Entidade $entity_name contém serialização JSON (deve estar em data/models)"
                ((entities_with_json++))
            fi
            
            # Verificar se Entity pura tem campo 'id' (violação)
            if grep -q "final String.*id;\|final String?.*id;" "$entity_file"; then
                report_error "$package_name: Entity $entity_name NÃO deve ter campo 'id' (apenas EntityDetails deve ter)"
                ((entities_with_id++))
            fi
        fi
    done
    
    if [ $entities_with_json -eq 0 ] && [ $entities_with_id -eq 0 ]; then
        report_success "$package_name: Todas as entidades são puras (sem JSON e sem id)"
    fi
}

# Função para verificar BaseDetails implementation
validate_base_details() {
    local package_path=$1
    local package_name=$(basename "$package_path")
    
    if [ ! -d "$package_path/lib/src/domain/entities" ]; then
        return
    fi
    
    echo -e "\n${BLUE}Validando implementação de BaseDetails em $package_name...${NC}"
    
    # Verificar se há classes *Details
    local details_files=$(find "$package_path/lib/src/domain/entities" -name "*_details.dart" -o -name "*Details.dart" 2>/dev/null)
    
    if [ -n "$details_files" ]; then
        local all_implement_base=true
        local all_non_nullable=true
        
        for details_file in $details_files; do
            local file_name=$(basename "$details_file")
            
            # Verificar se implementa BaseDetails
            if grep -q "implements BaseDetails" "$details_file"; then
                report_success "$package_name: $file_name implementa BaseDetails"
                
                # Verificar se createdAt e updatedAt são non-nullable
                # Procura por declaração de campos (final DateTime?) e não parâmetros
                if grep -q "^[[:space:]]*final DateTime?[[:space:]]*createdAt\|^[[:space:]]*final DateTime?[[:space:]]*updatedAt" "$details_file"; then
                    report_error "$package_name: $file_name tem createdAt/updatedAt nullable (devem ser DateTime, não DateTime?)"
                    all_non_nullable=false
                else
                    report_success "$package_name: $file_name tem createdAt/updatedAt non-nullable"
                fi
            else
                report_warning "$package_name: $file_name NÃO implementa BaseDetails"
                all_implement_base=false
            fi
        done
        
        if $all_implement_base && $all_non_nullable; then
            report_success "$package_name: Todas as classes *Details estão corretas"
        fi
    fi
}

# Função para verificar feature vs sub-feature
validate_feature_structure() {
    local feature_path=$1
    local feature_name=$(basename "$feature_path")
    
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Validando feature: $feature_name${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    
    # Verificar se é feature com sub-features
    local has_subfeatures=false
    local subfeature_count=0
    
    for dir in "$feature_path"/*; do
        if [ -d "$dir" ] && [[ $(basename "$dir") =~ ^${feature_name}_ ]]; then
            has_subfeatures=true
            ((subfeature_count++))
        fi
    done
    
    if [ "$has_subfeatures" = true ]; then
        echo -e "${BLUE}Tipo: Feature com Sub-Features ($subfeature_count encontradas)${NC}"
        
        # Validar README e CONTRIBUTING no nível da feature
        [ -f "$feature_path/README.md" ] && report_success "$feature_name: README.md presente no nível da feature"
        [ ! -f "$feature_path/README.md" ] && report_warning "$feature_name: README.md ausente no nível da feature"
        
        [ -f "$feature_path/CONTRIBUTING.md" ] && report_success "$feature_name: CONTRIBUTING.md presente (único para toda feature)"
        [ ! -f "$feature_path/CONTRIBUTING.md" ] && report_warning "$feature_name: CONTRIBUTING.md ausente"
        
        # Validar cada sub-feature
        for dir in "$feature_path"/*; do
            if [ -d "$dir" ] && [[ $(basename "$dir") =~ ^${feature_name}_ ]]; then
                validate_subfeature "$dir"
            fi
        done
    else
        echo -e "${BLUE}Tipo: Feature Simples${NC}"
        
        # Validar README e CONTRIBUTING no nível da feature
        [ -f "$feature_path/README.md" ] && report_success "$feature_name: README.md presente"
        [ ! -f "$feature_path/README.md" ] && report_warning "$feature_name: README.md ausente"
        
        [ -f "$feature_path/CONTRIBUTING.md" ] && report_success "$feature_name: CONTRIBUTING.md presente"
        [ ! -f "$feature_path/CONTRIBUTING.md" ] && report_warning "$feature_name: CONTRIBUTING.md ausente"
        
        # Validar pacotes individuais
        for package_type in core client server ui; do
            local package_path="$feature_path/${feature_name}_${package_type}"
            if [ -d "$package_path" ]; then
                validate_package "$package_path"
            fi
        done
    fi
}

# Função para validar sub-feature
validate_subfeature() {
    local subfeature_path=$1
    local subfeature_name=$(basename "$subfeature_path")
    
    echo -e "\n${BLUE}--- Sub-Feature: $subfeature_name ---${NC}"
    
    # Sub-features não devem ter CONTRIBUTING.md (deve estar no pai)
    if [ -f "$subfeature_path/CONTRIBUTING.md" ]; then
        report_warning "$subfeature_name: CONTRIBUTING.md duplicado (deve estar apenas no nível da feature pai)"
    fi
    
    # Validar pacotes individuais
    for package_type in core client server ui; do
        local package_path="$subfeature_path/${subfeature_name}_${package_type}"
        if [ -d "$package_path" ]; then
            validate_package "$package_path"
        fi
    done
}

# Função para validar DTOs Update
validate_update_dtos() {
    local package_path=$1
    local package_name=$(basename "$package_path")
    
    if [ ! -d "$package_path/lib/src/domain/dtos" ]; then
        return
    fi
    
    echo -e "\n${BLUE}Validando DTOs de Update em $package_name...${NC}"
    
    local update_files=$(find "$package_path/lib/src/domain/dtos" -name "*_update.dart" -o -name "*Update.dart" 2>/dev/null)
    
    if [ -n "$update_files" ]; then
        for update_file in $update_files; do
            local file_name=$(basename "$update_file")
            
            # Verificar se tem campo id obrigatório
            if ! grep -q "final String id;" "$update_file"; then
                report_warning "$package_name: $file_name deveria ter campo 'id' obrigatório"
            fi
            
            # Verificar se NÃO tem createdAt/updatedAt (são imutáveis)
            if grep -q "createdAt\|updatedAt" "$update_file"; then
                report_error "$package_name: $file_name NÃO deve ter createdAt/updatedAt (campos imutáveis)"
            fi
        done
    fi
}

# Função para validar um pacote individual
validate_package() {
    local package_path=$1
    local package_name=$(basename "$package_path")
    
    # Validar apenas pacotes _core, _client, _server, _ui
    if [[ ! "$package_name" =~ _(core|client|server|ui)$ ]]; then
        return
    fi
    
    validate_required_files "$package_path"
    
    # Validações específicas para pacotes core
    if [[ "$package_name" =~ _core$ ]]; then
        validate_core_package_structure "$package_path"
        validate_pure_entities "$package_path"
        validate_base_details "$package_path"
        validate_update_dtos "$package_path"
    fi
}

# ============================================================
# MAIN - Execução Principal
# ============================================================

echo "Iniciando validação arquitetural..."
echo "Diretório: $PROJECT_ROOT"
echo ""

# Descobrir automaticamente todas as features em packages/
echo "Descobrindo features em packages/..."

# Validar se diretório packages existe
if [ ! -d "$PROJECT_ROOT/packages" ]; then
    report_error "Diretório packages/ não encontrado!"
    exit 1
fi

# Coletar todos os diretórios em packages/
FEATURES=()
for feature_dir in "$PROJECT_ROOT/packages"/*; do
    if [ -d "$feature_dir" ]; then
        feature_basename=$(basename "$feature_dir")
        
        # Verificar se está na lista de exclusão
        is_excluded=false
        for excluded in "${EXCLUDED_PACKAGES[@]}"; do
            if [[ "$feature_basename" == "$excluded" ]]; then
                is_excluded=true
                break
            fi
        done
        
        if [ "$is_excluded" = true ]; then
            if [ "$VERBOSE" = true ]; then
                echo -e "${YELLOW}Ignorando pacote excluído: $feature_basename${NC}"
            fi
            continue
        fi

        FEATURES+=("${feature_dir#$PROJECT_ROOT/}")
    fi
done

# Validar features encontradas
if [ ${#FEATURES[@]} -eq 0 ]; then
    report_warning "Nenhuma feature encontrada em packages/"
else
    echo "Encontradas ${#FEATURES[@]} features: ${FEATURES[*]}"
    echo ""
fi

for feature in "${FEATURES[@]}"; do
    if [ -d "$PROJECT_ROOT/$feature" ]; then
        validate_feature_structure "$PROJECT_ROOT/$feature"
    fi
done

# Validar pacotes core
echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Validando pacotes Core${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"

CORE_PACKAGES=(
    "packages/core/core_client"
    "packages/core/core_server"
    "packages/core/core_shared"
)

for core_pkg in "${CORE_PACKAGES[@]}"; do
    if [ -d "$PROJECT_ROOT/$core_pkg" ]; then
        validate_package "$PROJECT_ROOT/$core_pkg"
    fi
done

# Relatório Final
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}           RELATÓRIO FINAL DE VALIDAÇÃO${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Sucessos: $SUCCESS${NC}"
echo -e "${YELLOW}Avisos:  $WARNINGS${NC}"
echo -e "${RED}Erros:      $ERRORS${NC}"
echo ""

# Determinar status da validação
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✅ VALIDAÇÃO COMPLETA - Arquitetura 100% conforme!      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║   ⚠️  VALIDAÇÃO COM AVISOS - Revisar itens marcados       ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   ❌ VALIDAÇÃO FALHOU - Corrigir erros críticos           ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    exit 1
fi
