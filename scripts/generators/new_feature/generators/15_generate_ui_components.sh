#!/bin/bash

# ============================================================================
# 15_generate_ui_components.sh - Gera Pages + ViewModels (MVVM)
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=============================================="
echo "  Gerador de UI Components (MVVM)"
echo "=============================================="
echo ""

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome da entidade (PascalCase)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

ask "Nome da entidade (plural)" ENTITY_PLURAL
validate_name "$ENTITY_PLURAL" || exit 1

FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENTITY_SNAKE=$(to_snake_case "$ENTITY_NAME")
ROOT=$(get_project_root)
UI_PATH=$(get_ui_package_path "$FEATURE_SNAKE")
VM_DIR="$UI_PATH/lib/ui/view_models"
PAGES_DIR="$UI_PATH/lib/ui/pages"

validate_package_exists "$FEATURE_SNAKE" "ui" || exit 1
ensure_dir "$VM_DIR"
ensure_dir "$PAGES_DIR"

progress "Gerando ${ENTITY_NAME}ViewModel..."

# ViewModel  
cat > "$VM_DIR/${ENTITY_SNAKE}_view_model.dart" <<EOF
import 'package:flutter/foundation.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_shared/core_shared.dart' hide Loggable;
import 'package:${FEATURE_SNAKE}_core/${FEATURE_SNAKE}_core.dart';
// import '../validators/${ENTITY_SNAKE}_validators.dart';

