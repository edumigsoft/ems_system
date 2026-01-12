#!/bin/bash

# ============================================================================
# 07_generate_tables.sh - Gera Drift Tables
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=============================================="
echo "  Gerador de Drift Tables"
echo "=============================================="
echo ""

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome da entidade (PascalCase)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

ask "Campos (mesmo da Entity)" FIELDS
validate_fields "$FIELDS" || exit 1

FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENTITY_SNAKE=$(to_snake_case "$ENTITY_NAME")
ROOT=$(get_project_root)
SERVER_PATH=$(get_server_package_path "$FEATURE_SNAKE")
TABLE_FILE="$SERVER_PATH/lib/src/database/tables/${ENTITY_SNAKE}_table.dart"

validate_package_exists "$FEATURE_SNAKE" "server" || exit 1
ensure_dir "$(dirname "$TABLE_FILE")"

progress "Gerando ${ENTITY_NAME}Table..."

# Gera colunas
IFS=',' read -ra FIELD_ARRAY <<< "$FIELDS"
COLUMNS=""
for field in "${FIELD_ARRAY[@]}"; do
  field=$(echo "$field" | xargs)
  field_name=$(get_field_name "$field")
  field_type=$(get_field_type "$field")
  
  case "$field_type" in
    String)
      COLUMNS+="  TextColumn get $field_name => text()();\n"
      ;;
    int)
      COLUMNS+="  IntColumn get $field_name => integer()();\n"
      ;;
    double)
      COLUMNS+="  RealColumn get $field_name => real()();\n"
      ;;
    bool)
      COLUMNS+="  BoolColumn get $field_name => boolean()();\n"
      ;;
    DateTime)
      COLUMNS+="  DateTimeColumn get $field_name => dateTime()();\n"
      ;;
    *)
      COLUMNS+="  TextColumn get $field_name => text()();  // Custom type: $field_type\n"
      ;;
  esac
done

cat > "$TABLE_FILE" <<EOF
import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart' show DriftTableMixinPostgres;
import 'package:${FEATURE_SNAKE}_core/${FEATURE_SNAKE}_core.dart' show ${ENTITY_NAME}Details;

/// Tabela Drift para $ENTITY_NAME.
@UseRowClass(${ENTITY_NAME}Details)
class ${ENTITY_NAME}Table extends Table with DriftTableMixinPostgres {
  @override
  String get tableName => '${ENTITY_SNAKE}s';
  
$(echo -e "$COLUMNS")}
EOF

success "Table gerada!"
info "Arquivo: $TABLE_FILE"
echo ""
info "Próximo: Executar build_runner no pacote server"
