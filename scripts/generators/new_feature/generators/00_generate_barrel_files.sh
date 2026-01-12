#!/bin/bash

# ============================================================================
# 00_generate_barrel_files.sh - Gera ou atualiza barrel files do pacote
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=============================================="
echo "  Gerador de Barrel Files"
echo "=============================================="
echo ""


ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Tipo de pacote (shared/client)" PACKAGE_TYPE
if [[ "$PACKAGE_TYPE" != "shared" && "$PACKAGE_TYPE" != "client" ]]; then
  error "Tipo de pacote inválido. Use 'shared' ou 'client'."
  exit 1
fi

FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ROOT=$(get_project_root)

if [ "$PACKAGE_TYPE" = "shared" ]; then
  PACKAGE_PATH=$(get_shared_package_path "$FEATURE_SNAKE")
  validate_package_exists "$FEATURE_SNAKE" "shared" || exit 1
  
  BARREL_INTERNAL="$PACKAGE_PATH/lib/src/${FEATURE_SNAKE}_shared.dart"
  BARREL_EXTERNAL="$PACKAGE_PATH/lib/${FEATURE_SNAKE}_shared.dart"
  
  progress "Gerando barrel files para ${FEATURE_SNAKE}_shared..."
  
  # Gera barrel file interno (src/)
  cat > "$BARREL_INTERNAL" <<'EOF_SCRIPT'
# Este arquivo é gerado automaticamente. Edite com cuidado.
# Para adicionar novos exports, adicione-os manualmente ou regenere com o script.

# Entities
EOF_SCRIPT
  
  # Adiciona exports de entities
  if [ -d "$PACKAGE_PATH/lib/src/domain/entities" ]; then
    find "$PACKAGE_PATH/lib/src/domain/entities" -name "*.dart" -type f | while read -r file; do
      relative_path=$(realpath --relative-to="$PACKAGE_PATH/lib/src" "$file")
      echo "export '$relative_path';" >> "$BARREL_INTERNAL"
    done
  fi
  
  echo "" >> "$BARREL_INTERNAL"
  echo "# Repositories" >> "$BARREL_INTERNAL"
  
  # Adiciona exports de repositories
  if [ -d "$PACKAGE_PATH/lib/src/domain/repositories" ]; then
    find "$PACKAGE_PATH/lib/src/domain/repositories" -name "*.dart" -type f | while read -r file; do
      relative_path=$(realpath --relative-to="$PACKAGE_PATH/lib/src" "$file")
      echo "export '$relative_path';" >> "$BARREL_INTERNAL"
    done
  fi
  
  echo "" >> "$BARREL_INTERNAL"
  echo "# Use Cases" >> "$BARREL_INTERNAL"
  
  # Adiciona exports de use cases
  if [ -d "$PACKAGE_PATH/lib/src/domain/use_cases" ]; then
    find "$PACKAGE_PATH/lib/src/domain/use_cases" -name "*.dart" -type f | while read -r file; do
      relative_path=$(realpath --relative-to="$PACKAGE_PATH/lib/src" "$file")
      echo "export '$relative_path';" >> "$BARREL_INTERNAL"
    done
  fi
  
  echo "" >> "$BARREL_INTERNAL"
  echo "# DTOs" >> "$BARREL_INTERNAL"
  
  # Adiciona exports de DTOs
  if [ -d "$PACKAGE_PATH/lib/src/domain/dtos" ]; then
    find "$PACKAGE_PATH/lib/src/domain/dtos" -name "*.dart" -type f | while read -r file; do
      relative_path=$(realpath --relative-to="$PACKAGE_PATH/lib/src" "$file")
      echo "export '$relative_path';" >> "$BARREL_INTERNAL"
    done
  fi
  
  echo "" >> "$BARREL_INTERNAL"
  echo "# Models" >> "$BARREL_INTERNAL"
  
  # Adiciona exports de models
  if [ -d "$PACKAGE_PATH/lib/src/data/models" ]; then
    find "$PACKAGE_PATH/lib/src/data/models" -name "*.dart" -type f | while read -r file; do
      relative_path=$(realpath --relative-to="$PACKAGE_PATH/lib/src" "$file")
      echo "export '$relative_path';" >> "$BARREL_INTERNAL"
    done
  fi
  
  echo "" >> "$BARREL_INTERNAL"
  echo "# Converters" >> "$BARREL_INTERNAL"
  
  # Adiciona exports de converters
  if [ -d "$PACKAGE_PATH/lib/src/data/converters" ]; then
    find "$PACKAGE_PATH/lib/src/data/converters" -name "*.dart" -type f | while read -r file; do
      relative_path=$(realpath --relative-to="$PACKAGE_PATH/lib/src" "$file")
      echo "export '$relative_path';" >> "$BARREL_INTERNAL"
    done
  fi
  
  echo "" >> "$BARREL_INTERNAL"
  echo "# Validators" >> "$BARREL_INTERNAL"
  
  # Adiciona exports de validators
  if [ -d "$PACKAGE_PATH/lib/src/validators" ]; then
    find "$PACKAGE_PATH/lib/src/validators" -name "*.dart" -type f | while read -r file; do
      relative_path=$(realpath --relative-to="$PACKAGE_PATH/lib/src" "$file")
      echo "export '$relative_path';" >> "$BARREL_INTERNAL"
    done
  fi
  
  echo "" >> "$BARREL_INTERNAL"
  echo "# Constants" >> "$BARREL_INTERNAL"
  
  # Adiciona exports de constants
  if [ -d "$PACKAGE_PATH/lib/src/constants" ]; then
    find "$PACKAGE_PATH/lib/src/constants" -name "*.dart" -type f | while read -r file; do
      relative_path=$(realpath --relative-to="$PACKAGE_PATH/lib/src" "$file")
      echo "export '$relative_path';" >> "$BARREL_INTERNAL"
    done
  fi
  
  # Gera barrel file externo (lib/)
  cat > "$BARREL_EXTERNAL" <<EOF
