#!/bin/bash

# Script de rollback para SMS Server
# Uso: ./rollback.sh

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# Verificar se está no diretório correto
if [ ! -f "docker-compose.prod.yml" ]; then
    log_error "docker-compose.prod.yml não encontrado!"
    log_info "Execute este script no diretório servers/sms/container/"
    exit 1
fi

echo ""
log_info "=== Rollback SMS Server ==="
echo ""

# Verificar token GitHub
if [ -z "$GITHUB_TOKEN" ]; then
    log_warning "GITHUB_TOKEN não configurado"
    read -sp "Digite seu GitHub Personal Access Token: " GITHUB_TOKEN
    echo ""
    export GITHUB_TOKEN
fi

# Listar versões disponíveis (requer gh CLI ou API)
log_info "Versões disponíveis no GHCR:"
echo ""
echo "Opções comuns:"
echo "  1) latest"
echo "  2) Versão anterior (será solicitada)"
echo "  3) Custom tag"
echo ""

read -p "Opção [2]: " VERSION_OPTION
VERSION_OPTION=${VERSION_OPTION:-2}

case $VERSION_OPTION in
    1)
        IMAGE_TAG="latest"
        log_warning "Rollback para 'latest' pode não ser a versão anterior!"
        ;;
    2)
        read -p "Digite a versão para rollback (ex: 1.0.0): " VERSION
        IMAGE_TAG="$VERSION"
        ;;
    3)
        read -p "Digite a tag custom: " CUSTOM_TAG
        IMAGE_TAG="$CUSTOM_TAG"
        ;;
    *)
        log_error "Opção inválida"
        exit 1
        ;;
esac

IMAGE="ghcr.io/edumigsoft/sms-server:$IMAGE_TAG"

log_info "Fazendo rollback para: $IMAGE"
echo ""

read -p "Confirmar rollback? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    log_warning "Rollback cancelado"
    exit 0
fi

# Login no GHCR
log_info "Fazendo login no GitHub Container Registry..."
echo "$GITHUB_TOKEN" | docker login ghcr.io -u edumigsoft --password-stdin

if [ $? -ne 0 ]; then
    log_error "Falha no login do GHCR"
    exit 1
fi

log_success "Login realizado"
echo ""

# Pull da imagem
log_info "Fazendo pull da versão anterior: $IMAGE"
docker pull "$IMAGE"

if [ $? -ne 0 ]; then
    log_error "Falha ao fazer pull da imagem"
    log_info "Verifique se a versão existe no GHCR"
    exit 1
fi

log_success "Pull concluído"
echo ""

# Atualizar docker-compose.prod.yml
log_info "Atualizando docker-compose.prod.yml..."
sed -i.bak "s|image:.*|image: $IMAGE|" docker-compose.prod.yml
rm -f docker-compose.prod.yml.bak

# Parar container atual
log_info "Parando container atual..."
docker-compose -f docker-compose.prod.yml down

# Iniciar com versão anterior
log_info "Iniciando container com versão anterior..."
docker-compose -f docker-compose.prod.yml up -d

if [ $? -ne 0 ]; then
    log_error "Falha ao iniciar container"
    exit 1
fi

log_success "Rollback concluído!"
echo ""

# Aguardar alguns segundos
sleep 3

# Exibir status
log_info "Status do container:"
docker-compose -f docker-compose.prod.yml ps
echo ""

# Exibir logs
log_info "Últimas linhas do log:"
docker-compose -f docker-compose.prod.yml logs --tail=20
echo ""

log_success "Container rodando com versão: $IMAGE_TAG"
echo ""
log_info "Para verificar os logs:"
echo "  docker-compose -f docker-compose.prod.yml logs -f"
