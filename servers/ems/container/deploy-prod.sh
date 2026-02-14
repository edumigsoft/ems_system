#!/bin/bash

# Script de deploy automatizado para EMS Server em produção
# Uso: ./deploy-prod.sh

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
    log_info "Execute este script no diretório servers/ems/container/"
    exit 1
fi

# Verificar se .env existe
if [ ! -f ".env" ]; then
    log_error "Arquivo .env não encontrado!"
    log_info "Crie o arquivo .env a partir do .env.example:"
    echo "  cp .env.example .env"
    echo "  nano .env  # Configure as variáveis"
    exit 1
fi

echo ""
log_info "=== Deploy EMS Server - Produção ==="
echo ""

# Solicitar seleção de versão
log_info "Selecione a versão da imagem:"
echo "  1) latest (padrão)"
echo "  2) Versão específica (ex: 1.1.0)"
echo "  3) Custom tag"
echo ""
read -p "Opção [1]: " VERSION_OPTION
VERSION_OPTION=${VERSION_OPTION:-1}

case $VERSION_OPTION in
    1)
        IMAGE_TAG="latest"
        ;;
    2)
        read -p "Digite a versão (ex: 1.1.0): " VERSION
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

IMAGE="ghcr.io/edumigsoft/ems-server:$IMAGE_TAG"

log_info "Imagem selecionada: $IMAGE"
echo ""

# Verificar token GitHub
if [ -z "$GITHUB_TOKEN" ]; then
    log_warning "GITHUB_TOKEN não configurado"
    read -sp "Digite seu GitHub Personal Access Token: " GITHUB_TOKEN
    echo ""
    export GITHUB_TOKEN
fi

# Login no GHCR
log_info "Fazendo login no GitHub Container Registry..."
echo "$GITHUB_TOKEN" | docker login ghcr.io -u edumigsoft --password-stdin

if [ $? -ne 0 ]; then
    log_error "Falha no login do GHCR"
    exit 1
fi

log_success "Login realizado com sucesso"
echo ""

# Pull da imagem
log_info "Fazendo pull da imagem: $IMAGE"
docker pull "$IMAGE"

if [ $? -ne 0 ]; then
    log_error "Falha ao fazer pull da imagem"
    exit 1
fi

log_success "Pull concluído"
echo ""

# Atualizar docker-compose.prod.yml com a tag selecionada
log_info "Atualizando docker-compose.prod.yml..."
sed -i.bak "s|image:.*|image: $IMAGE|" docker-compose.prod.yml
rm -f docker-compose.prod.yml.bak

# Parar containers antigos
log_info "Parando containers antigos..."
docker-compose -f docker-compose.prod.yml down

# Iniciar novo container
log_info "Iniciando novo container..."
docker-compose -f docker-compose.prod.yml up -d

if [ $? -ne 0 ]; then
    log_error "Falha ao iniciar container"
    exit 1
fi

log_success "Container iniciado com sucesso!"
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

log_success "Deploy concluído!"
echo ""
log_info "Para verificar os logs em tempo real:"
echo "  docker-compose -f docker-compose.prod.yml logs -f"
echo ""
log_info "Para verificar o status:"
echo "  docker ps | grep ems_server_prod"
echo ""
log_info "Para testar o healthcheck:"
echo "  curl http://localhost:8181/health"
