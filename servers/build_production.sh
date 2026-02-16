#!/bin/bash

# Script para build de imagens de produção
# Uso: ./build_production.sh [ems|sms|all] [version]

set -e

SERVICE=${1:-all}
VERSION=${2:-$(cat ../VERSION 2>/dev/null || echo "dev")}
ENVIRONMENT="production"

echo "🏗️  Building production images..."
echo "📦 Version: $VERSION"
echo "🌍 Environment: $ENVIRONMENT"
echo ""

build_service() {
    local service=$1
    local service_upper=$(echo "$service" | tr '[:lower:]' '[:upper:]')

    echo "🔨 Building ${service_upper} Server..."

    docker build \
        --build-arg VERSION="$VERSION" \
        --build-arg ENVIRONMENT="$ENVIRONMENT" \
        -t "${service}-server:${VERSION}" \
        -t "${service}-server:latest" \
        -f "${service}/container/Dockerfile" \
        ..

    echo "✅ ${service_upper} Server built successfully!"
    echo ""
}

case $SERVICE in
    ems)
        build_service "ems"
        ;;
    sms)
        build_service "sms"
        ;;
    all)
        build_service "ems"
        build_service "sms"
        ;;
    *)
        echo "❌ Unknown service: $SERVICE"
        echo "Usage: $0 [ems|sms|all] [version]"
        exit 1
        ;;
esac

echo "🎉 Build completed!"
echo ""
echo "📝 Next steps:"
echo "  1. Test locally: docker run -p 8080:8080 ${SERVICE}-server:${VERSION}"
echo "  2. Tag for registry: docker tag ${SERVICE}-server:${VERSION} ghcr.io/YOUR_ORG/${SERVICE}-server:${VERSION}"
echo "  3. Push to registry: docker push ghcr.io/YOUR_ORG/${SERVICE}-server:${VERSION}"
