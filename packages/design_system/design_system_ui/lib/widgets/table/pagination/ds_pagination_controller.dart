import 'package:flutter/foundation.dart';

/// Controlador genérico de paginação.
///
/// Gerencia o estado da paginação para uma lista de itens, incluindo:
/// - Página atual
/// - Itens por página (configurável dinamicamente)
/// - Navegação entre páginas
/// - Cálculo de itens visíveis
///
/// Estende [ChangeNotifier] para notificar ouvintes quando o estado muda.
///
/// **Exemplo de uso:**
/// ```dart
/// final controller = DSPaginationController<School>(
///   allItems: schools,
///   itemsPerPage: 10,
/// );
///
/// // Em um StatefulWidget
/// controller.addListener(() => setState(() {}));
///
/// // Usar currentItems na tabela
/// DSDataTable(data: controller.currentItems, ...);
///
/// // Mudar itens por página
/// controller.setItemsPerPage(20);
/// ```
class DSPaginationController<T> extends ChangeNotifier {
  /// Lista completa de todos os itens.
  final List<T> allItems;

  int _itemsPerPage;
  int _currentPage = 1;

  DSPaginationController({
    required this.allItems,
    int itemsPerPage = 10,
  }) : _itemsPerPage = itemsPerPage;

  // Getters calculados

  /// Página atual (1-indexed).
  int get currentPage => _currentPage;

  /// Quantidade de itens por página.
  int get itemsPerPage => _itemsPerPage;

  /// Total de páginas calculado.
  int get totalPages => (allItems.length / _itemsPerPage).ceil();

  /// Total de itens na lista completa.
  int get totalItems => allItems.length;

  /// Se existe uma página anterior.
  bool get hasPreviousPage => _currentPage > 1;

  /// Se existe uma próxima página.
  bool get hasNextPage => _currentPage < totalPages;

  /// Itens da página atual.
  List<T> get currentItems {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, allItems.length);
    return allItems.sublist(startIndex, endIndex);
  }

  // Métodos públicos

  /// Define a quantidade de itens por página.
  ///
  /// Recalcula a página atual se necessário para garantir que permanece
  /// dentro do intervalo válido.
  void setItemsPerPage(int value) {
    if (value > 0 && value != _itemsPerPage) {
      _itemsPerPage = value;

      // Ajusta a página atual se ficou fora do range
      if (_currentPage > totalPages) {
        _currentPage = totalPages.clamp(1, totalPages);
      }

      notifyListeners();
    }
  }

  /// Navega para a página anterior (se existir).
  void previousPage() {
    if (hasPreviousPage) {
      _currentPage--;
      notifyListeners();
    }
  }

  /// Navega para a próxima página (se existir).
  void nextPage() {
    if (hasNextPage) {
      _currentPage++;
      notifyListeners();
    }
  }

  /// Vai diretamente para uma página específica.
  ///
  /// A página deve estar no intervalo [1, totalPages].
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  /// Reseta para a primeira página.
  void reset() {
    _currentPage = 1;
    notifyListeners();
  }
}
