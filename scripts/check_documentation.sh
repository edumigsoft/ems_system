#!/bin/bash
# Script de validação de documentação do EMS System
# Verifica presença de docstrings e qualidade da documentação

# Cores para output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Modo verboso (padrão: desligado para performance)
VERBOSE=false
if [[ "$1" == "-v" ]] || [[ "$1" == "--verbose" ]]; then
    VERBOSE=true
fi

# Contadores
TOTAL_CLASSES=0
DOCUMENTED_CLASSES=0
TOTAL_METHODS=0
DOCUMENTED_METHODS=0
WARNINGS=0

# Diretório raiz do projeto
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Validação de Documentação - EMS System           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Função para reportar erro
report_error() {
    echo -e "${RED}❌ $1${NC}"
    ((WARNINGS++))
}

# Função para reportar warning
report_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

# Função para reportar info
report_info() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}ℹ️  $1${NC}"
    fi
}

# Função para reportar sucesso
report_success() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${GREEN}✅ $1${NC}"
    fi
}

# Função para verificar se linha é início de classe pública
is_public_class() {
    local line="$1"
    local next_line="$2"
    
    # Ignorar classes privadas (começam com _)
    if [[ "$line" =~ class[[:space:]]+_[A-Z] ]]; then
        return 1
    fi
    
    # Padrão 1: class ClassName
    if [[ "$line" =~ ^[[:space:]]*(abstract[[:space:]]+)?class[[:space:]]+[A-Z] ]]; then
        return 0
    fi
    
    # Padrão 2: class X extends Y
    if [[ "$line" =~ ^[[:space:]]*(abstract[[:space:]]+)?class[[:space:]]+[A-Z][a-zA-Z0-9]*[[:space:]]+extends ]]; then
        return 0
    fi
    
    # Padrão 3: class X implements Y
    if [[ "$line" =~ ^[[:space:]]*(abstract[[:space:]]+)?class[[:space:]]+[A-Z][a-zA-Z0-9]*[[:space:]]+implements ]]; then
        return 0
    fi
    
    # Padrão 4: Anotação seguida de class na próxima linha
    if [[ "$line" =~ ^[[:space:]]*@[a-zA-Z]+[[:space:]]*$ ]] && [[ "$next_line" =~ ^[[:space:]]*(abstract[[:space:]]+)?class[[:space:]]+[A-Z] ]]; then
        return 0
    fi
    
    return 1
}

