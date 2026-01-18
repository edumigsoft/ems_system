#!/bin/bash
# Script para executar build_runner em todos os pacotes que o possuem
# Agnóstico - descobre pacotes automaticamente
# Uso: ./build_runner_all.sh [build|clean|rebuild]
#   build (padrão): Executa build_runner build em todos os pacotes
#   clean: Remove todos os arquivos gerados (.g.dart, .freezed.dart, .mocks.dart, .reflectable.dart)
#   rebuild: Limpa e reconstrói todos os arquivos gerados

set -e

ACTION="${1:-rebuild}"

# Busca todos os diretórios com pubspec.yaml
PACKAGES=$(find packages apps servers -name "pubspec.yaml" -type f -exec dirname {} \; 2>/dev/null | sort)

echo "📦 Packages: $PACKAGES..."

# Função para limpar arquivos gerados
clean_generated_files() {
  echo "🧹 Limpando arquivos gerados em todos os pacotes..."
  
  for pkg in $PACKAGES; do
    if grep -q "build_runner" "$pkg/pubspec.yaml" 2>/dev/null; then
      echo "🗑️  Cleaning $pkg..."
      # Remove arquivos gerados
      find "$pkg" -type f \( -name "*.g.dart" -o -name "*.freezed.dart" -o -name "*.mocks.dart" -o -name "*.reflectable.dart" \) -delete 2>/dev/null
      echo "   ✅ Cleaned"
    fi
  done
  
  echo ""
  echo "🧹 Limpeza concluída em todos os pacotes!"
}

# Função para build
build_packages() {
  echo "🔨 Executando build_runner em todos os pacotes..."
  
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
}

# Executa a ação apropriada
case "$ACTION" in
  clean)
    clean_generated_files
    ;;
  build)
    build_packages
    ;;
  rebuild)
    clean_generated_files
    echo ""
    build_packages
    ;;
  *)
    echo "❌ Ação desconhecida: $ACTION"
    echo "Uso: $0 [build|clean|rebuild]"
    exit 1
    ;;
esac
