#!/bin/bash

# ============================================================================
# 04_generate_models.sh - Gera Models para serialização JSON MANUAL
# ============================================================================
#
# Responsabilidade: Gera *Model com serialização JSON MANUAL.
#
# Regras Arquiteturais:
# - Model contém campo 'entity' ou 'data'
# - Serialização JSON MANUAL (SEM @JsonSerializable)
# - Deve ter fromJson, toJson, fromDomain, toDomain
# - PROIBIDO usar @JsonSerializable ou freezed
#
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"
source "$SCRIPT_DIR/common/templates_engine.sh"

echo "=================================================="
echo "  Gerador de Models (JSON Manual)"
echo "=================================================="
echo ""

progress "Coletando informações..."

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome da entidade (PascalCase)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

ask "Tipo de Model (details/create/update)" MODEL_TYPE
if [[ "$MODEL_TYPE" != "details" && "$MODEL_TYPE" != "create" && "$MODEL_TYPE" != "update" ]]; then
  error "Tipo inválido. Use: details, create ou update"
  exit 1
fi

info "Informe os campos (mesmos da Entity/DTO)"
ask "Campos" FIELDS
validate_fields "$FIELDS" || exit 1

# Preparação
FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENTITY_SNAKE=$(to_snake_case "$ENTITY_NAME")
ROOT=$(get_project_root)
CORE_PATH=$(get_core_package_path "$FEATURE_SNAKE")
MODEL_DIR="$CORE_PATH/lib/src/data/models"

validate_package_exists "$FEATURE_SNAKE" "core" || exit 1
ensure_dir "$MODEL_DIR"

# ============================================================================
# Gera Model Details
# ============================================================================

if [[ "$MODEL_TYPE" == "details" ]]; then
  MODEL_FILE="$MODEL_DIR/${ENTITY_SNAKE}_details_model.dart"
  
  progress "Gerando ${ENTITY_NAME}DetailsModel..."
  
  FROM_JSON_FIELDS=$(generate_from_json_fields "$FIELDS" "        ")
  TO_JSON_FIELDS=$(generate_to_json_fields "$FIELDS" "entity" "        ")
  CONSTRUCTOR_PARAMS=$(generate_constructor_params "$FIELDS" "        " "true")
  
  cat > "$MODEL_FILE" <<EOF
import '../../domain/entities/${ENTITY_SNAKE}_details.dart';

/// Model para serialização JSON de ${ENTITY_NAME}Details.
///
/// - Contém campo 'entity' do tipo ${ENTITY_NAME}Details
/// - Serialização JSON MANUAL (sem @JsonSerializable)
/// - Métodos: fromJson, toJson, fromDomain, toDomain
class ${ENTITY_NAME}DetailsModel {
  final ${ENTITY_NAME}Details entity;

  ${ENTITY_NAME}DetailsModel(this.entity);

  /// Converte JSON para Model
  factory ${ENTITY_NAME}DetailsModel.fromJson(Map<String, dynamic> json) {
    return ${ENTITY_NAME}DetailsModel(
      ${ENTITY_NAME}Details(
        id: json['id'] as String,
        isDeleted: json['is_deleted'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
$FROM_JSON_FIELDS
      ),
    );
  }

  /// Converte Model para JSON
  Map<String, dynamic> toJson() => {
        'id': entity.id,
        'is_deleted': entity.isDeleted,
        'is_active': entity.isActive,
        'created_at': entity.createdAt.toIso8601String(),
        'updated_at': entity.updatedAt.toIso8601String(),
$TO_JSON_FIELDS
      };

  /// Converte Model para Domain
  ${ENTITY_NAME}Details toDomain() => entity;

  /// Converte Domain para Model
  factory ${ENTITY_NAME}DetailsModel.fromDomain(${ENTITY_NAME}Details details) =>
      ${ENTITY_NAME}DetailsModel(details);
}
EOF

  success "DetailsModel gerada!"
  info "Arquivo: $MODEL_FILE"
  
elif [[ "$MODEL_TYPE" == "create" ]]; then
  MODEL_FILE="$MODEL_DIR/${ENTITY_SNAKE}_create_model.dart"
  
  progress "Gerando ${ENTITY_NAME}CreateModel..."
  
  FROM_JSON_FIELDS=$(generate_from_json_fields "$FIELDS" "      ")
  TO_JSON_FIELDS=$(generate_to_json_fields "$FIELDS" "data" "        ")
  CONSTRUCTOR_PARAMS=$(generate_constructor_params "$FIELDS" "        " "true")
  
  cat > "$MODEL_FILE" <<EOF
import '../../domain/dtos/${ENTITY_SNAKE}_create.dart';

/// Model para serialização JSON de ${ENTITY_NAME}Create.
class ${ENTITY_NAME}CreateModel {
  final ${ENTITY_NAME}Create data;

  ${ENTITY_NAME}CreateModel(this.data);