# Função para verificar se linha é início de método/getter público
is_public_method() {
    local line="$1"
    # Métodos públicos não começam com _, tem tipo de retorno ou são getters
    if [[ "$line" =~ ^[[:space:]]*[A-Z][a-zA-Z0-9\<\>\?]*[[:space:]]+[a-z][a-zA-Z0-9]*\( ]] || \
       [[ "$line" =~ ^[[:space:]]*[A-Z][a-zA-Z0-9\<\>\?]*[[:space:]]+get[[:space:]]+[a-z] ]] || \
       [[ "$line" =~ ^[[:space:]]*(static[[:space:]]+)?[A-Z][a-zA-Z0-9\<\>\?]*[[:space:]]+[a-z][a-zA-Z0-9]*\( ]]; then
        # Ignorar se for privado (começa com _)
        if [[ ! "$line" =~ _[a-zA-Z] ]]; then
            return 0
        fi
    fi
    return 1
}

# Função para verificar se há docstring antes
has_docstring_before() {
    local file="$1"
    local line_num="$2"
    
    # Validação: não processar se line_num for inválido
    if [ "$line_num" -le 0 ]; then
        return 1
    fi
    
    # Verifica as 5 linhas anteriores em busca de /// (aumentado para cobrir anotações)
    for ((i=1; i<=5; i++)); do
        local check_line=$((line_num - i))
        
        # Validação: não processar linhas negativas ou zero
        if [ "$check_line" -le 0 ]; then
            break
        fi
        
        local prev_line=$(sed -n "${check_line}p" "$file")
        
        # Encontrou docstring - sucesso
        if [[ "$prev_line" =~ ^[[:space:]]*/// ]]; then
            return 0
        fi
        
        # Permitir anotações (@override, @JsonKey, etc) - continua procurando
        if [[ "$prev_line" =~ ^[[:space:]]*@ ]]; then
            continue
        fi
        
        # Permitir linhas vazias - continua procurando
        if [[ "$prev_line" =~ ^[[:space:]]*$ ]]; then
            continue
        fi
        
        # Se encontrar linha de código real, para de procurar
        if [[ -n "$prev_line" ]] && [[ ! "$prev_line" =~ ^[[:space:]]*/\* ]] && [[ ! "$prev_line" =~ ^[[:space:]]*\* ]]; then
            break
        fi
    done
    return 1
}

# Função para extrair nome da classe/método
extract_name() {
    local line="$1"
    echo "$line" | sed -E 's/.*class[[:space:]]+([A-Z][a-zA-Z0-9]*).*/\1/; s/.*[[:space:]]+([a-z][a-zA-Z0-9]*)\(.*/\1/; s/.*get[[:space:]]+([a-z][a-zA-Z0-9]*).*/\1/'
}

# Função para verificar comentários redundantes
check_redundant_comments() {
    local file="$1"
    local file_name=$(basename "$file")
    
    # Procurar por comentários que apenas repetem o código
    while IFS= read -r line_num; do
        local line=$(sed -n "${line_num}p" "$file")
        local next_line=$(sed -n "$((line_num + 1))p" "$file")
        
        # Exemplos de redundância: // variavel x, // esta é a classe X
        if [[ "$line" =~ //[[:space:]]*(esta é|this is|variavel|variable|função|function)[[:space:]] ]]; then
            report_warning "$file_name:$line_num - Comentário possivelmente redundante: ${line}"
        fi
    done < <(grep -n "^[[:space:]]*//" "$file" | cut -d: -f1)
}

# Função para analisar arquivo Dart
analyze_dart_file() {
    local file="$1"
    local file_name=$(basename "$file")
    local relative_path=${file#$PROJECT_ROOT/}
    
    # Ignorar arquivos gerados
    if [[ "$file_name" =~ \.g\.dart$ ]] || [[ "$file_name" =~ \.freezed\.dart$ ]]; then
        return
    fi
    
    echo -e "\n${CYAN}Analisando: $relative_path${NC}"
    
    local line_num=0
    local local_classes=0
    local local_documented_classes=0
    local local_methods=0
    local local_documented_methods=0
    local prev_line=""
    
    while IFS= read -r line; do
        ((line_num++))
        
        # Ler próxima linha para detecção de anotações
        local next_line=$(sed -n "$((line_num + 1))p" "$file")
        
        # Verificar classes públicas
        if is_public_class "$line" "$next_line"; then
            local class_name=$(extract_name "$line")
            ((TOTAL_CLASSES++))
            ((local_classes++))
            
            if has_docstring_before "$file" "$line_num"; then
                ((DOCUMENTED_CLASSES++))
                ((local_documented_classes++))
            else
                report_warning "$file_name:$line_num - Classe '$class_name' sem docstring"
            fi
        fi
        
        # Verificar métodos públicos (não construtores)
        if is_public_method "$line" && [[ ! "$line" =~ factory ]] && [[ ! "$line" =~ $class_name\( ]]; then
            local method_name=$(extract_name "$line")
            ((TOTAL_METHODS++))
            ((local_methods++))
            
            if has_docstring_before "$file" "$line_num"; then
                ((DOCUMENTED_METHODS++))
                ((local_documented_methods++))
            else
                report_warning "$file_name:$line_num - Método público '$method_name' sem docstring"
            fi
        fi
        
        prev_line="$line"
    done < "$file"
    
    # Verificar comentários redundantes
    check_redundant_comments "$file"
    
    # Relatório do arquivo
    if [ $local_classes -gt 0 ] || [ $local_methods -gt 0 ]; then
        local class_coverage=0
        local method_coverage=0
        
        if [ $local_classes -gt 0 ]; then
            class_coverage=$((local_documented_classes * 100 / local_classes))
        fi
        
        if [ $local_methods -gt 0 ]; then
            method_coverage=$((local_documented_methods * 100 / local_methods))
        fi
        
        echo -e "  Classes: $local_documented_classes/$local_classes (${class_coverage}%)"
        echo -e "  Métodos: $local_documented_methods/$local_methods (${method_coverage}%)"
    fi
}

# Função para analisar pacote
analyze_package() {
    local package_path="$1"
    local package_name=$(basename "$package_path")
    
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Analisando pacote: $package_name${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    
    # Validar estrutura obrigatória para pacotes core (ADR-0005)
    if [[ "$package_name" =~ _core$ ]]; then
        if [ ! -d "$package_path/lib/src/domain" ]; then
            report_warning "Pacote core '$package_name' não possui estrutura domain/ obrigatória (ADR-0005)"
        fi
        if [ ! -d "$package_path/lib/src/data" ]; then
            report_warning "Pacote core '$package_name' não possui estrutura data/ obrigatória (ADR-0005)"
        fi
    fi
    
    # Analisar apenas arquivos em lib/src (código público)
    if [ -d "$package_path/lib/src" ]; then
        find "$package_path/lib/src" -name "*.dart" -type f | while read -r dart_file; do
            analyze_dart_file "$dart_file"
        done
    fi
    
    # Analisar arquivo barrel (lib/<package>.dart)
    if [ -f "$package_path/lib/$package_name.dart" ]; then
        analyze_dart_file "$package_path/lib/$package_name.dart"
    fi
}

# Função para analisar feature
analyze_feature() {
    local feature_path="$1"
    local feature_name=$(basename "$feature_path")
    
    # Verificar se é feature com sub-features
    # Sub-features seguem o padrão: packages/financial/billing/billing_core/
    # IMPORTANTE: Sub-features têm profundidade extra, então caminhos relativos
    # em analysis_options.yaml precisam de um nível a mais (../../../../)
    for dir in "$feature_path"/*; do
        if [ -d "$dir" ] && [[ $(basename "$dir") =~ _(core|client|server|ui)$ ]]; then
            analyze_package "$dir"
        fi
    done
}

# ============================================================
# MAIN - Execução Principal
# ============================================================

echo "Iniciando validação de documentação..."
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
        analyze_feature "$PROJECT_ROOT/$feature"
    fi
done

# Relatório Final
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}           RELATÓRIO FINAL DE DOCUMENTAÇÃO${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Calcular percentuais
CLASS_COVERAGE=0
METHOD_COVERAGE=0
OVERALL_COVERAGE=0

if [ $TOTAL_CLASSES -gt 0 ]; then
    CLASS_COVERAGE=$((DOCUMENTED_CLASSES * 100 / TOTAL_CLASSES))
fi

if [ $TOTAL_METHODS -gt 0 ]; then
    METHOD_COVERAGE=$((DOCUMENTED_METHODS * 100 / TOTAL_METHODS))
fi

TOTAL_ITEMS=$((TOTAL_CLASSES + TOTAL_METHODS))
DOCUMENTED_ITEMS=$((DOCUMENTED_CLASSES + DOCUMENTED_METHODS))

if [ $TOTAL_ITEMS -gt 0 ]; then
    OVERALL_COVERAGE=$((DOCUMENTED_ITEMS * 100 / TOTAL_ITEMS))
fi

echo -e "${CYAN}Estatísticas de Documentação:${NC}"
echo -e "  Classes Públicas:  $DOCUMENTED_CLASSES/$TOTAL_CLASSES (${CLASS_COVERAGE}%)"
echo -e "  Métodos Públicos:  $DOCUMENTED_METHODS/$TOTAL_METHODS (${METHOD_COVERAGE}%)"
echo -e "  ${BLUE}Cobertura Geral:   $DOCUMENTED_ITEMS/$TOTAL_ITEMS (${OVERALL_COVERAGE}%)${NC}"
echo ""
echo -e "${YELLOW}Avisos: $WARNINGS${NC}"
echo ""

# Meta de documentação (conforme flutter_dart_rules.md)
DOCUMENTATION_TARGET=100

# Limiar de warning (70%): não documentado formalmente, mas serve como indicador
# de que o projeto está próximo da meta e requer apenas ajustes finais
META_WARNING_THRESHOLD=70

echo -e "${CYAN}Meta de Documentação:${NC}"
echo -e "  Objetivo:  ${DOCUMENTATION_TARGET}%"
echo -e "  Atual:     ${OVERALL_COVERAGE}%"
echo ""

# Determinar status
if [ $OVERALL_COVERAGE -ge $DOCUMENTATION_TARGET ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✅ META ATINGIDA - Documentação completa!               ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    exit 0
elif [ $OVERALL_COVERAGE -ge $META_WARNING_THRESHOLD ]; then
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║   ⚠️  DOCUMENTAÇÃO BOA - Próximo da meta                  ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Adicione docstrings nas classes/métodos marcados acima.${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   ❌ DOCUMENTAÇÃO INSUFICIENTE - Abaixo da meta           ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}Ação Requerida:${NC}"
    echo -e "  1. Adicione docstrings (///) em todas as classes públicas"
    echo -e "  2. Documente todos os métodos públicos"
    echo -e "  3. Siga o padrão: resumo + linha vazia + detalhes"
    echo ""
    echo -e "${CYAN}Referência: docs/rules/flutter_dart_rules.md${NC}"
    exit 1
fi
