#!/bin/bash
# Script para deploy em VPS - Pull imagem GHCR + restart
# Uso: ./update.sh <ems|sms> [version]

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
    echo "  $0 ems              # Pull :latest (padrão)"
    echo "  $0 ems 1.1.3        # Pull versão específica"
    echo "  $0 ems v1.1         # Pull série 1.1.x"
    exit 1
fi

SERVER=$1

# Se versão não fornecida, pedir ao usuário
if [ -z "$2" ]; then
    echo ""
    log_info "Versões disponíveis:"
    echo "  • latest (mais recente)"
    echo "  • Versão específica (ex: 1.1.0)"
    echo "  • Série de versão (ex: v1.1)"
    echo ""
    read -p "Digite a versão [latest]: " VERSION_INPUT
    VERSION=${VERSION_INPUT:-latest}
else
    VERSION=$2
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
CONTAINER_DIR="$PROJECT_ROOT/servers/$SERVER/container"
IMAGE="ghcr.io/edumigsoft/${SERVER}-server:${VERSION}"

echo ""
log_info "=== Deploy ${SERVER^^} Server ==="
log_info "Versão: $VERSION"
log_info "Imagem: $IMAGE"
echo ""

# Validar docker-compose.prod.yml existe
cd "$CONTAINER_DIR"
if [ ! -f "docker-compose.prod.yml" ]; then
    log_error "docker-compose.prod.yml não encontrado em $CONTAINER_DIR"
    exit 1
fi

# Verificar se GITHUB_TOKEN está definido
if [ -z "$GITHUB_TOKEN" ]; then
    # Tentar carregar de /root/apps/.secrets/github
    GLOBAL_SECRETS_FILE="/root/apps/.secrets/github"
    if [ -f "$GLOBAL_SECRETS_FILE" ]; then
        log_info "Carregando GITHUB_TOKEN de $GLOBAL_SECRETS_FILE"
        source "$GLOBAL_SECRETS_FILE"
    fi
fi

# Se ainda não estiver definido, pedir interativamente
if [ -z "$GITHUB_TOKEN" ]; then
    log_warning "GITHUB_TOKEN não definido"
    echo ""
    echo "Para autenticar no GHCR, defina a variável de ambiente:"
    echo "  export GITHUB_TOKEN=ghp_your_token_here"
    echo ""
    echo "Ou configure globalmente em: $GLOBAL_SECRETS_FILE"
    echo ""
    echo "Ou gere um token em: https://github.com/settings/tokens"
    echo "  Permissões necessárias: read:packages"
    echo ""
    read -sp "GITHUB_TOKEN: " GITHUB_TOKEN
    echo ""
fi

# Passo 1: Login GHCR
log_info "Passo 1/4: Login no GitHub Container Registry..."
echo "$GITHUB_TOKEN" | docker login ghcr.io -u edumigsoft --password-stdin 2>&1 | grep -i "login succeeded" > /dev/null
if [ $? -eq 0 ]; then
    log_success "Login GHCR OK"
else
    log_error "Falha no login GHCR"
    exit 1
fi
echo ""

# Passo 2: Pull da imagem
log_info "Passo 2/4: Pull da imagem: $IMAGE"
if docker pull "$IMAGE"; then
    log_success "Pull concluído"
else
    log_error "Falha no pull da imagem $IMAGE"
    log_warning "Verifique se a tag existe: https://github.com/edumigsoft/ems_system/pkgs/container/${SERVER}-server"
    exit 1
fi
echo ""

# Confirmação para versões específicas (não latest)
if [ "$VERSION" != "latest" ]; then
    log_warning "Você está prestes a fazer deploy da versão: $VERSION"
    read -p "Confirmar deploy? [y/N]: " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        log_info "Deploy cancelado pelo usuário"
        exit 0
    fi
    echo ""
fi

# Passo 3: Restart com IMAGE_TAG
log_info "Passo 3/4: Reiniciando container com versão: $VERSION"
IMAGE_TAG=$VERSION docker compose -f docker-compose.prod.yml up -d --force-recreate
log_success "Container reiniciado"
echo ""

# Passo 4: Health check
log_info "Passo 4/4: Aguardando servidor inicializar (5s)..."
sleep 5

# Verificar se container está rodando
CONTAINER_NAME="${SERVER}_server_prod"
if docker ps --filter "name=$CONTAINER_NAME" --filter "status=running" | grep -q "$CONTAINER_NAME"; then
    log_success "Container $CONTAINER_NAME está rodando"

    # Tentar fazer health check (opcional - pode não estar acessível de fora)
    if [ -f ".env" ]; then
        export $(grep -v '^#' .env | grep -E '(SERVER_PORT|BACKEND_PATH_API)' | xargs)
    fi

    SERVER_PORT=${SERVER_PORT:-8181}
    BACKEND_PATH_API=${BACKEND_PATH_API:-/api/v1}

    # Tentar acessar health endpoint (pode falhar em produção com NPM)
    HEALTH_URL="http://localhost:${SERVER_PORT}${BACKEND_PATH_API}/health"
    log_info "Testando health endpoint: $HEALTH_URL"

    HEALTH_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" "$HEALTH_URL" 2>/dev/null || echo "")
    HTTP_CODE=$(echo "$HEALTH_RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)

    if [ "$HTTP_CODE" = "200" ]; then
        BODY=$(echo "$HEALTH_RESPONSE" | sed '/HTTP_CODE:/d')
        log_success "Health check OK"
        echo ""
        echo "Resposta:"
        echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
    else
        log_warning "Health endpoint não acessível (pode ser normal em produção com NPM)"
        log_info "Verifique os logs com: docker compose -f docker-compose.prod.yml logs -f"
    fi
else
    log_error "Container $CONTAINER_NAME não está rodando"
    echo ""
    log_info "Logs do container:"
    docker compose -f docker-compose.prod.yml logs --tail=50
    exit 1
fi

echo ""

# Passo 5: Mostrar logs recentes
log_info "Logs recentes (últimas 20 linhas):"
echo ""
docker compose -f docker-compose.prod.yml logs --tail=20

echo ""
log_success "=== Deploy concluído! ==="
echo ""
log_info "Informações:"
echo "  • Servidor: ${SERVER^^}"
echo "  • Versão: $VERSION"
echo "  • Container: $CONTAINER_NAME"
echo ""
log_info "Comandos úteis:"
echo "  • Ver logs: cd $CONTAINER_DIR && docker compose -f docker-compose.prod.yml logs -f"
echo "  • Status: docker ps --filter name=$CONTAINER_NAME"
echo "  • Rollback: cd $(dirname $SCRIPT_DIR)/servers && ./rollback.sh $SERVER [version]"
echo ""
