#!/bin/bash
# Script para scaffold de nova feature (Suporte a Sub-features, Pubspec e CLI flags)
# Uso interativo: ./scripts/scaffold_feature.sh
# Uso com flags: ./scripts/scaffold_feature.sh --name book --title "Book Management" --entity Book --packages shared,client,server,ui --no-prompt

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variáveis padrão
NO_PROMPT=false
FEATURE_PATH=""
FEATURE_TITLE=""
ENTITY_NAME=""
PACKAGES=""
DESCRIPTION="Auto-generated feature"

# Parse argumentos de linha de comando
while [[ $# -gt 0 ]]; do
  case $1 in
    --name)
      FEATURE_PATH="$2"
      shift 2
      ;;
    --title)
      FEATURE_TITLE="$2"
      shift 2
      ;;
    --entity)
      ENTITY_NAME="$2"
      shift 2
      ;;
    --packages)
      PACKAGES="$2"
      shift 2
      ;;
    --description)
      DESCRIPTION="$2"
      shift 2
      ;;
    --no-prompt)
      NO_PROMPT=true
      shift
      ;;
    *)
      echo "Argumento desconhecido: $1"
      exit 1
      ;;
  esac
done

# Função para solicitar input (somente se não estiver em modo no-prompt)
ask() {
  local prompt="$1"
  local var_name="$2"
  local default="${3:-}"
  
  if [ "$NO_PROMPT" = true ]; then
    return
  fi
  
  if [ -n "$default" ]; then
    read -p "$prompt [$default]: " value
    value="${value:-$default}"
  else
    read -p "$prompt: " value
  fi
  eval "$var_name='$value'"
}

echo "🚀 Scaffold de Nova Feature"
echo ""

# Solicitar informações (se modo interativo)
if [ "$NO_PROMPT" = false ]; then
  ask "Nome da feature (ex: library ou finance/invoice)" FEATURE_PATH
  ask "Título da feature (ex: Library Management)" FEATURE_TITLE
  ask "Entidade principal (ex: Book)" ENTITY_NAME
  ask "Pacotes a criar (shared,client,server,ui)" PACKAGES "shared,client,server,ui"
  ask "Descrição breve" DESCRIPTION
fi

# Validar que temos todas as informações necessárias
if [ -z "$FEATURE_PATH" ] || [ -z "$FEATURE_TITLE" ] || [ -z "$ENTITY_NAME" ] || [ -z "$PACKAGES" ]; then
  echo "Erro: Parâmetros obrigatórios faltando"
  echo "Uso: $0 --name <feature> --title <title> --entity <entity> --packages <packages> [--no-prompt]"
  exit 1
fi

# Extrair o nome base da feature (última parte do path)
FEATURE_NAME=$(basename "$FEATURE_PATH")
TOP_FEATURE_PATH=$(echo "$FEATURE_PATH" | cut -d'/' -f1)

# Calcular profundidade para caminhos relativos
# packages/feature (depth 0) -> root is ../../../ (pkg), ../../ (feature)
# packages/parent/sub (depth 1) -> root is ../../../../ (pkg), ../../../ (feature)
DEPTH=$(echo "$FEATURE_PATH" | tr -cd '/' | wc -c)

# REL_PATH para o nível da FEATURE (README.md, CONTRIBUTING.md)
REL_PATH_FEATURE="../../"
for ((i=0; i<$DEPTH; i++)); do
  REL_PATH_FEATURE="../$REL_PATH_FEATURE"
done

# REL_PATH para o nível do PACOTE (lib, pubspec, etc)
REL_PATH_PKG="../../../$REL_PATH_FEATURE"

# Função para substituir placeholders
replace_placeholders() {
  local file="$1"
  local rel_path="$2"
  sed -i "s/{{FEATURE_NAME}}/$FEATURE_NAME/g" "$file"
  sed -i "s/{{FEATURE_TITLE}}/$FEATURE_TITLE/g" "$file"
  sed -i "s/{{ENTITY_NAME}}/$ENTITY_NAME/g" "$file"
  sed -i "s/{{DESCRIPTION}}/$DESCRIPTION/g" "$file"
  sed -i "s|{{REL_PATH}}|$rel_path|g" "$file"
}