/// ViewModel para gerenciar estado de $ENTITY_NAME.
///
/// Segue padrão MVVM:
/// - Extends ChangeNotifier para reatividade
/// - Usa FormValidationMixin para validação
/// - Usa Loggable para logging
class ${ENTITY_NAME}ViewModel extends ChangeNotifier 
    with Loggable, FormValidationMixin {
  final ${ENTITY_NAME}GetAllUseCase _get${ENTITY_NAME}sUseCase;
  final ${ENTITY_NAME}GetByIdUseCase _get${ENTITY_NAME}ByIdUseCase;
  // final ${ENTITY_NAME}CreateUseCase _create${ENTITY_NAME}UseCase;
  // final ${ENTITY_NAME}UpdateUseCase _update${ENTITY_NAME}UseCase;
  final ${ENTITY_NAME}DeleteUseCase _delete${ENTITY_NAME}UseCase;

  ${ENTITY_NAME}ViewModel({
    required ${ENTITY_NAME}GetAllUseCase get${ENTITY_NAME}sUseCase,
    required ${ENTITY_NAME}GetByIdUseCase get${ENTITY_NAME}ByIdUseCase,
    // required ${ENTITY_NAME}CreateUseCase create${ENTITY_NAME}UseCase,
    // required ${ENTITY_NAME}UpdateUseCase update${ENTITY_NAME}UseCase,
    required ${ENTITY_NAME}DeleteUseCase delete${ENTITY_NAME}UseCase,
  })  : _get${ENTITY_NAME}sUseCase = get${ENTITY_NAME}sUseCase,
        _get${ENTITY_NAME}ByIdUseCase = get${ENTITY_NAME}ByIdUseCase,
        // _create${ENTITY_NAME}UseCase = create${ENTITY_NAME}UseCase,
        // _update${ENTITY_NAME}UseCase = update${ENTITY_NAME}UseCase,
        _delete${ENTITY_NAME}UseCase = delete${ENTITY_NAME}UseCase;

  List<${ENTITY_NAME}Details> _items = [];
  List<${ENTITY_NAME}Details> get items => _items;

  ${ENTITY_NAME}Details? _selectedItem;
  ${ENTITY_NAME}Details? get selectedItem => _selectedItem;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Carrega lista de ${ENTITY_PLURAL}
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _get${ENTITY_NAME}sUseCase();

    if (result case Success(value: final data)) {
      _items = data;
      _isLoading = false;
      notifyListeners();
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega ${ENTITY_NAME} por ID
  Future<void> loadItemById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _get${ENTITY_NAME}ByIdUseCase(id);

    if (result case Success(value: final data)) {
      _selectedItem = data;
      _isLoading = false;
      notifyListeners();
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cria novo ${ENTITY_NAME}
  // Future<bool> create(Map<String, dynamic> formData) async {
  //   // Validação com Zard
  //   final validationResult = validateForm(
  //     data: formData,
  //     schema: ${ENTITY_NAME}Validators.create,
  //   );
  //   
  //   if (validationResult case Failure(error: final error)) {
  //      _error = error.toString();
  //      notifyListeners();
  //      return false;
  //   }
  // 
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();
  // 
  //   // Implemente a criação do DTO removendo o null e o throw abaixo
  //   // Exemplo:
  //   // final dto = ${ENTITY_NAME}Create(
  //   //   field1: formData['field1'],
  //   //   field2: formData['field2'],
  //   // );
  //   final ${ENTITY_NAME}Create? dto = null;
  //   if (dto == null) {
  //     throw UnimplementedError('Implemente a criação do ${ENTITY_NAME}Create DTO');
  //   }
  //   
  //   final result = await _create${ENTITY_NAME}UseCase(dto);
  //   
  //   if (result case Success()) {
  //     await loadItems();
  //     _isLoading = false;
  //     notifyListeners();
  //     return true;
  //   } else if (result case Failure(error: final error)) {
  //     _error = error.toString();
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   }
  // }

  /// Atualiza ${ENTITY_NAME}
  // Future<bool> update(String id, Map<String, dynamic> formData) async {
  //  // Validação com Zard
  //  final validationResult = validateForm(
  //    data: formData,
  //    schema: ${ENTITY_NAME}Validators.update,
  //  );
  //  
  //  if (validationResult case Failure(error: final error)) {
  //     _error = error.toString();
  //     notifyListeners();
  //     return false;
  //  }
  //
  //  _isLoading = true;
  //  _error = null;
  //  notifyListeners();

  //  // Implemente a criação do DTO removendo o null e o throw abaixo
  //  // Exemplo:
  //  // final dto = ${ENTITY_NAME}Update(
  //  //   id: id,
  //  //   field1: formData['field1'],
  //  //   field2: formData['field2'],
  //  // );
  //  final ${ENTITY_NAME}Update? dto = null;
  //  if (dto == null) {
  //    throw UnimplementedError('Implemente a criação do ${ENTITY_NAME}Update DTO');
  //  }
  //  
  //  final result = await _update${ENTITY_NAME}UseCase(dto);
  //  
  //  if (result case Success()) {
  //    await loadItems();
  //    _isLoading = false;
  //    notifyListeners();
  //    return true;
  //  } else if (result case Failure(error: final error)) {
  //    _error = error.toString();
  //    _isLoading = false;
  //    notifyListeners();
  //    return false;
  //  }
  //}

  /// Deleta ${ENTITY_NAME}
  Future<bool> delete(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _delete${ENTITY_NAME}UseCase(id);

    if (result case Success()) {
      await loadItems();
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
    
    return false; // Fallback para garantir retorno em todos os caminhos
  }
}
EOF

success "ViewModel gerada!"
info "Arquivo: $VM_DIR/${ENTITY_SNAKE}_view_model.dart"
echo ""
run_pub_get "$FEATURE_SNAKE"
echo ""
info "Próximos passos:"
info "  1. Implementar métodos de criação/atualização"
info "  2. Criar Pages correspondentes"
info "  3. Registrar no DI Module"

progress "Gerando ${ENTITY_NAME}ListPage..."

# ListPage
cat > "$PAGES_DIR/${ENTITY_SNAKE}_list_page.dart" <<EOF
import 'package:flutter/material.dart';
import '../view_models/${ENTITY_SNAKE}_view_model.dart';
import '../widgets/${ENTITY_SNAKE}_card.dart';

class ${ENTITY_NAME}ListPage extends StatelessWidget {
  final ${ENTITY_NAME}ViewModel viewModel;

  const ${ENTITY_NAME}ListPage({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${ENTITY_PLURAL}'),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('Erro: \${viewModel.error}'));
          }

          if (viewModel.items.isEmpty) {
            return const Center(child: Text('Nenhum item encontrado'));
          }

          return ListView.builder(
            itemCount: viewModel.items.length,
            itemBuilder: (context, index) {
              final item = viewModel.items[index];
              return ${ENTITY_NAME}Card(
                item: item,
                onTap: () {
                  // Navegar para detalhes
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para criação
          // viewModel.create(...);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
EOF

success "ListPage gerada!"
info "Arquivo: $PAGES_DIR/${ENTITY_SNAKE}_list_page.dart"

# Atualiza barrel files automaticamente
progress "Atualizando barrel files do UI..."
update_ui_barrel_files "$FEATURE_SNAKE"
