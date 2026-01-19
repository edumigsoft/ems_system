#!/bin/bash
# Script para limpar todos os pacotes (remover .dart_tool e outros artefatos)
# Agnóstico - descobre pacotes automaticamente

set -e

echo "🧹 Limpando todos os pacotes..."

# Busca todos os diretórios com pubspec.yaml
PACKAGES=$(find packages apps servers -name "pubspec.yaml" -type f -exec dirname {} \; 2>/dev/null | sort)

echo "📦 Packages: $PACKAGES..."

for pkg in $PACKAGES; do
  echo "🧼 Cleaning $pkg..."
  if [ -f "$pkg/pubspec.yaml" ]; then
    # Se for um projeto flutter, usa flutter clean, senão apenas remove .dart_tool
    if grep -q "sdk: flutter" "$pkg/pubspec.yaml" || grep -q "flutter:" "$pkg/pubspec.yaml"; then
      (cd "$pkg" && flutter clean > /dev/null 2>&1) && echo "   ✅ Flutter Clean Done" || echo "   ❌ Flutter Clean Failed"
    else
      (cd "$pkg" && rm -rf .dart_tool build .pub-cache .packages pubspec.lock > /dev/null 2>&1) && echo "   ✅ Dart Clean Done" || echo "   ❌ Dart Clean Failed"
    fi
  fi
done

echo ""
echo "✨ Limpeza concluída em todos os pacotes!"
