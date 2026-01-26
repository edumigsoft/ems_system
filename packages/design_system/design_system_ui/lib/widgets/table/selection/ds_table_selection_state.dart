import 'package:flutter/foundation.dart';

/// Estado de seleção múltipla para tabelas.
///
/// Gerencia quais itens estão selecionados, permitindo seleção individual,
/// seleção de todos, e limpeza de seleção. Usa [ChangeNotifier] para
/// notificar listeners sobre mudanças.
///
/// **Exemplo de uso:**
/// ```dart
/// final selectionState = DSTableSelectionState<School>();
///
/// selectionState.addListener(() {
///   setState(() {});
/// });
///
/// // Selecionar/desselecionar item
/// selectionState.toggle(school);
///
/// // Selecionar todos
/// selectionState.selectAll(schools);
///
/// // Limpar seleção
/// selectionState.clearSelection();
/// ```
class DSTableSelectionState<T> extends ChangeNotifier {
  final Set<T> _selectedItems = {};

  /// Lista de itens selecionados.
  List<T> get selectedItems => _selectedItems.toList();

  /// Quantidade de itens selecionados.
  int get selectedCount => _selectedItems.length;

  /// Se há pelo menos um item selecionado.
  bool get hasSelection => _selectedItems.isNotEmpty;

  /// Verifica se um item está selecionado.
  bool isSelected(T item) => _selectedItems.contains(item);

  /// Alterna seleção de um item.
  ///
  /// Se o item já está selecionado, remove da seleção.
  /// Caso contrário, adiciona à seleção.
  void toggle(T item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
    } else {
      _selectedItems.add(item);
    }
    notifyListeners();
  }

  /// Seleciona um item específico.
  void select(T item) {
    if (!_selectedItems.contains(item)) {
      _selectedItems.add(item);
      notifyListeners();
    }
  }

  /// Desseléciona um item específico.
  void deselect(T item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
      notifyListeners();
    }
  }

  /// Seleciona todos os itens fornecidos.
  void selectAll(List<T> items) {
    final hadChanges = items.any((item) => !_selectedItems.contains(item));
    _selectedItems.addAll(items);
    if (hadChanges) {
      notifyListeners();
    }
  }

  /// Remove todos os itens selecionados.
  void clearSelection() {
    if (_selectedItems.isNotEmpty) {
      _selectedItems.clear();
      notifyListeners();
    }
  }

  /// Verifica se todos os itens da lista estão selecionados.
  bool areAllSelected(List<T> items) {
    return items.every((item) => _selectedItems.contains(item));
  }

  /// Verifica se alguns (mas não todos) itens estão selecionados.
  bool areSomeSelected(List<T> items) {
    final selectedInList = items.where((item) => _selectedItems.contains(item));
    return selectedInList.isNotEmpty && selectedInList.length < items.length;
  }

  /// Alterna entre selecionar todos e desselecionar todos.
  void toggleAll(List<T> items) {
    if (areAllSelected(items)) {
      // Todos selecionados: desselecionar todos
      for (final item in items) {
        _selectedItems.remove(item);
      }
    } else {
      // Nem todos selecionados: selecionar todos
      _selectedItems.addAll(items);
    }
    notifyListeners();
  }
}