  factory ${ENTITY_NAME}CreateModel.fromJson(Map<String, dynamic> json) {
    return ${ENTITY_NAME}CreateModel(
      ${ENTITY_NAME}Create(
$FROM_JSON_FIELDS
      ),
    );
  }

  Map<String, dynamic> toJson() => {
$TO_JSON_FIELDS
      };

  ${ENTITY_NAME}Create toDomain() => data;

  factory ${ENTITY_NAME}CreateModel.fromDomain(${ENTITY_NAME}Create dto) =>
      ${ENTITY_NAME}CreateModel(dto);
}
EOF

  success "CreateModel gerada!"
  info "Arquivo: $MODEL_FILE"

elif [[ "$MODEL_TYPE" == "update" ]]; then
  MODEL_FILE="$MODEL_DIR/${ENTITY_SNAKE}_update_model.dart"
  
  progress "Gerando ${ENTITY_NAME}UpdateModel..."
  
  FROM_JSON_FIELDS=$(generate_from_json_fields "$FIELDS" "        ")
  TO_JSON_FIELDS=$(generate_to_json_fields "$FIELDS" "data" "        ")
  
  cat > "$MODEL_FILE" <<EOF
import '../../domain/dtos/${ENTITY_SNAKE}_update.dart';

/// Model para serialização JSON de ${ENTITY_NAME}Update.
class ${ENTITY_NAME}UpdateModel {
  final ${ENTITY_NAME}Update data;

  ${ENTITY_NAME}UpdateModel(this.data);

  factory ${ENTITY_NAME}UpdateModel.fromJson(Map<String, dynamic> json) {
    return ${ENTITY_NAME}UpdateModel(
      ${ENTITY_NAME}Update(
        id: json['id'] as String,
        isActive: json['is_active'] as bool?,
        isDeleted: json['is_deleted'] as bool?,
$FROM_JSON_FIELDS
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': data.id,
        if (data.isActive != null) 'is_active': data.isActive,
        if (data.isDeleted != null) 'is_deleted': data.isDeleted,
$TO_JSON_FIELDS
      };

  ${ENTITY_NAME}Update toDomain() => data;

  factory ${ENTITY_NAME}UpdateModel.fromDomain(${ENTITY_NAME}Update dto) =>
      ${ENTITY_NAME}UpdateModel(dto);
}
EOF

  success "UpdateModel gerada!"
  info "Arquivo: $MODEL_FILE"
fi

# ============================================================================
# Gera ModelConverter (Automático)
# ============================================================================

CONVERTER_DIR="$CORE_PATH/lib/src/data/converters"
CONVERTER_FILE="$CONVERTER_DIR/${ENTITY_SNAKE}_${MODEL_TYPE}_converter.dart"

ensure_dir "$CONVERTER_DIR"

progress "Gerando ${ENTITY_NAME}${MODEL_TYPE^}Converter..."

MODEL_CLASS="${ENTITY_NAME}${MODEL_TYPE^}Model"
DOMAIN_CLASS="${ENTITY_NAME}${MODEL_TYPE^}"

# Define Imports baseados no tipo
if [[ "$MODEL_TYPE" == "details" ]]; then
  IMPORT_DOMAIN="import '../../domain/entities/${ENTITY_SNAKE}_details.dart';"
  DOMAIN_CLASS="${ENTITY_NAME}Details"
elif [[ "$MODEL_TYPE" == "create" ]]; then
  IMPORT_DOMAIN="import '../../domain/dtos/${ENTITY_SNAKE}_create.dart';"
  DOMAIN_CLASS="${ENTITY_NAME}Create"
elif [[ "$MODEL_TYPE" == "update" ]]; then
  IMPORT_DOMAIN="import '../../domain/dtos/${ENTITY_SNAKE}_update.dart';"
  DOMAIN_CLASS="${ENTITY_NAME}Update"
fi

cat > "$CONVERTER_FILE" <<EOF
$IMPORT_DOMAIN
import 'package:core_shared/core_shared.dart';
import '../models/${ENTITY_SNAKE}_${MODEL_TYPE}_model.dart';

/// Conversor para $DOMAIN_CLASS ↔ $MODEL_CLASS.
///
/// Centraliza lógica de conversão entre Model e Domain.
class ${ENTITY_NAME}${MODEL_TYPE^}Converter implements ModelConverter<$MODEL_CLASS, $DOMAIN_CLASS> {
  
  const ${ENTITY_NAME}${MODEL_TYPE^}Converter();
  
  @override
  $DOMAIN_CLASS toDomain($MODEL_CLASS model) => model.toDomain();
  
  @override
  $MODEL_CLASS fromDomain($DOMAIN_CLASS domain) => 
      $MODEL_CLASS.fromDomain(domain);
}
EOF

success "ModelConverter gerada!"
info "Arquivo: $CONVERTER_FILE"


echo ""
info "Próximos passos:"
info "  1. Gerar Constants com: ./06_generate_constants.sh"


# Atualiza barrel files automaticamente
progress "Atualizando barrel files..."
update_barrel_files "$FEATURE_SNAKE"
