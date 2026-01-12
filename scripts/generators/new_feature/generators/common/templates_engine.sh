#!/bin/bash

# ============================================================================
# templates_engine.sh - Engine de processamento de templates
# ============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# ============================================================================
# Funções de Processamento de Templates
# ============================================================================

# Processa template substituindo placeholders
# Uso: process_template "template_content" FEATURE=book ENTITY=Book
process_template() {
  local content="$1"
  shift
  
  # Para cada par chave=valor passado
  while [[ $# -gt 0 ]]; do
    local pair="$1"
    local key=$(echo "$pair" | cut -d= -f1)
    local value=$(echo "$pair" | cut -d= -f2-)
    
    # Substitui placeholder {{KEY}} pelo valor
    content=$(echo "$content" | sed "s|{{$key}}|$value|g")
    
    shift
  done
  
  echo "$content"
}

# Carrega e processa template de arquivo
# Uso: process_template_file "entity.dart.template" FEATURE=book ENTITY=Book
process_template_file() {
  local template_name="$1"
  shift
  
  local content=$(load_template "$template_name")
  
  if [[ -z "$content" ]]; then
    return 1
  fi
  
  process_template "$content" "$@"
}

# ============================================================================
# Geração de Campos
# ============================================================================

# Gera declarações de campos para classe
# Formato entrada: "title:String,isbn:String,year:int"
# Formato saída: "  final String title;\n  final String isbn;\n  final int year;"
generate_field_declarations() {
  local fields_str="$1"
  local indent="${2:-  }"
  
  IFS=',' read -ra FIELDS <<< "$fields_str"
  
  local declarations=""
  
  for field in "${FIELDS[@]}"; do
    field=$(echo "$field" | xargs)
    
    local field_name=$(get_field_name "$field")
    local field_type=$(get_field_type "$field")
    
    declarations+="${indent}final $field_type $field_name;\n"
  done
  
  echo -e "$declarations"
}

# Gera parâmetros de construtor
# Formato: "required this.title, required this.isbn"
generate_constructor_params() {
  local fields_str="$1"
  local indent="${2:-    }"
  local required="${3:-true}"
  
  IFS=',' read -ra FIELDS <<< "$fields_str"
  
  local params=""
  
  for i in "${!FIELDS[@]}"; do
    local field=$(echo "${FIELDS[$i]}" | xargs)
    local field_name=$(get_field_name "$field")
    
    if [[ "$required" == "true" ]]; then
      params+="${indent}required this.$field_name"
    else
      params+="${indent}this.$field_name"
    fi
    
    # Adiciona vírgula se não for o último
    if [[ $i -lt $((${#FIELDS[@]} - 1)) ]]; then
      params+=","
    fi
    
    params+="\n"
  done
  
  echo -e "$params"
}

# Gera argumentos para inicialização de Entity
# Formato: "field_name: field_name"
# Usado para passar argumentos do construtor de Details para a Entity
generate_entity_constructor_args() {
  local fields_str="$1"
  local indent="${2:-       }"
  
  IFS=',' read -ra FIELDS <<< "$fields_str"
  
  local args=""
  
  for i in "${!FIELDS[@]}"; do
    local field=$(echo "${FIELDS[$i]}" | xargs)
    local field_name=$(get_field_name "$field")
    
    args+="${indent}$field_name: $field_name"
    
    # Adiciona vírgula se não for o último
    if [[ $i -lt $((${#FIELDS[@]} - 1)) ]]; then
      args+=","
    fi
    
    args+="\n"
  done
  
  echo -e "$args"
}

# Gera parâmetros para o construtor de Details (SEM this.)
# Formato: "required String name" para ser usado em Details
generate_entity_details_constructor_params() {
  local fields_str="$1"
  local indent="${2:-    }"
  
  IFS=',' read -ra FIELDS <<< "$fields_str"
  
  local params=""
  
  for i in "${!FIELDS[@]}"; do
    local field=$(echo "${FIELDS[$i]}" | xargs)
    local field_name=$(get_field_name "$field")
    local field_type=$(get_field_type "$field")
    
    # Verifica se o tipo é nullable
    if [[ "$field_type" == *"?"* ]]; then
      params+="${indent}$field_type $field_name"
    else
      params+="${indent}required $field_type $field_name"
    fi
    
    # Adiciona vírgula
    if [[ $i -lt $((${#FIELDS[@]} - 1)) ]]; then
      params+=","
    else
      params+=","
    fi
    
    params+="\n"
  done
  
  echo -e "$params"
}

# Gera factory empty() para Details
generate_details_empty_factory() {
  local class_name="$1"
  local fields_str="$2"
  local indent="${3:-  }"
  
  IFS=',' read -ra FIELDS <<< "$fields_str"
  
  local factory_params=""
  
  for field in "${FIELDS[@]}"; do
    field=$(echo "$field" | xargs)
    
    local field_name=$(get_field_name "$field")
    local field_type=$(get_field_type "$field")
    
    # Valores padrão baseados no tipo
    local default_value="''"
    
    if [[ "$field_type" == "int" ]]; then
      default_value="0"
    elif [[ "$field_type" == "double" ]]; then
      default_value="0.0"
    elif [[ "$field_type" == "bool" ]]; then
      default_value="false"
    elif [[ "$field_type" == "DateTime" ]]; then
      default_value="DateTime.now()"
    elif [[ "$field_type" == *"?"* ]]; then
      default_value="null"
    fi
    
    factory_params+="${indent}    $field_name: $default_value,\n"
  done
  
  cat <<EOF
${indent}factory ${class_name}Details.empty() {
${indent}  return ${class_name}Details(
${indent}    id: '',
${indent}    isDeleted: false,
${indent}    isActive: true,
${indent}    createdAt: DateTime.now(),
${indent}    updatedAt: DateTime.now(),
$(echo -e "$factory_params")${indent}  );
${indent}}
EOF
}

# Gera método copyWith() para Details
generate_details_copy_with() {
  local class_name="$1"
  local fields_str="$2"
  local indent="${3:-  }"
  
  IFS=',' read -ra FIELDS <<< "$fields_str"
  
  # Parâmetros do copyWith
  local copywith_params=""
  copywith_params+="${indent}  String? id,\n"
  copywith_params+="${indent}  bool? isDeleted,\n"
  copywith_params+="${indent}  bool? isActive,\n"
  copywith_params+="${indent}  DateTime? createdAt,\n"
  copywith_params+="${indent}  DateTime? updatedAt,\n"
  
  local null_flags=""
  
  for field in "${FIELDS[@]}"; do
    field=$(echo "$field" | xargs)
    
    local field_name=$(get_field_name "$field")
    local field_type=$(get_field_type "$field")
    
    # Adiciona parâmetro
    copywith_params+="${indent}  $field_type? $field_name,\n"
    
    # Se for nullable, adiciona flag isNull
    if [[ "$field_type" == *"?"* ]]; then
      null_flags+="${indent}  bool isNull${field_name^} = false,\n"
    fi
  done
  
  # Remove última vírgula e adiciona fechamento
  if [[ -n "$null_flags" ]]; then
    copywith_params+="$null_flags"
  fi
  
  # Construtor args
  local constructor_args=""
  constructor_args+="${indent}    id: id ?? this.id,\n"
  constructor_args+="${indent}    isDeleted: isDeleted ?? this.isDeleted,\n"
  constructor_args+="${indent}    isActive: isActive ?? this.isActive,\n"
  constructor_args+="${indent}    createdAt: createdAt ?? this.createdAt,\n"
  constructor_args+="${indent}    updatedAt: updatedAt ?? this.updatedAt,\n"
  
  for field in "${FIELDS[@]}"; do
    field=$(echo "$field" | xargs)
    
    local field_name=$(get_field_name "$field")
    local field_type=$(get_field_type "$field")
    
    if [[ "$field_type" == *"?"* ]]; then
      # Nullable - usa flag isNull
      constructor_args+="${indent}    $field_name: isNull${field_name^}\n"
      constructor_args+="${indent}        ? null\n"
      constructor_args+="${indent}        : $field_name ?? this.$field_name,\n"
    else
      # Non-nullable
      constructor_args+="${indent}    $field_name: $field_name ?? this.$field_name,\n"
    fi
  done
  
  cat <<EOF
${indent}${class_name}Details copyWith({
$(echo -e "$copywith_params")${indent}}) {
${indent}  return ${class_name}Details(
$(echo -e "$constructor_args")${indent}  );
${indent}}
EOF
}

# Gera getters de conveniência para Details
# Formato: "  String get title => data.title;"
generate_convenience_getters() {
  local fields_str="$1"
  local data_field="${2:-data}"
  local indent="${3:-  }"
  
  IFS=',' read -ra FIELDS <<< "$fields_str"
  
  local getters=""
  
  for field in "${FIELDS[@]}"; do
    field=$(echo "$field" | xargs)
    
    local field_name=$(get_field_name "$field")
    local field_type=$(get_field_type "$field")
    
    getters+="${indent}$field_type get $field_name => $data_field.$field_name;\n"
  done
  
  echo -e "$getters"
}

# Gera campos para toJson
# Formato: "    'title': entity.title,\n    'isbn': entity.isbn,"
generate_to_json_fields() {
  local fields_str="$1"
  local entity_var="${2:-entity}"
  local indent="${3:-        }"
  
  IFS=',' read -ra FIELDS <<< "$fields_str"
  
  local json_fields=""
  
  for field in "${FIELDS[@]}"; do
    field=$(echo "$field" | xargs)
    
    local field_name=$(get_field_name "$field")
    local field_type=$(get_field_type "$field")
    
    # Tratamento especial para DateTime
    if [[ "$field_type" == "DateTime" ]]; then
      json_fields+="${indent}'$field_name': $entity_var.$field_name.toIso8601String(),\n"
    else
      json_fields+="${indent}'$field_name': $entity_var.$field_name,\n"
    fi
  done
  
  echo -e "$json_fields"
}

# Gera campos para fromJson
# Formato: "      title: json['title'] as String,"
generate_from_json_fields() {
  local fields_str="$1"
  local indent="${2:-        }"
  
  IFS=',' read -ra FIELDS <<< "$fields_str"
  
  local json_fields=""
  
  for field in "${FIELDS[@]}"; do
    field=$(echo "$field" | xargs)
    
    local field_name=$(get_field_name "$field")
    local field_type=$(get_field_type "$field")
    
    # Tratamento especial para DateTime
    if [[ "$field_type" == "DateTime" ]]; then
      json_fields+="${indent}$field_name: DateTime.parse(json['$field_name'] as String),\n"
    else
      json_fields+="${indent}$field_name: json['$field_name'] as $field_type,\n"
    fi
  done
  
  echo -e "$json_fields"
}

# ============================================================================
# Geração de Code Snippets Complexos
# ============================================================================

# Gera operator == para classe
generate_equals_operator() {
  local class_name="$1"
  local fields_str="$2"
  local indent="${3:-  }"
  
  IFS=',' read -ra FIELDS <<< "$fields_str"
  
  local comparisons=""
  
  for i in "${!FIELDS[@]}"; do
    local field=$(echo "${FIELDS[$i]}" | xargs)
    local field_name=$(get_field_name "$field")
    
    if [[ $i -eq 0 ]]; then
      comparisons+="${indent}      $field_name == other.$field_name"
    else
      comparisons+=" &&"$'\n'"${indent}          $field_name == other.$field_name"
    fi
  done
  
  cat <<EOF
${indent}@override
${indent}bool operator ==(Object other) =>
${indent}      identical(this, other) ||
${indent}      other is $class_name &&
${indent}          runtimeType == other.runtimeType &&
$comparisons;
EOF
}

# Gera método copyWith para classe
generate_copy_with() {
  local class_name="$1"
  local fields_str="$2"
  local indent="${3:-  }"
  
  IFS=',' read -ra FIELDS <<< "$fields_str"
  
  # Parâmetros do copyWith (todos opcionais)
  local params=""
  for i in "${!FIELDS[@]}"; do
    local field=$(echo "${FIELDS[$i]}" | xargs)
    local field_name=$(get_field_name "$field")
    local field_type=$(get_field_type "$field")
    
    params+="${indent}  $field_type? $field_name,"$'\n'
  done
  
  # Construtor com valores
  local constructor_args=""
  for i in "${!FIELDS[@]}"; do
    local field=$(echo "${FIELDS[$i]}" | xargs)
    local field_name=$(get_field_name "$field")
    
    constructor_args+="${indent}    $field_name: $field_name ?? this.$field_name,"$'\n'
  done
  
  cat <<EOF
${indent}/// Cria uma cópia da entidade com os campos especificados atualizados
${indent}$class_name copyWith({
$params${indent}}) {
${indent}  return $class_name(
$constructor_args${indent}  );
${indent}}
EOF
}

# Gera hashCode para classe usando padrão XOR
generate_hash_code() {
  local fields_str="$1"
  local indent="${2:-  }"
  
  IFS=',' read -ra FIELDS <<< "$fields_str"
  
  # Se for apenas um campo, use .hashCode direto
  if [[ ${#FIELDS[@]} -eq 1 ]]; then
    local field=$(echo "${FIELDS[0]}" | xargs)
    local field_name=$(get_field_name "$field")
    
    echo "${indent}@override"
    echo "${indent}int get hashCode => $field_name.hashCode;"
  else
    # Múltiplos campos: use XOR (^)
    local hash_expr=""
    
    for i in "${!FIELDS[@]}"; do
      local field=$(echo "${FIELDS[$i]}" | xargs)
      local field_name=$(get_field_name "$field")
      
      if [[ $i -eq 0 ]]; then
        hash_expr+="${indent}      $field_name.hashCode"
      else
        hash_expr+=" ^"$'\n'"${indent}      $field_name.hashCode"
      fi
    done
    
    cat <<EOF
${indent}@override
${indent}int get hashCode =>
$hash_expr;
EOF
  fi
}

# Gera toString para classe
generate_to_string() {
  local class_name="$1"
  local fields_str="$2"
  local indent="${3:-  }"
  
  IFS=',' read -ra FIELDS <<< "$fields_str"
  
  local field_list=""
  
  for i in "${!FIELDS[@]}"; do
    local field=$(echo "${FIELDS[$i]}" | xargs)
    local field_name=$(get_field_name "$field")
    
    if [[ $i -eq 0 ]]; then
      field_list="$field_name: \$$field_name"
    else
      field_list+=", $field_name: \$$field_name"
    fi
  done
  
  cat <<EOF
${indent}@override
${indent}String toString() => '$class_name($field_list)';
EOF
}

# ============================================================================
# Helpers de Formatação
# ============================================================================

# Remove última vírgula de string
remove_trailing_comma() {
  echo "$1" | sed 's/,$//'
}

# Adiciona indent a cada linha
add_indent() {
  local content="$1"
  local indent="$2"
  
  echo "$content" | sed "s/^/$indent/"
}
