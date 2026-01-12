#!/bin/bash

# ============================================================================
# 14_generate_ui_module.sh - Gera AppModule com DI
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=============================================="
echo "  Gerador de UI Module (DI)"
echo "=============================================="
echo ""

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome da entidade (PascalCase)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENTITY_SNAKE=$(to_snake_case "$ENTITY_NAME")
ROOT=$(get_project_root)
UI_PATH=$(get_ui_package_path "$FEATURE_SNAKE")
MODULE_FILE="$UI_PATH/lib/${FEATURE_SNAKE}_module.dart"
MAIN_FILE="$UI_PATH/lib/${FEATURE_SNAKE}_ui.dart"

validate_package_exists "$FEATURE_SNAKE" "ui" || exit 1
ensure_dir "$(dirname "$MODULE_FILE")"

progress "Gerando ${FEATURE_NAME^}Module..."

cat > "$MODULE_FILE" <<EOF
import 'package:flutter/material.dart';
import 'package:core_ui/core_ui.dart' show AppModule, AppNavigationItem;
import 'package:core_shared/core_shared.dart' show Loggable, DependencyInjector;
import 'package:${FEATURE_SNAKE}_shared/${FEATURE_SNAKE}_shared.dart';
import 'package:${FEATURE_SNAKE}_client/${FEATURE_SNAKE}_client.dart';
import 'ui/view_models/${ENTITY_SNAKE}_view_model.dart';
import 'ui/pages/${ENTITY_SNAKE}_list_page.dart';

/// Module para feature $FEATURE_NAME.
class ${FEATURE_NAME^}Module extends AppModule with Loggable {
  final DependencyInjector di;

  ${FEATURE_NAME^}Module({required this.di});

  @override
  void registerDependencies(DependencyInjector di) {
    // Services
    di.registerLazySingleton<${ENTITY_NAME}Service>(
      () => ${ENTITY_NAME}Service(di.get()),
    );

    // Repositories
    di.registerLazySingleton<${ENTITY_NAME}Repository>(
      () => ${ENTITY_NAME}RepositoryClient(di.get()),
    );

    // Use Cases
    di.registerLazySingleton<${ENTITY_NAME}GetAllUseCase>(
      () => ${ENTITY_NAME}GetAllUseCase(di.get()),
    );
    di.registerLazySingleton<${ENTITY_NAME}GetByIdUseCase>(
      () => ${ENTITY_NAME}GetByIdUseCase(di.get()),
    );
    di.registerLazySingleton<${ENTITY_NAME}CreateUseCase>(
      () => ${ENTITY_NAME}CreateUseCase(di.get()),
    );
    di.registerLazySingleton<${ENTITY_NAME}UpdateUseCase>(
      () => ${ENTITY_NAME}UpdateUseCase(di.get()),
    );
    di.registerLazySingleton<${ENTITY_NAME}DeleteUseCase>(
      () => ${ENTITY_NAME}DeleteUseCase(di.get()),
    );

    // ViewModels
    di.registerLazySingleton<${ENTITY_NAME}ViewModel>(
      () => ${ENTITY_NAME}ViewModel(
        get${ENTITY_NAME}sUseCase: di.get(),
        get${ENTITY_NAME}ByIdUseCase: di.get(),
        // create${ENTITY_NAME}UseCase: di.get(),
        // update${ENTITY_NAME}UseCase: di.get(),
        delete${ENTITY_NAME}UseCase: di.get(),
      ),
    );
     

    // Pages
    di.registerLazySingleton<${ENTITY_NAME}ListPage>(
      () => ${ENTITY_NAME}ListPage(
        viewModel: di.get(),
      ),
    );
  }

  @override
  Map<String, Widget> get routes => {
        '/${FEATURE_SNAKE}_list': di.get<${ENTITY_NAME}ListPage>(),
      };

  @override
  List<AppNavigationItem> get navigationItems => [
        AppNavigationItem(
          labelBuilder: (context) => '${ENTITY_NAME}s', // Use AppLocalizations
          icon: Icons.list,
          route: '/${FEATURE_SNAKE}_list',
        ),
      ];
}
EOF

progress "Gerando arquivo principal do pacote ${FEATURE_SNAKE}_ui.dart..."

cat > "$MAIN_FILE" <<EOF
library;

export '${FEATURE_SNAKE}_module.dart';
export 'ui/pages/${ENTITY_SNAKE}_list_page.dart';
export 'ui/view_models/${ENTITY_SNAKE}_view_model.dart';
EOF

success "Module e arquivo principal gerados!"

# Atualiza barrel files automaticamente
progress "Atualizando barrel files do UI..."
update_ui_barrel_files "$FEATURE_SNAKE"

echo ""
run_pub_get "$FEATURE_SNAKE"
echo ""
info "Próximos passos:"
info "  1. Registrar module no app principal"
info "  2. Implementar páginas"
