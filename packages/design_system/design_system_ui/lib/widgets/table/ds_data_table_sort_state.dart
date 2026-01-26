import 'package:flutter/foundation.dart';

/// Estado de ordenação para tabelas.
///
/// Gerencia qual coluna está atualmente ordenada e em qual direção
/// (ascendente ou descendente). Usa [ChangeNotifier] para notificar
/// listeners sobre mudanças.
///
/// **Exemplo de uso:**
/// ```dart
/// final sortState = DSDataTableSortState();
///
/// sortState.addListener(() {
///   setState(() {
///     // Reordenar dados
///   });
/// });
///
/// // Quando usuário clica em uma coluna
/// sortState.sort(columnIndex);
/// ```
class DSDataTableSortState extends ChangeNotifier {
  int? _sortColumnIndex;
  bool _sortAscending = true;

  /// Índice da coluna atualmente ordenada (null se nenhuma).
  int? get sortColumnIndex => _sortColumnIndex;

  /// Se a ordenação é ascendente (true) ou descendente (false).
  bool get sortAscending => _sortAscending;

  /// Se há uma coluna ordenada atualmente.
  bool get isSorted => _sortColumnIndex != null;

  /// Ordena por uma coluna específica.
  ///
  /// Se a coluna já está ordenada, inverte a direção.
  /// Se é uma nova coluna, ordena em ordem ascendente.
  void sort(int columnIndex) {
    if (_sortColumnIndex == columnIndex) {
      // Mesma coluna: inverte direção
      _sortAscending = !_sortAscending;
    } else {
      // Nova coluna: ordena ascendente
      _sortColumnIndex = columnIndex;
      _sortAscending = true;
    }
    notifyListeners();
  }

  /// Define a ordenação de forma programática.
  ///
  /// Útil para restaurar estado ou aplicar ordenação inicial.
  void setSortState({
    required int? columnIndex,
    required bool ascending,
  }) {
    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;
    notifyListeners();
  }

  /// Remove a ordenação atual.
  void clearSort() {
    _sortColumnIndex = null;
    _sortAscending = true;
    notifyListeners();
  }

  /// Alterna entre ascendente/descendente para a coluna atual.
  ///
  /// Se não há coluna ordenada, não faz nada.
  void toggleDirection() {
    if (_sortColumnIndex != null) {
      _sortAscending = !_sortAscending;
      notifyListeners();
    }
  }
}
