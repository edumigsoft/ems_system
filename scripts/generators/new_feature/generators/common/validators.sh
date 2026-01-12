#!/bin/bash

# ============================================================================
# validators.sh - Validações de input para geração de código
# ============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# ============================================================================
# Validações de Nome
# ============================================================================

# Valida nome de feature/entidade
validate_name() {
  local name="$1"
  local type="${2:-nome}"
  
  if [[ -z "$name" ]]; then
    error "$type não pode ser vazio"
    return 1
  fi
  
  if ! is_valid_name "$name"; then
    error "$type deve estar em snake_case (ex: book_management)"
    return 1
  fi
  
  return 0
}

# Valida nome de classe (PascalCase)
validate_class_name() {
  local name="$1"
  
  if [[ -z "$name" ]]; then
    error "Nome da classe não pode ser vazio"
    return 1
  fi
  
  if ! [[ "$name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
    error "Nome da classe deve estar em PascalCase (ex: BookManagement)"
    return 1
  fi
  
  return 0
}

# ============================================================================
# Validações de Campo
# ============================================================================

# Valida definição de campo (formato: nome:tipo)
validate_field() {
  local field="$1"
  
  if [[ -z "$field" ]]; then
    error "Campo não pode ser vazio"
    return 1
  fi
  
  # Formato esperado: nome:tipo
  if ! [[ "$field" =~ ^[a-z][a-zA-Z0-9]*:[A-Z][a-zA-Z0-9\<\>,]*$ ]]; then
    error "Campo inválido. Formato esperado: nome:Tipo (ex: title:String, items:List<String>)"
    return 1
  fi
  
  local field_name=$(echo "$field" | cut -d: -f1)
  local field_type=$(echo "$field" | cut -d: -f2)
  
  # Valida nome do campo (camelCase)
  if ! [[ "$field_name" =~ ^[a-z][a-zA-Z0-9]*$ ]]; then
    error "Nome do campo '$field_name' deve estar em camelCase"
    return 1
  fi
  
  # Valida tipo
  if ! is_valid_dart_type "$field_type"; then
    error "Tipo inválido: $field_type"
    return 1
  fi
  
  return 0
}

# Valida lista de campos
validate_fields() {
  local fields_str="$1"
  
  if [[ -z "$fields_str" ]]; then
    error "Lista de campos não pode ser vazia"
    return 1
  fi
  
  # Separa campos por vírgula
  IFS=',' read -ra FIELD_ARRAY <<< "$fields_str"
  
  for field in "${FIELD_ARRAY[@]}"; do
    # Remove espaços
    field=$(echo "$field" | xargs)
    
    if ! validate_field "$field"; then
      return 1
    fi
  done
  
  return 0
}

# ============================================================================
# Validações de Pacote
# ============================================================================

# Valida se o pacote existe
validate_package_exists() {
  local feature="$1"
  local package_type="$2"  # core, client, server, ui
  
  local root=$(get_project_root)
  local package_path="$root/packages/$feature/${feature}_${package_type}"
  
  if ! dir_exists "$package_path"; then
    error "Pacote $package_type não encontrado: $package_path"
    error "Execute scaffold_feature.sh primeiro para criar a estrutura"
    return 1
  fi
  
  return 0
}

# Valida se a feature existe
validate_feature_exists() {
  local feature="$1"
  
  local root=$(get_project_root)
  local feature_path="$root/packages/$feature"
  
  if ! dir_exists "$feature_path"; then
    error "Feature '$feature' não encontrada"
    error "Execute scaffold_feature.sh primeiro para criar a estrutura"
    return 1
  fi
  
  return 0
}

# ============================================================================
# Validações de Arquivo
# ============================================================================

# Valida se arquivo não existe (para evitar sobrescrever)
validate_file_not_exists() {
  local file_path="$1"
  
  if file_exists "$file_path"; then
    warn "Arquivo já existe: $file_path"
    
    if ! confirm "Deseja sobrescrever?"; then
      info "Operação cancelada"
      return 1
    fi
  fi
  
  return 0
}

# ============================================================================
# Validações de Enums
# ============================================================================

# Valida valores de enum (separados por vírgula)
validate_enum_values() {
  local values_str="$1"
  
  if [[ -z "$values_str" ]]; then
    error "Valores do enum não podem ser vazios"
    return 1
  fi
  
  # Separa valores por vírgula
  IFS=',' read -ra VALUE_ARRAY <<< "$values_str"
  
  if [[ ${#VALUE_ARRAY[@]} -lt 2 ]]; then
    error "Enum deve ter pelo menos 2 valores"
    return 1
  fi
  
  for value in "${VALUE_ARRAY[@]}"; do
    # Remove espaços
    value=$(echo "$value" | xargs)
    
    # Valida formato camelCase
    if ! [[ "$value" =~ ^[a-z][a-zA-Z0-9]*$ ]]; then
      error "Valor de enum '$value' inválido. Use camelCase (ex: active, pending)"
      return 1
    fi
  done
  
  return 0
}

# ============================================================================
# Validações Arquiteturais
# ============================================================================

# Valida que Entity não tem campo 'id'
validate_entity_no_id() {
  local fields_str="$1"
  
  if [[ "$fields_str" =~ id: ]]; then
    error "Entity NÃO deve ter campo 'id'"
    error "O campo 'id' é detalhe de persistência e deve estar apenas em *Details"
    return 1
  fi
  
  return 0
}

# Valida que Create DTO não tem timestamps
validate_create_no_timestamps() {
  local fields_str="$1"
  
  if [[ "$fields_str" =~ createdAt: ]] || [[ "$fields_str" =~ updatedAt: ]]; then
    error "Create DTO NÃO deve ter campos 'createdAt' ou 'updatedAt'"
    error "Timestamps são gerenciados automaticamente"
    return 1
  fi
  
  if [[ "$fields_str" =~ id: ]]; then
    error "Create DTO NÃO deve ter campo 'id'"
    error "O ID é gerado automaticamente"
    return 1
  fi
  
  return 0
}

# ============================================================================
# Helper: Extrai informações de campo
# ============================================================================

# Extrai nome do campo de uma definição
get_field_name() {
  echo "$1" | cut -d: -f1 | xargs
}

# Extrai tipo do campo de uma definição
get_field_type() {
  echo "$1" | cut -d: -f2 | xargs
}
