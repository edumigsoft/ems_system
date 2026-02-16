#!/bin/bash
# Script para rollback em VPS - Voltar para versão anterior
# Uso: ./rollback.sh <ems|sms> [version]

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Validar argumentos
if [ $# -lt 1 ]; then
    log_error "Uso: $0 <ems|sms> [version]"
    echo ""
    echo "Exemplos:"
    echo "  $0 ems 1.1.2        # Rollback para versão específica"
    echo "  $0 ems v1.0         # Rollback para série anterior"
    echo "  $0 ems              # Solicita versão interativamente"
    exit 1
fi

SERVER=$1
ROLLBACK_VERSION=$2

# Validar servidor
if [[ ! "$SERVER" =~ ^(ems|sms)$ ]]; then
    log_error "Servidor inválido: $SERVER. Use 'ems' ou 'sms'"
    exit 1
fi

echo ""
log_warning "=== ROLLBACK ${SERVER^^} Server ==="
echo ""

# Se versão não especificada, solicitar interativamente
if [ -z "$ROLLBACK_VERSION" ]; then
    log_info "Versões comuns para rollback:"
    echo "  • Versão específica (ex: 1.1.2, 1.0.5)"
    echo "  • Série anterior (ex: v1.1, v1.0)"
    echo ""
    read -p "Digite a versão para rollback: " ROLLBACK_VERSION

    if [ -z "$ROLLBACK_VERSION" ]; then
        log_error "Versão não especificada. Rollback cancelado."
        exit 1
    fi
fi

# Obter versão atual (se possível)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONTAINER_DIR="$PROJECT_ROOT/servers/$SERVER/container"
CONTAINER_NAME="${SERVER}_server_prod"

echo ""
log_info "Informações do rollback:"
echo "  • Servidor: ${SERVER^^}"
echo "  • Versão de destino: $ROLLBACK_VERSION"
echo ""

# Tentar obter versão atual
CURRENT_VERSION="desconhecida"
cd "$CONTAINER_DIR"
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | grep -E '(SERVER_PORT|BACKEND_PATH_API)' | xargs 2>/dev/null)
fi

SERVER_PORT=${SERVER_PORT:-8181}
BACKEND_PATH_API=${BACKEND_PATH_API:-/api/v1}
HEALTH_URL="http://localhost:${SERVER_PORT}${BACKEND_PATH_API}/health"

HEALTH_RESPONSE=$(curl -s "$HEALTH_URL" 2>/dev/null || echo "")
if [ -n "$HEALTH_RESPONSE" ]; then
    CURRENT_VERSION=$(echo "$HEALTH_RESPONSE" | grep -o '"version":"[^"]*"' | cut -d'"' -f4 || echo "desconhecida")
fi

if [ "$CURRENT_VERSION" != "desconhecida" ]; then
    log_info "Versão atual: $CURRENT_VERSION"
    echo ""
fi

# Confirmação OBRIGATÓRIA
log_warning "ATENÇÃO: Esta operação substituirá a versão atual."
log_warning "Certifique-se de que a versão $ROLLBACK_VERSION existe no GHCR."
echo ""
read -p "Confirmar rollback de $CURRENT_VERSION para $ROLLBACK_VERSION? [y/N]: " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    log_info "Rollback cancelado pelo usuário"
    exit 0
fi

echo ""
log_info "Executando rollback..."
echo ""

# Executar update.sh com a versão de rollback
if [ -f "$SCRIPT_DIR/update.sh" ]; then
    "$SCRIPT_DIR/update.sh" "$SERVER" "$ROLLBACK_VERSION"
else
    log_error "Script update.sh não encontrado em $SCRIPT_DIR"
    exit 1
fi

# Validação pós-rollback
echo ""
log_info "Validando rollback..."
sleep 3

# Tentar validar versão via health endpoint
HEALTH_RESPONSE=$(curl -s "$HEALTH_URL" 2>/dev/null || echo "")
if [ -n "$HEALTH_RESPONSE" ]; then
    NEW_VERSION=$(echo "$HEALTH_RESPONSE" | grep -o '"version":"[^"]*"' | cut -d'"' -f4 || echo "desconhecida")

    if [ "$NEW_VERSION" = "$ROLLBACK_VERSION" ]; then
        log_success "Versão confirmada via health endpoint: $NEW_VERSION ✓"
    elif [ "$NEW_VERSION" != "desconhecida" ]; then
        log_warning "Versão no health endpoint: $NEW_VERSION (esperado: $ROLLBACK_VERSION)"
        log_info "Nota: Pode haver diferença entre tag da imagem e versão no health endpoint"
    fi
fi

echo ""
log_success "=== Rollback concluído! ==="
echo ""
log_info "Resumo:"
echo "  • Versão anterior: $CURRENT_VERSION"
echo "  • Versão atual: $ROLLBACK_VERSION"
echo "  • Servidor: ${SERVER^^}"
echo ""
log_info "Próximos passos:"
echo "  • Verifique os logs: cd $CONTAINER_DIR && docker compose -f docker-compose.prod.yml logs -f"
echo "  • Teste a aplicação: curl $HEALTH_URL"
echo "  • Se necessário, faça novo rollback: $SCRIPT_DIR/rollback.sh $SERVER [version]"
echo ""
