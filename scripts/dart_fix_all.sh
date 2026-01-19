#!/bin/bash
# Script para aplicar dart fix --apply em todos os pacotes
# Agnóstico - descobre pacotes automaticamente

set -e

echo "🔧 Aplicando dart fix em todos os pacotes..."

# Busca todos os diretórios com pubspec.yaml
PACKAGES=$(find packages apps servers -name "pubspec.yaml" -type f -exec dirname {} \; 2>/dev/null | sort)

echo "📦 Packages: $PACKAGES..."

for pkg in $PACKAGES; do
  echo "🔧 Fixing $pkg..."
  (cd "$pkg" && dart fix --apply > /dev/null 2>&1) && echo "   ✅ Done" || echo "   ⚠️  No fixes or failed"
done

echo ""
echo "✅ Dart fix aplicado em todos os pacotes!"
