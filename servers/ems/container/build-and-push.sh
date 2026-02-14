#!/bin/bash
set -e

# Script wrapper para build local + push para GHCR (PC local)
# Uso: ./servers/ems/container/build-and-push.sh

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

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Verificar se está no diretório raiz do projeto
if [ ! -f "VERSION" ] && [ ! -d "servers/ems/server_v1" ]; then
    log_error "Execute este script do diretório raiz do projeto"
    echo ""
    log_info "Exemplo:"
    echo "  cd /caminho/do/ems_system"
    echo "  ./servers/ems/container/build-and-push.sh"
    exit 1
fi

echo ""
log_info "=== Build Local + Push GHCR (EMS Server) ==="
echo ""

# Passo 1: Build local
log_info "Passo 1/2: Building imagem local..."
echo ""
./scripts/build-local.sh ems

if [ $? -ne 0 ]; then
    log_error "Build falhou"
    exit 1
fi

echo ""
log_success "Build concluído!"
echo ""

# Passo 2: Push para GHCR
log_info "Passo 2/2: Push para GHCR..."
echo ""

# Verificar token
if [ -z "$GITHUB_TOKEN" ]; then
    log_info "GITHUB_TOKEN não configurado"
    echo ""
    log_info "Para configurar permanentemente:"
    echo "  export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX"
    echo "  echo 'export GITHUB_TOKEN=ghp_XXX' >> ~/.bashrc"
    echo ""
    read -sp "Digite seu GitHub Token: " GITHUB_TOKEN
    echo ""
fi

# Push
GITHUB_TOKEN=$GITHUB_TOKEN ./scripts/push-to-ghcr.sh ems

if [ $? -ne 0 ]; then
    log_error "Push falhou"
    exit 1
fi

echo ""
log_success "✓ Build e Push concluídos!"
echo ""
log_info "Próximos passos:"
echo ""
echo "  1. Conectar na VPS:"
echo "     ssh user@vps"
echo ""
echo "  2. Atualizar servidor:"
echo "     cd /caminho/ems_system/servers/ems/container"
echo "     ./update.sh"
echo ""