# Criar branch (somente se não estiver em modo no-prompt ou se git está disponível)
if [ "$NO_PROMPT" = false ]; then
  echo ""
  echo -e "${YELLOW}Criando branch feature/$FEATURE_NAME...${NC}"
  git checkout -b "feature/$FEATURE_NAME" 2>/dev/null || git checkout "feature/$FEATURE_NAME" || true
fi

# Criar diretórios
FEATURE_DIR="packages/$FEATURE_PATH"
TOP_FEATURE_DIR="packages/$TOP_FEATURE_PATH"

mkdir -p "$FEATURE_DIR"

# Garantir arquivos no nível pai se for uma sub-feature ou feature nova
if [ ! -f "$TOP_FEATURE_DIR/CONTRIBUTING.md" ]; then
  echo -e "${GREEN}Criando estrutura base em $TOP_FEATURE_DIR...${NC}"
  cp generators/templates/feature/README.md "$TOP_FEATURE_DIR/"
  cp generators/templates/feature/CONTRIBUTING.md "$TOP_FEATURE_DIR/"
  cp generators/templates/feature/CHANGELOG.md "$TOP_FEATURE_DIR/"
  replace_placeholders "$TOP_FEATURE_DIR/README.md" "$REL_PATH_FEATURE"
  replace_placeholders "$TOP_FEATURE_DIR/CONTRIBUTING.md" "$REL_PATH_FEATURE"
  replace_placeholders "$TOP_FEATURE_DIR/CHANGELOG.md" "$REL_PATH_FEATURE"
fi

# Se for uma sub-feature, criar o README dela também
if [ "$FEATURE_PATH" != "$TOP_FEATURE_PATH" ]; then
  cp generators/templates/feature/README.md "$FEATURE_DIR/"
  replace_placeholders "$FEATURE_DIR/README.md" "$REL_PATH_FEATURE"
fi

# Copiar templates de pacotes selecionados
IFS=',' read -ra PKG_ARRAY <<< "$PACKAGES"
for pkg in "${PKG_ARRAY[@]}"; do
  PKG_DIR="$FEATURE_DIR/${FEATURE_NAME}_$pkg"
  echo -e "${GREEN}Criando pacote $pkg em $PKG_DIR...${NC}"
  
  mkdir -p "$PKG_DIR/lib/src"
  mkdir -p "$PKG_DIR/test"
  
  # Copiar templates base
  cp "generators/templates/$pkg/README.md" "$PKG_DIR/"
  cp "generators/templates/$pkg/CHANGELOG.md" "$PKG_DIR/"
  
  # Gerar Pubspec
  if [ -f "generators/templates/$pkg/pubspec.yaml.template" ]; then
    cp "generators/templates/$pkg/pubspec.yaml.template" "$PKG_DIR/pubspec.yaml"
    replace_placeholders "$PKG_DIR/pubspec.yaml" "$REL_PATH_PKG"
  fi
  
  # Gerar Analysis Options
  cp "generators/templates/$pkg/analysis_options.yaml.template" "$PKG_DIR/analysis_options.yaml"
  replace_placeholders "$PKG_DIR/analysis_options.yaml" "$REL_PATH_PKG"
  
  # Substituir placeholders nos arquivos restantes
  replace_placeholders "$PKG_DIR/README.md" "$REL_PATH_PKG"
  replace_placeholders "$PKG_DIR/CHANGELOG.md" "$REL_PATH_PKG"
done

echo ""
echo -e "${GREEN}✅ Feature $FEATURE_NAME criada com sucesso em $FEATURE_DIR!${NC}"
echo ""

if [ "$NO_PROMPT" = false ]; then
  echo "Próximos passos:"
  echo "1. Execute: ./scripts/pub_get_all.sh"
  echo "2. Use o wizard ou scripts de geração para criar o código"
  echo "3. Execute: ./scripts/dart_fix_all.sh"
  echo "4. Commit e push"
  echo ""
  
  # Perguntar sobre commit inicial
  read -p "Fazer commit inicial? (y/n): " commit
  if [ "$commit" = "y" ]; then
    git add "packages/$TOP_FEATURE_PATH"
    git commit -m "feat: scaffold $FEATURE_NAME structure"
    echo -e "${GREEN}✅ Commit realizado!${NC}"
  fi
fi
