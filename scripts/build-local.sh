#!/bin/bash

# Script para build local de imagens Docker dos servidores EMS e SMS
# Uso: ./scripts/build-local.sh <ems|sms>

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Função para exibir mensagens
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
if [ $# -ne 1 ]; then
    log_error "Uso: $0 <ems|sms>"
    exit 1
fi

SERVER=$1

# Validar servidor
if [[ ! "$SERVER" =~ ^(ems|sms)$ ]]; then
    log_error "Servidor inválido: $SERVER. Use 'ems' ou 'sms'"
    exit 1
fi

# Configurações específicas por servidor
if [ "$SERVER" = "ems" ]; then
    SERVER_DIR="servers/ems"
    CONTAINER_DIR="servers/ems/container"
    PUBSPEC_PATH="servers/ems/server_v1/pubspec.yaml"
    IMAGE_NAME="ems-server"
elif [ "$SERVER" = "sms" ]; then
    SERVER_DIR="servers/sms"
    CONTAINER_DIR="servers/sms/container"
    PUBSPEC_PATH="servers/sms/server_v1/pubspec.yaml"
    IMAGE_NAME="sms-server"
fi

# Ler versão do pubspec.yaml
if [ ! -f "$PUBSPEC_PATH" ]; then
    log_error "Arquivo pubspec.yaml não encontrado: $PUBSPEC_PATH"
    exit 1
fi

VERSION=$(grep '^version:' "$PUBSPEC_PATH" | sed 's/version: *//' | tr -d ' ')

if [ -z "$VERSION" ]; then
    log_error "Não foi possível ler a versão do pubspec.yaml"
    exit 1
fi

log_info "Servidor: ${SERVER^^}"
log_info "Versão: $VERSION"
log_info "Imagem: $IMAGE_NAME:$VERSION"
echo ""

# Build da imagem
log_info "Iniciando build da imagem Docker..."
echo ""

docker build \
    -f "$CONTAINER_DIR/Dockerfile" \
    -t "$IMAGE_NAME:$VERSION" \
    -t "$IMAGE_NAME:latest" \
    .

echo ""
log_success "Build concluído com sucesso!"
log_success "Tags criadas:"
echo "  • $IMAGE_NAME:$VERSION"
echo "  • $IMAGE_NAME:latest"
echo ""
log_info "Para executar localmente:"
echo "  cd $CONTAINER_DIR && docker-compose up -d"
echo ""
log_info "Para fazer push para GHCR:"
echo "  ./scripts/push-to-ghcr.sh $SERVER"
