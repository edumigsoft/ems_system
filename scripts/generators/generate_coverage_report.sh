#!/bin/bash
# Script de geração de relatório de cobertura de testes
# Executa testes e gera relatório consolidado para EMS System

set -e

# Cores para output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Diretório raiz do projeto
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Diretório para relatórios consolidados
COVERAGE_DIR="$PROJECT_ROOT/coverage_reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="$COVERAGE_DIR/$TIMESTAMP"

# Metas de cobertura (conforme flutter_dart_rules.md)
SHARED_TARGET=90      # Shared (Domain/UseCases)
DATA_TARGET=80      # Client/Server (Data)
UI_TARGET=50        # UI (Widgets)

# Contadores
TOTAL_PACKAGES=0
TESTED_PACKAGES=0
FAILED_PACKAGES=0

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║            Relatório de Cobertura - EMS System             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Diretório: $PROJECT_ROOT${NC}"
echo -e "${CYAN}Relatório: $REPORT_DIR${NC}"
echo ""

# Criar diretórios
mkdir -p "$REPORT_DIR"

# ============================================================
# FUNÇÕES AUXILIARES
# ============================================================

# Função para reportar erro
report_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Função para reportar warning
report_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Função para reportar info
report_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Função para reportar sucesso
report_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# ============================================================
# FUNÇÕES DE VALIDAÇÃO
# ============================================================

# Função para validar estrutura de pacotes shared (ADR-0005)
validate_shared_structure() {
    local package_path="$1"
    local package_name=$(basename "$package_path")
    
    if [[ "$package_name" =~ _shared$ ]]; then
        if [ ! -d "$package_path/lib/src/domain" ]; then
            report_warning "Pacote shared '$package_name' não possui estrutura domain/ obrigatória (ADR-0005)"
        fi
        if [ ! -d "$package_path/lib/src/data" ]; then
            report_warning "Pacote shared '$package_name' não possui estrutura data/ obrigatória (ADR-0005)"
        fi
    fi
}

# ============================================================
# FUNÇÕES DE COBERTURA
# ============================================================

# Função para calcular cobertura de um arquivo lcov.info
calculate_coverage() {
    local lcov_file="$1"
    
    if [ ! -f "$lcov_file" ]; then
        echo "0"
        return
    fi
    
    # Extrair linhas executadas e totais
    local lines_found=$(grep -c "^DA:" "$lcov_file" || echo "0")
    local lines_hit=$(grep "^DA:" "$lcov_file" | grep -v ",0$" | wc -l || echo "0")
    
    if [ "$lines_found" -eq 0 ]; then
        echo "0"
        return
    fi
    
    # Calcular percentual
    local coverage=$((lines_hit * 100 / lines_found))
    echo "$coverage"
}

