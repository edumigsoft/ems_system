#!/bin/bash

# ============================================================================
# utils.sh - Funções auxiliares para scripts de geração
# ============================================================================

# Cores para output
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export RED='\033[0;31m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# ============================================================================
# Funções de Output
# ============================================================================

# Imprime mensagem de sucesso
success() {
  echo -e "${GREEN}✅ $1${NC}"
}

# Imprime mensagem de erro
error() {
  echo -e "${RED}❌ $1${NC}"
}

# Imprime mensagem de aviso
warn() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

# Imprime mensagem informativa
info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

# Imprime mensagem de progresso
progress() {
  echo -e "${CYAN}🚀 $1${NC}"
}

# ============================================================================
# Funções de Input
# ============================================================================

# Solicita input do usuário
# Uso: ask "Nome da feature?" FEATURE_NAME "book"
ask() {
  local prompt="$1"
  local var_name="$2"
  local default="$3"
  
  if [ -n "$default" ]; then
    read -p "$(echo -e "${CYAN}${prompt}${NC} [${default}]: ")" value
    value="${value:-$default}"
  else
    read -p "$(echo -e "${CYAN}${prompt}${NC}: ")" value
  fi
  
  eval "$var_name='$value'"
}

# Confirma ação (y/n)
# Uso: if confirm "Deseja continuar?"; then ...
confirm() {
  local prompt="$1"
  read -p "$(echo -e "${YELLOW}${prompt}${NC} (y/n): ")" response
  [[ "$response" =~ ^[Yy]$ ]]
}

# ============================================================================
# Funções de Conversão de Nomes
# ============================================================================

# Converte para PascalCase
# Exemplo: "book_management" -> "BookManagement"
to_pascal_case() {
  echo "$1" | sed 's/_/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' | sed 's/ //g'
}

# Converte para snake_case
# Exemplo: "BookManagement" -> "book_management"
to_snake_case() {
  echo "$1" | sed 's/\([A-Z]\)/_\L\1/g' | sed 's/^_//'
}

# Converte para camelCase
# Exemplo: "book_management" -> "bookManagement"
to_camel_case() {
  local pascal=$(to_pascal_case "$1")
  echo "${pascal,}"
}

# Converte para kebab-case
# Exemplo: "BookManagement" -> "book-management"
to_kebab_case() {
  echo "$1" | sed 's/\([A-Z]\)/-\L\1/g' | sed 's/^-//'
}

# ============================================================================
# Funções de Path
# ============================================================================

# Obtém o diretório raiz do projeto
# Procura por pubspec.yaml ou meson.build
get_project_root() {
  local current_dir="$PWD"
  
  while [[ "$current_dir" != "/" ]]; do
    if [[ -f "$current_dir/meson.build" ]] || [[ -f "$current_dir/.git/config" ]]; then
      echo "$current_dir"
      return 0
    fi
    current_dir="$(dirname "$current_dir")"
  done
  
  error "Diretório raiz do projeto não encontrado"
  return 1
}

# Verifica se um diretório existe
dir_exists() {
  [[ -d "$1" ]]
}

# Verifica se um arquivo existe
file_exists() {
  [[ -f "$1" ]]
}

# Cria diretório se não existir
ensure_dir() {
  if ! dir_exists "$1"; then
    mkdir -p "$1"
    success "Diretório criado: $1"
  fi
}

# ============================================================================
# Funções de Arquivo
# ============================================================================

# Substitui placeholders em arquivo
# Uso: replace_in_file "file.txt" "PLACEHOLDER" "value"
replace_in_file() {
  local file="$1"
  local placeholder="$2"
  local value="$3"
  
  if file_exists "$file"; then
    sed -i "s|$placeholder|$value|g" "$file"
  else
    error "Arquivo não encontrado: $file"
    return 1
  fi
}

# ============================================================================
# Funções de Feature/Package
# ============================================================================

# Obtém o caminho do pacote core
get_core_package_path() {
  local feature="$1"
  local root=$(get_project_root)
  echo "$root/packages/$feature/${feature}_core"
}

# Obtém o caminho do pacote client
get_client_package_path() {
  local feature="$1"
  local root=$(get_project_root)
  echo "$root/packages/$feature/${feature}_client"
}

# Obtém o caminho do pacote server
get_server_package_path() {
  local feature="$1"
  local root=$(get_project_root)
  echo "$root/packages/$feature/${feature}_server"
}

# Obtém o caminho do pacote ui
get_ui_package_path() {
  local feature="$1"
  local root=$(get_project_root)
  echo "$root/packages/$feature/${feature}_ui"
}

# ============================================================================
# Funções de Validação
# ============================================================================

# Verifica se o nome é válido (snake_case)
is_valid_name() {
  [[ "$1" =~ ^[a-z][a-z0-9_]*$ ]]
}

