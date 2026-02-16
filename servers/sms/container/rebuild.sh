#!/bin/bash
# Script para rebuild do servidor SMS com garantia de nova imagem
# Uso: ./rebuild.sh [--follow-logs]

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

# Verificar se deve seguir os logs
FOLLOW_LOGS=false
if [ "$1" = "--follow-logs" ] || [ "$1" = "-f" ]; then
    FOLLOW_LOGS=true
fi

# Ler versão do pubspec.yaml
PUBSPEC_PATH="../server_v1/pubspec.yaml"
if [ ! -f "$PUBSPEC_PATH" ]; then
    echo "⚠️  pubspec.yaml não encontrado em $PUBSPEC_PATH"
    echo "   Usando versão 'dev'"
    VERSION="dev"
else
    VERSION=$(grep '^version:' "$PUBSPEC_PATH" | sed 's/version: *//' | tr -d ' ')
    if [ -z "$VERSION" ]; then
        VERSION="dev"
    fi
fi

echo ""
log_info "=== Rebuild SMS Server ==="
log_info "Versão: $VERSION"
echo ""

# Passo 1: Parar container
log_info "Passo 1/5: Parando container..."
docker compose down
log_success "Container parado"
echo ""

# Passo 2: Remover imagem antiga
log_info "Passo 2/5: Removendo imagem antiga..."
docker rmi sms-server:latest 2>/dev/null && log_success "Imagem removida" || echo "   (imagem não encontrada, ok)"
echo ""

# Passo 3: Build com versão
log_info "Passo 3/5: Building imagem com versão $VERSION..."
docker compose build --no-cache --build-arg VERSION=$VERSION
log_success "Build concluído"
echo ""

# Passo 4: Subir container
log_info "Passo 4/5: Subindo container..."
docker compose up -d
log_success "Container iniciado"
echo ""

# Passo 5: Mostrar logs
log_info "Passo 5/5: Logs recentes"
echo ""
docker compose logs --tail=30

echo ""
log_success "Rebuild concluído!"
echo ""

# Passo 6: Validar health
log_info "Validando servidor..."
echo ""

# Carregar porta do .env local
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | grep SERVER_PORT | xargs)
fi

# Usar porta padrão se não encontrada
SERVER_PORT=${SERVER_PORT:-8080}

# Ler BACKEND_PATH_API do .env do servidor
BACKEND_PATH_API=$(grep '^BACKEND_PATH_API=' ../server_v1/.env 2>/dev/null | cut -d'=' -f2)
if [ -z "$BACKEND_PATH_API" ]; then
    BACKEND_PATH_API="/api/v1"  # Fallback padrão
fi

log_info "Aguardando servidor inicializar (5s)..."
sleep 5

# Tentar URLs em ordem de prioridade
HEALTH_URLS=(
    "https://sms.local${BACKEND_PATH_API}/health"
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

# Validar se encontrou resposta válida
if [ -n "$HEALTH_URL" ]; then
    log_success "Servidor respondeu: $HEALTH_URL"
    echo ""
    echo "Resposta:"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
    echo ""

    # Verificar se a versão está correta
    RESPONSE_VERSION=$(echo "$BODY" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$RESPONSE_VERSION" ]; then
        if [ "$RESPONSE_VERSION" = "$VERSION" ]; then
            log_success "Versão confirmada: $RESPONSE_VERSION ✓"
        else
            log_warning "Versão diferente - Esperado: $VERSION, Recebido: $RESPONSE_VERSION"
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

echo ""
log_info "Comandos úteis:"
echo "  • Ver logs em tempo real: docker compose logs -f"
echo "  • Verificar saúde: curl -k ${HEALTH_URLS[0]}"
echo "  • Parar servidor: docker compose down"
echo ""

# Seguir logs se solicitado
if [ "$FOLLOW_LOGS" = true ]; then
    echo ""
    log_info "Seguindo logs (Ctrl+C para sair)..."
    echo ""
    docker compose logs -f
fi