# Função para executar testes em um pacote
run_tests_for_package() {
    local package_path="$1"
    local package_name=$(basename "$package_path")
    
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Testando: $package_name${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    
    ((TOTAL_PACKAGES++))
    
    # Validar estrutura (ADR-0005)
    validate_shared_structure "$package_path"
    
    # Verificar se tem pasta test
    if [ ! -d "$package_path/test" ]; then
        echo -e "${YELLOW}⚠️  Sem pasta test/ - pulando${NC}"
        return
    fi
    
    # Verificar se tem arquivos de teste
    local test_files=$(find "$package_path/test" -name "*_test.dart" 2>/dev/null | wc -l)
    if [ "$test_files" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Sem arquivos *_test.dart - pulando${NC}"
        return
    fi
    
    echo -e "${CYAN}Encontrados $test_files arquivo(s) de teste${NC}"
    
    cd "$package_path"
    
    # Verificar se é pacote Flutter ou Dart
    local is_flutter=false
    if grep -q "flutter:" "$package_path/pubspec.yaml" 2>/dev/null; then
        is_flutter=true
    fi
    
    # Executar testes com cobertura
    echo -e "${CYAN}Executando testes...${NC}"
    
    if [ "$is_flutter" = true ]; then
        if flutter test --coverage --reporter expanded 2>&1 | tee "$REPORT_DIR/${package_name}_test.log"; then
            ((TESTED_PACKAGES++))
            echo -e "${GREEN}✅ Testes executados com sucesso${NC}"
        else
            ((FAILED_PACKAGES++))
            echo -e "${RED}❌ Falha nos testes${NC}"
            return 1
        fi
    else
        if dart test --coverage=coverage --reporter expanded 2>&1 | tee "$REPORT_DIR/${package_name}_test.log"; then
            ((TESTED_PACKAGES++))
            echo -e "${GREEN}✅ Testes executados com sucesso${NC}"
        else
            ((FAILED_PACKAGES++))
            echo -e "${RED}❌ Falha nos testes${NC}"
            return 1
        fi
    fi
    
    # Verificar se cobertura foi gerada
    if [ -f "coverage/lcov.info" ]; then
        # Copiar arquivo de cobertura
        cp "coverage/lcov.info" "$REPORT_DIR/${package_name}_lcov.info"
        
        # Calcular cobertura
        local coverage=$(calculate_coverage "coverage/lcov.info")
        echo -e "${CYAN}Cobertura: ${coverage}%${NC}"
        
        # Determinar meta baseado no tipo de pacote
        local target=$DATA_TARGET
        if [[ "$package_name" =~ _shared$ ]]; then
            target=$SHARED_TARGET
        elif [[ "$package_name" =~ _ui$ ]]; then
            target=$UI_TARGET
        fi
        
        # Verificar se atingiu a meta
        if [ "$coverage" -ge "$target" ]; then
            echo -e "${GREEN}✅ Meta atingida (≥${target}%)${NC}"
        else
            echo -e "${YELLOW}⚠️  Abaixo da meta (${target}%)${NC}"
        fi
        
        # Gerar HTML (se genhtml estiver disponível)
        if command -v genhtml &> /dev/null; then
            echo -e "${CYAN}Gerando relatório HTML...${NC}"
            genhtml -q "coverage/lcov.info" -o "$REPORT_DIR/${package_name}_html" 2>/dev/null || true
            echo -e "${GREEN}✅ HTML gerado em: $REPORT_DIR/${package_name}_html/index.html${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Arquivo de cobertura não encontrado${NC}"
    fi
    
    cd "$PROJECT_ROOT"
}

# Função para mesclar arquivos lcov
merge_coverage_files() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Mesclando arquivos de cobertura...${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    
    # Combinar todos os arquivos lcov.info
    cat "$REPORT_DIR"/*_lcov.info > "$REPORT_DIR/merged_lcov.info" 2>/dev/null || true
    
    if [ -f "$REPORT_DIR/merged_lcov.info" ]; then
        echo -e "${GREEN}✅ Cobertura mesclada: $REPORT_DIR/merged_lcov.info${NC}"
        
        # Gerar HTML consolidado
        if command -v genhtml &> /dev/null; then
            echo -e "${CYAN}Gerando relatório HTML consolidado...${NC}"
            genhtml -q "$REPORT_DIR/merged_lcov.info" -o "$REPORT_DIR/html" 2>/dev/null || true
            echo -e "${GREEN}✅ Relatório consolidado: $REPORT_DIR/html/index.html${NC}"
        fi
        
        # Calcular cobertura geral
        local overall_coverage=$(calculate_coverage "$REPORT_DIR/merged_lcov.info")
        echo -e "${CYAN}Cobertura Geral: ${overall_coverage}%${NC}"
    fi
}

# Função para gerar relatório textual
generate_text_report() {
    local report_file="$REPORT_DIR/summary.txt"
    
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Gerando relatório textual...${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    
    {
        echo "═══════════════════════════════════════════════════════════════"
        echo "        RELATÓRIO DE COBERTURA DE TESTES - EMS System"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "Data/Hora: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Diretório: $PROJECT_ROOT"
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "  MÉTRICAS GLOBAIS"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "Pacotes Encontrados:  $TOTAL_PACKAGES"
        echo "Pacotes Testados:     $TESTED_PACKAGES"
        echo "Pacotes com Falha:    $FAILED_PACKAGES"
        echo ""
        
        if [ -f "$REPORT_DIR/merged_lcov.info" ]; then
            local overall=$(calculate_coverage "$REPORT_DIR/merged_lcov.info")
            echo "Cobertura Geral:      ${overall}%"
        fi
        
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "  COBERTURA POR PACOTE"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        
        for lcov_file in "$REPORT_DIR"/*_lcov.info; do
            if [ -f "$lcov_file" ] && [[ ! "$lcov_file" =~ merged_lcov ]]; then
                local package_name=$(basename "$lcov_file" _lcov.info)
                local coverage=$(calculate_coverage "$lcov_file")
                
                # Determinar meta
                local target=$DATA_TARGET
                local type="Client/Server"
                if [[ "$package_name" =~ _shared$ ]]; then
                    target=$SHARED_TARGET
                    type="Shared"
                elif [[ "$package_name" =~ _ui$ ]]; then
                    target=$UI_TARGET
                    type="UI"
                fi
                
                # Status
                local status="✅"
                if [ "$coverage" -lt "$target" ]; then
                    status="⚠️ "
                fi
                
                printf "%-40s %3s%%  [Meta: %2s%%] %s %s\n" "$package_name" "$coverage" "$target" "$status" "$type"
            fi
        done
        
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "  METAS DE COBERTURA (flutter_dart_rules.md)"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "Shared (Domain/UseCases):        ${SHARED_TARGET}%"
        echo "Client/Server (Data):          ${DATA_TARGET}%"
        echo "UI (Widgets):                  ${UI_TARGET}%"
        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "  PRÓXIMOS PASSOS"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "Para validar documentação, execute:"
        echo "  ./scripts/check_documentation.sh"
        echo ""
        echo "Referências:"
        echo "  • Regras de Teste: docs/rules/flutter_dart_rules.md (Seção 6)"
        echo "  • Métricas KPI:    docs/rules/flutter_dart_rules.md (Seção 9)"
        echo ""
        
    } > "$report_file"
    
    # Mostrar relatório
    cat "$report_file"
    
    echo -e "\n${GREEN}✅ Relatório salvo em: $report_file${NC}"
}

# Função para descobrir pacotes (incluindo sub-features)
discover_packages() {
    local base_dir="$1"
    local packages=()
    
    # Buscar pacotes em dois níveis para suportar sub-features (ADR-0005)
    # Nível 1: packages/feature/feature_shared
    # Nível 2: packages/feature/sub-feature/sub-feature_shared
    
    # Buscar pacotes diretos
    for dir in "$base_dir"/*/*; do
        if [ -d "$dir" ] && [[ $(basename "$dir") =~ _(shared|client|server|ui)$ ]]; then
            packages+=("$dir")
        fi
    done
    
    # Buscar pacotes em sub-features
    for dir in "$base_dir"/*/*/*; do
        if [ -d "$dir" ] && [[ $(basename "$dir") =~ _(shared|client|server|ui)$ ]]; then
            packages+=("$dir")
        fi
    done
    
    printf '%s\n' "${packages[@]}"
}

# ============================================================
# MAIN - Execução Principal
# ============================================================

echo -e "${CYAN}Iniciando análise de cobertura...${NC}"
echo ""

# Validar se diretório packages existe
if [ ! -d "$PROJECT_ROOT/packages" ]; then
    report_error "Diretório packages/ não encontrado!"
    exit 1
fi

# Descobrir automaticamente todos os pacotes em packages/ (incluindo sub-features)
echo "Descobrindo pacotes em packages/..."
mapfile -t PACKAGES < <(discover_packages "$PROJECT_ROOT/packages")

# Validar pacotes encontrados
if [ ${#PACKAGES[@]} -eq 0 ]; then
    report_warning "Nenhum pacote encontrado em packages/"
    exit 0
else
    echo "Encontrados ${#PACKAGES[@]} pacotes"
    echo ""
fi

# Executar testes em cada pacote
for package_path in "${PACKAGES[@]}"; do
    if [ -d "$package_path" ]; then
        run_tests_for_package "$package_path" || true
    else
        report_warning "Pacote não encontrado: $package_path"
    fi
done

# Mesclar coberturas
merge_coverage_files

# Gerar relatório textual
generate_text_report

# Criar symlink para último relatório
ln -sfn "$REPORT_DIR" "$COVERAGE_DIR/latest"

# Relatório Final
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}           RELATÓRIO FINAL${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Pacotes Testados: $TESTED_PACKAGES/$TOTAL_PACKAGES${NC}"
echo -e "${RED}Pacotes com Falha: $FAILED_PACKAGES${NC}"
echo ""
echo -e "${CYAN}Relatórios gerados em:${NC}"
echo -e "  • Consolidado: ${REPORT_DIR}/html/index.html"
echo -e "  • Resumo:      ${REPORT_DIR}/summary.txt"
echo -e "  • Último:      ${COVERAGE_DIR}/latest/"
echo ""

# Status de saída
if [ $FAILED_PACKAGES -gt 0 ]; then
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║    ❌ FALHAS NOS TESTES - Corrigir pacotes com erro        ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    exit 1
else
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║    ✅ TESTES CONCLUÍDOS - Ver relatório para detalhes      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    exit 0
fi
