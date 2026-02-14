#!/bin/bash
set -e

# Script simplificado para atualizar servidor EMS na VPS
# Uso: ./update.sh

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funções de log
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

# Verificar docker-compose.prod.yml
if [ ! -f "docker-compose.prod.yml" ]; then
    log_error "docker-compose.prod.yml não encontrado!"
    log_error "Execute este script no diretório servers/ems/container/"
    exit 1
fi

echo ""
log_info "=== Update EMS Server (latest) ==="
echo ""

# Verificar/solicitar token
if [ -z "$GITHUB_TOKEN" ]; then
    log_warning "GITHUB_TOKEN não configurado"
    echo ""
    log_info "Para configurar permanentemente:"
    echo "  export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX"
    echo "  echo 'export GITHUB_TOKEN=ghp_XXX' >> ~/.bashrc"
    echo ""
    read -sp "Digite seu GitHub Token: " GITHUB_TOKEN
    echo ""
    export GITHUB_TOKEN
fi

# Login GHCR
log_info "Login no GHCR..."
echo "$GITHUB_TOKEN" | docker login ghcr.io -u edumigsoft --password-stdin

if [ $? -ne 0 ]; then
    log_error "Falha no login GHCR"
    echo ""
    log_info "Verifique se o token tem permissões: read:packages, write:packages"
    log_info "Crie um novo token em: https://github.com/settings/tokens"
    exit 1
fi

log_success "Login realizado"
echo ""

# Pull
IMAGE="ghcr.io/edumigsoft/ems-server:latest"
log_info "Pull da imagem: $IMAGE"
docker pull "$IMAGE"

if [ $? -ne 0 ]; then
    log_error "Falha no pull da imagem"
    echo ""
    log_info "Verifique:"
    echo "  1. Imagem existe no GHCR"
    echo "  2. Token tem permissão de leitura"
    echo "  3. Conexão com internet está funcionando"
    exit 1
fi

log_success "Pull concluído"
echo ""

# Restart
log_info "Reiniciando container..."
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d

if [ $? -ne 0 ]; then
    log_error "Falha ao iniciar container"
    echo ""
    log_info "Verifique os logs com:"
    echo "  docker-compose -f docker-compose.prod.yml logs"
    exit 1
fi

log_success "Container atualizado!"
echo ""

# Aguardar container inicializar
log_info "Aguardando container inicializar..."
sleep 3

# Status
log_info "Status dos containers:"
docker-compose -f docker-compose.prod.yml ps
echo ""

# Logs
log_info "Logs (últimas 20 linhas):"
docker-compose -f docker-compose.prod.yml logs --tail=20
echo ""

log_success "Update concluído!"
echo ""
log_info "Verificar health: curl http://localhost:8181/health"
log_info "Ver logs em tempo real: docker-compose -f docker-compose.prod.yml logs -f"
