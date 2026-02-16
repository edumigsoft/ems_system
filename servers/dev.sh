#!/bin/bash
# Script para desenvolvimento local - Build + Test + Health Check
# Uso: ./dev.sh <ems|sms> [--follow-logs|-f]

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
    log_error "Uso: $0 <ems|sms> [--follow-logs|-f]"
    exit 1
fi

SERVER=$1
FOLLOW_LOGS=false

# Verificar flag de logs
if [ "$2" = "--follow-logs" ] || [ "$2" = "-f" ]; then
    FOLLOW_LOGS=true
fi

# Validar servidor
if [[ ! "$SERVER" =~ ^(ems|sms)$ ]]; then
    log_error "Servidor inválido: $SERVER. Use 'ems' ou 'sms'"
    exit 1
fi

# Determinar diretório raiz do projeto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configurações por servidor
if [ "$SERVER" = "ems" ]; then
    SERVER_DIR="ems"
    CONTAINER_DIR="$PROJECT_ROOT/servers/ems/container"
    PUBSPEC_PATH="$PROJECT_ROOT/servers/ems/server_v1/pubspec.yaml"
    CONTAINER_NAME="ems_server_dev"
elif [ "$SERVER" = "sms" ]; then
    SERVER_DIR="sms"
    CONTAINER_DIR="$PROJECT_ROOT/servers/sms/container"
    PUBSPEC_PATH="$PROJECT_ROOT/servers/sms/server_v1/pubspec.yaml"
    CONTAINER_NAME="sms_server_dev"
fi

# Ler versão do pubspec.yaml
if [ ! -f "$PUBSPEC_PATH" ]; then
    log_warning "pubspec.yaml não encontrado em $PUBSPEC_PATH"
    log_warning "Usando versão 'dev'"
    VERSION="dev"
else
    VERSION=$(grep '^version:' "$PUBSPEC_PATH" | sed 's/version: *//' | tr -d ' ')
    if [ -z "$VERSION" ]; then
        VERSION="dev"
    fi
fi

echo ""
log_info "=== Build Desenvolvimento ${SERVER^^} Server ==="
log_info "Versão: $VERSION"
log_info "Environment: development"
echo ""

# Passo 1: Parar container anterior
log_info "Passo 1/5: Parando container anterior..."
cd "$CONTAINER_DIR"
docker compose -f docker-compose.dev.yml down 2>/dev/null || true
log_success "Container parado"
echo ""

# Passo 2: Build com environment=development
log_info "Passo 2/5: Building imagem (development)..."
docker compose -f docker-compose.dev.yml build --build-arg VERSION=$VERSION --build-arg ENVIRONMENT=development
log_success "Build concluído"
echo ""

# Passo 3: Subir container
log_info "Passo 3/5: Subindo container..."
docker compose -f docker-compose.dev.yml up -d
log_success "Container iniciado"
echo ""

# Passo 4: Aguardar e fazer health check
log_info "Passo 4/5: Aguardando servidor inicializar (5s)..."
sleep 5

# Carregar porta do .env local
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | grep SERVER_PORT | xargs)
fi

# Usar porta padrão se não encontrada
SERVER_PORT=${SERVER_PORT:-8181}

# Ler BACKEND_PATH_API do .env do servidor
BACKEND_PATH_API=$(grep '^BACKEND_PATH_API=' ../server_v1/.env 2>/dev/null | cut -d'=' -f2)
if [ -z "$BACKEND_PATH_API" ]; then
    BACKEND_PATH_API="/api/v1"  # Fallback padrão
fi

# Tentar URLs em ordem de prioridade
HEALTH_URLS=(
    "https://${SERVER}.local${BACKEND_PATH_API}/health"
    "http://localhost:${SERVER_PORT}${BACKEND_PATH_API}/health"
)

# Loop para testar cada URL
HEALTH_RESPONSE=""
HEALTH_URL=""
HTTP_CODE=""
BODY=""

for url in "${HEALTH_URLS[@]}"; do
    log_info "Testando: $url"

    # curl com -k (insecure) para aceitar certificados self-signed
    RESPONSE=$(curl -k -s -w "\nHTTP_CODE:%{http_code}" "$url" 2>/dev/null)
    HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
    BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE:/d')

    if [ "$HTTP_CODE" = "200" ]; then
        HEALTH_URL="$url"
        HEALTH_RESPONSE="$RESPONSE"
        break
    fi
done

echo ""

# Validar resposta
if [ -n "$HEALTH_URL" ]; then
    log_success "Servidor respondeu: $HEALTH_URL"
    echo ""
    echo "Resposta:"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
    echo ""

    # Verificar versão
    RESPONSE_VERSION=$(echo "$BODY" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$RESPONSE_VERSION" ]; then
        if [ "$RESPONSE_VERSION" = "$VERSION" ]; then
            log_success "Versão confirmada: $RESPONSE_VERSION ✓"
        else
            log_warning "Versão diferente - Esperado: $VERSION, Recebido: $RESPONSE_VERSION"
        fi
    fi

    # Verificar environment
    RESPONSE_ENV=$(echo "$BODY" | grep -o '"env":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$RESPONSE_ENV" ]; then
        if [ "$RESPONSE_ENV" = "development" ]; then
            log_success "Environment confirmado: development ✓"
        else
            log_warning "Environment diferente - Esperado: development, Recebido: $RESPONSE_ENV"
        fi
    fi
else
    log_error "Servidor não respondeu em nenhuma URL"
    echo ""
    log_info "URLs testadas:"
    for url in "${HEALTH_URLS[@]}"; do
        echo "  ✗ $url"
    done
    echo ""
    log_info "Verifique os logs com: docker compose logs -f"
fi

# Passo 5: Mostrar logs recentes
echo ""
log_info "Passo 5/5: Logs recentes (últimas 30 linhas)"
echo ""
docker compose -f docker-compose.dev.yml logs --tail=30

echo ""
log_success "=== Build desenvolvimento concluído! ==="
echo ""
log_info "Comandos úteis:"
echo "  • Ver logs em tempo real: cd $CONTAINER_DIR && docker compose -f docker-compose.dev.yml logs -f"
echo "  • Verificar saúde: curl -k ${HEALTH_URLS[0]}"
echo "  • Parar servidor: cd $CONTAINER_DIR && docker compose -f docker-compose.dev.yml down"
echo ""

# Seguir logs se solicitado
if [ "$FOLLOW_LOGS" = true ]; then
    echo ""
    log_info "Seguindo logs (Ctrl+C para sair)..."
    echo ""
    docker compose -f docker-compose.dev.yml logs -f
fi
