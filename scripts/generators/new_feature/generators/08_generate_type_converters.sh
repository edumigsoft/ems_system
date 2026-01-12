#!/bin/bash

# ============================================================================
# 08_generate_type_converters.sh - Gera TypeConverters para enums NO _server
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=============================================="
echo "  Gerador de TypeConverters (Enums)"
echo "=============================================="
echo ""

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome do Enum (PascalCase)" ENUM_NAME
validate_class_name "$ENUM_NAME" || exit 1

FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENUM_SNAKE=$(to_snake_case "$ENUM_NAME")
ROOT=$(get_project_root)
SERVER_PATH=$(get_server_package_path "$FEATURE_SNAKE")
CONVERTER_FILE="$SERVER_PATH/lib/src/database/converters/${ENUM_SNAKE}_converter.dart"

validate_package_exists "$FEATURE_SNAKE" "server" || exit 1
ensure_dir "$(dirname "$CONVERTER_FILE")")

progress "Gerando ${ENUM_NAME}Converter..."

cat > "$CONVERTER_FILE" <<EOF
import 'package:drift/drift.dart';
import 'package:${FEATURE_SNAKE}_shared/${FEATURE_SNAKE}_shared.dart' show $ENUM_NAME;

/// TypeConverter para $ENUM_NAME.
///
/// - Armazena como int (index do enum)
/// - Validação de range
/// - Valor padrão em caso de index inválido
class ${ENUM_NAME}Converter extends TypeConverter<$ENUM_NAME, int> {
  const ${ENUM_NAME}Converter();
  
  @override
  $ENUM_NAME fromSql(int fromDb) {
    if (fromDb < 0 || fromDb >= $ENUM_NAME.values.length) {
      // Retorna primeiro valor como padrão
      return $ENUM_NAME.values.first;
    }
    return $ENUM_NAME.values[fromDb];
  }
  
  @override
  int toSql($ENUM_NAME value) => value.index;
}
EOF

success "TypeConverter gerada!"
info "Arquivo: $CONVERTER_FILE"
echo ""
warn "Lembre-se:"
info "  1. Usar na Table: @JsonKey(converter: ${ENUM_NAME}Converter())"
info "  2. Configurar no AppDatabase"