export 'src/${FEATURE_SNAKE}_shared.dart';
EOF

else # client
  PACKAGE_PATH=$(get_client_package_path "$FEATURE_SNAKE")
  validate_package_exists "$FEATURE_SNAKE" "client" || exit 1
  
  BARREL_INTERNAL="$PACKAGE_PATH/lib/src/${FEATURE_SNAKE}_client.dart"
  BARREL_EXTERNAL="$PACKAGE_PATH/lib/${FEATURE_SNAKE}_client.dart"
  
  progress "Gerando barrel files para ${FEATURE_SNAKE}_client..."
  
  # Gera barrel file interno (src/)
  cat > "$BARREL_INTERNAL" <<'EOF_SCRIPT'
# Este arquivo é gerado automaticamente. Edite com cuidado.
# Para adicionar novos exports, adicione-os manualmente ou regenere com o script.

# Services
EOF_SCRIPT
  
  # Adiciona exports de services
  if [ -d "$PACKAGE_PATH/lib/src/services" ]; then
    find "$PACKAGE_PATH/lib/src/services" -name "*.dart" -type f | while read -r file; do
      relative_path=$(realpath --relative-to="$PACKAGE_PATH/lib/src" "$file")
      echo "export '$relative_path';" >> "$BARREL_INTERNAL"
    done
  fi
  
  echo "" >> "$BARREL_INTERNAL"
  echo "# Repositories" >> "$BARREL_INTERNAL"
  
  # Adiciona exports de repositories
  if [ -d "$PACKAGE_PATH/lib/src/repositories" ]; then
    find "$PACKAGE_PATH/lib/src/repositories" -name "*.dart" -type f | while read -r file; do
      relative_path=$(realpath --relative-to="$PACKAGE_PATH/lib/src" "$file")
      echo "export '$relative_path';" >> "$BARREL_INTERNAL"
    done
  fi
  
  # Gera barrel file externo (lib/)
  cat > "$BARREL_EXTERNAL" <<EOF
export 'src/${FEATURE_SNAKE}_client.dart';
EOF

fi

success "Barrel files gerados!"
info "Arquivos criados:"
info "  - $BARREL_INTERNAL"
info "  - $BARREL_EXTERNAL"

# Executa pub get
run_pub_get "$FEATURE_SNAKE"
