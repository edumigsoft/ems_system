#!/bin/bash

# Script para push manual de imagens Docker para GitHub Container Registry (GHCR)
# Uso: GITHUB_TOKEN=ghp_xxx ./scripts/push-to-ghcr.sh <ems|sms>

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

# Validar token GitHub
if [ -z "$GITHUB_TOKEN" ]; then
    log_error "GITHUB_TOKEN não definido"
    echo ""
    echo "Configure o token antes de executar:"
    echo "  export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX"
    echo ""
    echo "Para criar um token:"
    echo "  1. Acesse: https://github.com/settings/tokens"
    echo "  2. Scope: write:packages, read:packages"
    echo "  3. Validade: 90 dias (rotacionar regularmente)"
    exit 1
fi

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
    PUBSPEC_PATH="servers/ems/server_v1/pubspec.yaml"
    LOCAL_IMAGE="ems-server"
    REMOTE_IMAGE="ghcr.io/edumigsoft/ems-server"
elif [ "$SERVER" = "sms" ]; then
    PUBSPEC_PATH="servers/sms/server_v1/pubspec.yaml"
    LOCAL_IMAGE="sms-server"
    REMOTE_IMAGE="ghcr.io/edumigsoft/sms-server"
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

MAJOR_MINOR="v$(echo $VERSION | cut -d. -f1,2)"

log_info "Servidor: ${SERVER^^}"
log_info "Versão: $VERSION"
log_info "Imagem local: $LOCAL_IMAGE:$VERSION"
log_info "Imagem remota: $REMOTE_IMAGE"
echo ""

# Verificar se a imagem local existe
if ! docker image inspect "$LOCAL_IMAGE:$VERSION" > /dev/null 2>&1; then
    log_error "Imagem local não encontrada: $LOCAL_IMAGE:$VERSION"
    echo ""
    log_info "Execute o build primeiro:"
    echo "  ./scripts/build-local.sh $SERVER"
    exit 1
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

# Tag da imagem local para GHCR
log_info "Criando tags para push..."
docker tag "$LOCAL_IMAGE:$VERSION" "$REMOTE_IMAGE:$VERSION"
docker tag "$LOCAL_IMAGE:$VERSION" "$REMOTE_IMAGE:$MAJOR_MINOR"
docker tag "$LOCAL_IMAGE:$VERSION" "$REMOTE_IMAGE:latest"

log_success "Tags criadas:"
echo "  • $REMOTE_IMAGE:$VERSION"
echo "  • $REMOTE_IMAGE:$MAJOR_MINOR"
echo "  • $REMOTE_IMAGE:latest"
echo ""

# Push das imagens
log_info "Fazendo push das imagens para GHCR..."
echo ""

docker push "$REMOTE_IMAGE:$VERSION"
docker push "$REMOTE_IMAGE:$MAJOR_MINOR"
docker push "$REMOTE_IMAGE:latest"

echo ""
log_success "Push concluído com sucesso!"
echo ""
log_info "Imagens publicadas:"
echo "  • $REMOTE_IMAGE:$VERSION"
echo "  • $REMOTE_IMAGE:$MAJOR_MINOR"
echo "  • $REMOTE_IMAGE:latest"
echo ""
log_info "Verifique em: https://github.com/edumigsoft/ems_system/pkgs/container/$SERVER-server"
