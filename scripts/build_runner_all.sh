#!/bin/bash
# Script para executar build_runner em todos os pacotes que o possuem
# Agnóstico - descobre pacotes automaticamente

set -e

echo "🔨 Executando build_runner em todos os pacotes..."

# Busca todos os diretórios com pubspec.yaml
PACKAGES=$(find ../packages ../apps ../servers -name "pubspec.yaml" -type f -exec dirname {} \; 2>/dev/null | sort)

for pkg in $PACKAGES; do
  if grep -q "build_runner" "$pkg/pubspec.yaml" 2>/dev/null; then
    echo "🏗️  Building $pkg..."
    # Verifica se é um projeto flutter ou dart puro
    if grep -q "sdk: flutter" "$pkg/pubspec.yaml" || grep -q "flutter:" "$pkg/pubspec.yaml"; then
      (cd "$pkg" && flutter pub run build_runner build --delete-conflicting-outputs > /dev/null 2>&1) && echo "   ✅ Flutter Build Done" || echo "   ❌ Flutter Build Failed"
    else
      (cd "$pkg" && dart run build_runner build --delete-conflicting-outputs > /dev/null 2>&1) && echo "   ✅ Dart Build Done" || echo "   ❌ Dart Build Failed"
    fi
  fi
done

echo ""
echo "🚀 Build concluído em todos os pacotes!"
