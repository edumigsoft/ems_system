#!/bin/bash
# Script para executar pub get em todos os pacotes
# Agnóstico - descobre pacotes automaticamente

set -e

echo "🔧 Executando dart pub get em todos os pacotes..."

# Busca todos os diretórios com pubspec.yaml
PACKAGES=$(find ../packages ../apps ../servers -name "pubspec.yaml" -type f -exec dirname {} \; 2>/dev/null | sort)

for pkg in $PACKAGES; do
  echo "📦 Processing $pkg..."
  (cd "$pkg" && dart pub get > /dev/null 2>&1) && echo "   ✅ Done" || echo "   ❌ Failed"
done

echo ""
echo "✅ Pub get concluído em todos os pacotes!"