# Verifica se o tipo Dart é válido
is_valid_dart_type() {
  local type="$1"
  
  # Tipos primitivos
  local primitives=("String" "int" "double" "bool" "DateTime" "num")
  for primitive in "${primitives[@]}"; do
    if [[ "$type" == "$primitive" ]]; then
      return 0
    fi
  done
  
  # Tipos customizados (PascalCase)
  if [[ "$type" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
    return 0
  fi
  
  # Listas e Maps
  if [[ "$type" =~ ^List\<.*\>$ ]] || [[ "$type" =~ ^Map\<.*\>$ ]]; then
    return 0
  fi
  
  return 1
}

# ============================================================================
# Funções de Execução
# ============================================================================

# Executa comando e reporta sucesso/erro
run_command() {
  local cmd="$1"
  local success_msg="$2"
  local error_msg="$3"
  
  if eval "$cmd"; then
    if [[ -n "$success_msg" ]]; then
      success "$success_msg"
    fi
    return 0
  else
    if [[ -n "$error_msg" ]]; then
      error "$error_msg"
    fi
    return 1
  fi
}

# ============================================================================
# Funções de Template
# ============================================================================

# Carrega template de arquivo
load_template() {
  local template_name="$1"
  local root=$(get_project_root)
  local template_path="$root/docs/templates/core/${template_name}"
  
  if file_exists "$template_path"; then
    cat "$template_path"
  else
    error "Template não encontrado: $template_path"
    return 1
  fi
}

# ============================================================================
# Funções de Barrel Files
# ============================================================================

# Atualiza barrel files de um pacote core
# Uso: update_barrel_files "feature_name"
update_barrel_files() {
  local feature="$1"
  local core_path=$(get_core_package_path "$feature")
  
  if ! dir_exists "$core_path"; then
    warn "Pacote core não encontrado: $core_path"
    return 1
  fi
  
  local barrel_internal="$core_path/lib/src/${feature}_core.dart"
  local barrel_external="$core_path/lib/${feature}_core.dart"
  
  # Cria barrel file interno
  {
    echo "// Este arquivo é gerado automaticamente."
    echo "// Edite com cuidado ou regenere com os scripts."
    echo ""
    
    # Entities
    if dir_exists "$core_path/lib/src/domain/entities"; then
      echo "// Entities"
      find "$core_path/lib/src/domain/entities" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$core_path/lib/src" "$file")
        echo "export '$relative_path';"
      done
      echo ""
    fi
    
    # Repositories
    if dir_exists "$core_path/lib/src/domain/repositories"; then
      echo "// Repositories"
      find "$core_path/lib/src/domain/repositories" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$core_path/lib/src" "$file")
        echo "export '$relative_path';"
      done
      echo ""
    fi
    
    # Use Cases
    if dir_exists "$core_path/lib/src/domain/use_cases"; then
      echo "// Use Cases"
      find "$core_path/lib/src/domain/use_cases" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$core_path/lib/src" "$file")
        echo "export '$relative_path';"
      done
      echo ""
    fi
    
    # DTOs
    if dir_exists "$core_path/lib/src/domain/dtos"; then
      echo "// DTOs"
      find "$core_path/lib/src/domain/dtos" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$core_path/lib/src" "$file")
        echo "export '$relative_path';"
      done
      echo ""
    fi
    
    # Models
    if dir_exists "$core_path/lib/src/data/models"; then
      echo "// Models"
      find "$core_path/lib/src/data/models" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$core_path/lib/src" "$file")
        echo "export '$relative_path';"
      done
      echo ""
    fi
    
    # Converters
    if dir_exists "$core_path/lib/src/data/converters"; then
      echo "// Converters"
      find "$core_path/lib/src/data/converters" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$core_path/lib/src" "$file")
        echo "export '$relative_path';"
      done
      echo ""
    fi
    
    # Validators
    if dir_exists "$core_path/lib/src/validators"; then
      echo "// Validators"
      find "$core_path/lib/src/validators" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$core_path/lib/src" "$file")
        echo "export '$relative_path';"
      done
      echo ""
    fi
    
    # Constants
    if dir_exists "$core_path/lib/src/constants"; then
      echo "// Constants"
      find "$core_path/lib/src/constants" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$core_path/lib/src" "$file")
        echo "export '$relative_path';"
      done
    fi
  } > "$barrel_internal"
  
  # Cria barrel file externo
  echo "export 'src/${feature}_core.dart';" > "$barrel_external"
  
  info "Barrel files atualizados para $feature"
  return 0
}

# Atualiza barrel files de um pacote client
# Uso: update_client_barrel_files "feature_name"
update_client_barrel_files() {
  local feature="$1"
  local client_path=$(get_client_package_path "$feature")
  
  if ! dir_exists "$client_path"; then
    warn "Pacote client não encontrado: $client_path"
    return 1
  fi
  
  local barrel_internal="$client_path/lib/src/${feature}_client.dart"
  local barrel_external="$client_path/lib/${feature}_client.dart"
  
  # Cria barrel file interno
  {
    echo "// Este arquivo é gerado automaticamente."
    echo "// Edite com cuidado ou regenere com os scripts."
    echo ""
    
    # Services
    if dir_exists "$client_path/lib/src/services"; then
      echo "// Services"
      find "$client_path/lib/src/services" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$client_path/lib/src" "$file")
        echo "export '$relative_path';"
      done
      echo ""
    fi
    
    # Repositories
    if dir_exists "$client_path/lib/src/repositories"; then
      echo "// Repositories"
      find "$client_path/lib/src/repositories" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$client_path/lib/src" "$file")
        echo "export '$relative_path';"
      done
    fi
  } > "$barrel_internal"
  
  # Cria barrel file externo
  echo "export 'src/${feature}_client.dart';" > "$barrel_external"
  
  info "Barrel files atualizados para ${feature}_client"
  return 0
}

# Atualiza barrel files de um pacote ui
# Uso: update_ui_barrel_files "feature_name"
update_ui_barrel_files() {
  local feature="$1"
  local ui_path=$(get_ui_package_path "$feature")
  
  if ! dir_exists "$ui_path"; then
    warn "Pacote ui não encontrado: $ui_path"
    return 1
  fi
  
  local barrel_file="$ui_path/lib/${feature}_ui.dart"
  
  # Cria barrel file
  {
    echo "library;"
    echo ""
    
    # Module (principal)
    if file_exists "$ui_path/lib/${feature}_module.dart"; then
      echo "export '${feature}_module.dart';"
    fi
    
    # Pages
    if dir_exists "$ui_path/lib/ui/pages"; then
      find "$ui_path/lib/ui/pages" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$ui_path/lib" "$file")
        echo "export '$relative_path';"
      done
    fi
    
    # ViewModels
    if dir_exists "$ui_path/lib/ui/view_models"; then
      find "$ui_path/lib/ui/view_models" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$ui_path/lib" "$file")
        echo "export '$relative_path';"
      done
    fi
    
    # Widgets (opcional, mas comum exportar para reutilização)
    if dir_exists "$ui_path/lib/ui/widgets"; then
      find "$ui_path/lib/ui/widgets" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$ui_path/lib" "$file")
        echo "export '$relative_path';"
      done
    fi
  } > "$barrel_file"
  
  info "Barrel files atualizados para ${feature}_ui"
  return 0
}

# Atualiza barrel files de um pacote server
# Uso: update_server_barrel_files "feature_name"
update_server_barrel_files() {
  local feature="$1"
  local server_path=$(get_server_package_path "$feature")
  
  if ! dir_exists "$server_path"; then
    warn "Pacote server não encontrado: $server_path"
    return 1
  fi
  
  local barrel_file="$server_path/lib/${feature}_server.dart"
  
  # Cria barrel file apenas com exports (imports serão adicionados manualmente quando criar Init class)
  {
    echo "library;"
    echo ""
    
    # Exports de Tables
    if dir_exists "$server_path/lib/src/database/tables"; then
      find "$server_path/lib/src/database/tables" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$server_path/lib" "$file")
        echo "export '$relative_path';"
      done
    fi
    
    # Export de Database (se existir)
    if file_exists "$server_path/lib/src/database/${feature}_database.dart"; then
      echo "export 'src/database/${feature}_database.dart';"
    fi
    
    # Exports de Repositories
    if dir_exists "$server_path/lib/src/repositories"; then
      find "$server_path/lib/src/repositories" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$server_path/lib" "$file")
        echo "export '$relative_path';"
      done
    fi
    
    # Exports de Routes
    if dir_exists "$server_path/lib/src/routes"; then
      find "$server_path/lib/src/routes" -name "*.dart" -type f | sort | while read -r file; do
        local relative_path=$(realpath --relative-to="$server_path/lib" "$file")
        echo "export '$relative_path';"
      done
    fi
  } > "$barrel_file"
  
  info "Barrel files atualizados para ${feature}_server (apenas exports)"
  return 0
}



# Valida se o pacote existe
validate_package_exists() {
  local feature="$1"
  local package_type="${2:-core}"
  local root=$(get_project_root)
  local package_path="$root/packages/$feature/${feature}_${package_type}"
  
  if ! dir_exists "$package_path"; then
    error "Pacote $feature/${feature}_${package_type} não encontrado"
    return 1
  fi
  
  return 0
}

# Executa pub get no pacote
# Uso: run_pub_get "feature_name"
run_pub_get() {
  local feature="$1"
  local core_path=$(get_core_package_path "$feature")
  
  if [[ "$SKIP_INTERNAL_PUB_GET" == "true" ]]; then
    # info "Pulando pub get (SKIP_INTERNAL_PUB_GET=true)"
    return 0
  fi
  
  if ! dir_exists "$core_path"; then
    warn "Pacote core não encontrado: $core_path"
    return 1
  fi
  
  progress "Executando dart pub get..."
  
  # Removido > /dev/null para permitir debug se travar
  if (cd "$core_path" && dart pub get); then
    success "Dependências atualizadas!"
    return 0
  else
    warn "Falha ao executar pub get (pode ser normal se o pacote ainda não está completo)"
    return 1
  fi
}

