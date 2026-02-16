#!/bin/bash
# Script para build production + push para GitHub Container Registry
# Uso: ./publish.sh <ems|sms> [version]

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
    exit 1
fi

SERVER=$1
VERSION_ARG=$2

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
    CONTAINER_DIR="$PROJECT_ROOT/servers/ems/container"
    PUBSPEC_PATH="$PROJECT_ROOT/servers/ems/server_v1/pubspec.yaml"
    IMAGE_BASE="ghcr.io/edumigsoft/ems-server"
    SERVER_NAME="EMS Server"
elif [ "$SERVER" = "sms" ]; then
    CONTAINER_DIR="$PROJECT_ROOT/servers/sms/container"
    PUBSPEC_PATH="$PROJECT_ROOT/servers/sms/server_v1/pubspec.yaml"
    IMAGE_BASE="ghcr.io/edumigsoft/sms-server"
    SERVER_NAME="SMS Server"
fi

# Determinar versão
if [ -n "$VERSION_ARG" ]; then
    VERSION="$VERSION_ARG"
else
    # Ler do pubspec.yaml
    if [ ! -f "$PUBSPEC_PATH" ]; then
        log_error "Arquivo pubspec.yaml não encontrado: $PUBSPEC_PATH"
        exit 1
    fi

    VERSION=$(grep '^version:' "$PUBSPEC_PATH" | sed 's/version: *//' | tr -d ' ')

    if [ -z "$VERSION" ]; then
        log_error "Não foi possível ler a versão do pubspec.yaml"
        exit 1
    fi
fi

# Extrair major.minor (ex: 1.1.0 -> v1.1)
MAJOR_MINOR=$(echo "$VERSION" | cut -d. -f1-2)
MAJOR_MINOR_TAG="v${MAJOR_MINOR}"

echo ""
log_info "=== Build Production ${SERVER_NAME} ==="
log_info "Versão: $VERSION"
log_info "Environment: production"
echo ""

# Confirmação com usuário
echo -e "${YELLOW}Publicar ${SERVER_NAME} v${VERSION} para GHCR?${NC}"
echo ""
echo "Tags que serão criadas:"
echo "  • ${IMAGE_BASE}:${VERSION}"
echo "  • ${IMAGE_BASE}:${MAJOR_MINOR_TAG}"
echo "  • ${IMAGE_BASE}:latest"
echo ""
read -p "Confirmar publicação? [y/N]: " -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warning "Publicação cancelada pelo usuário"
    exit 0
fi

# Verificar GITHUB_TOKEN
if [ -z "$GITHUB_TOKEN" ]; then
    log_error "GITHUB_TOKEN não configurado"
    echo ""
    log_info "Configure o token com:"
    echo "  export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX"
    echo ""
    log_info "Crie um token em: https://github.com/settings/tokens"
    log_info "Permissões necessárias: read:packages, write:packages"
    echo ""
    exit 1
fi

# Passo 1: Build production
log_info "Passo 1/4: Building imagem (production)..."
echo ""

# Mudar para a raiz do projeto para o build
cd "$PROJECT_ROOT"

docker build \
    --build-arg VERSION=$VERSION \
    --build-arg ENVIRONMENT=production \
    -t ${SERVER}-server:$VERSION \
    -f $CONTAINER_DIR/Dockerfile \
    .

log_success "Build concluído"
echo ""

# Passo 2: Login GHCR
log_info "Passo 2/4: Login no GitHub Container Registry..."
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

# Passo 3: Criar tags
log_info "Passo 3/4: Criando tags..."

docker tag ${SERVER}-server:$VERSION ${IMAGE_BASE}:${VERSION}
docker tag ${SERVER}-server:$VERSION ${IMAGE_BASE}:${MAJOR_MINOR_TAG}
docker tag ${SERVER}-server:$VERSION ${IMAGE_BASE}:latest

log_success "Tags criadas:"
echo "  • ${IMAGE_BASE}:${VERSION}"
echo "  • ${IMAGE_BASE}:${MAJOR_MINOR_TAG}"
echo "  • ${IMAGE_BASE}:latest"
echo ""

# Passo 4: Push
log_info "Passo 4/4: Fazendo push das imagens..."
echo ""

docker push ${IMAGE_BASE}:${VERSION}
docker push ${IMAGE_BASE}:${MAJOR_MINOR_TAG}
docker push ${IMAGE_BASE}:latest

echo ""
log_success "=== Publicação concluída com sucesso! ==="
echo ""

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_success "Imagens disponíveis no GHCR:"
echo "  • ${IMAGE_BASE}:${VERSION}"
echo "  • ${IMAGE_BASE}:${MAJOR_MINOR_TAG}"
echo "  • ${IMAGE_BASE}:latest"
echo ""
log_info "Verificar em: https://github.com/edumigsoft/ems_system/pkgs/container/${SERVER}-server"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_info "Deploy na VPS:"
echo "  ssh user@vps"
echo "  cd /path/servers/${SERVER}/container"
echo "  ./update.sh"
echo ""
