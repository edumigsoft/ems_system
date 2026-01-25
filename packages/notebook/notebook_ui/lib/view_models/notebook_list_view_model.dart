import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:core_client/core_client.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:notebook_client/notebook_client.dart';

/// ViewModel para gerenciar lista de cadernos.
///
/// Segue padrão MVVM + ADR-0001 (Result) + ADR-0002 (DioErrorHandler).
class NotebookListViewModel extends ChangeNotifier
    with Loggable, DioErrorHandler {
  final NotebookApiService _notebookService;

  NotebookListViewModel({required NotebookApiService notebookService})
    : _notebookService = notebookService;

  List<NotebookDetails>? _notebooks;
  List<NotebookDetails>? get notebooks => _notebooks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Carrega lista de cadernos.
  Future<void> loadNotebooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _executeLoadNotebooks();

    if (result case Success(value: final data)) {
      _notebooks = data.map((model) => model.toDomain()).toList();
      _isLoading = false;
      notifyListeners();
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Result<List<NotebookDetailsModel>>> _executeLoadNotebooks() async {
    try {
      final models = await _notebookService.getAll();
      return Success(models);
    } on DioException catch (e) {
      return handleDioError<List<NotebookDetailsModel>>(
        e,
        context: 'loadNotebooks',
      );
    }
  }

  /// Deleta um caderno.
  Future<bool> deleteNotebook(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _executeDeleteNotebook(id);

    if (result case Success()) {
      _notebooks?.removeWhere((notebook) => notebook.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }

    return false;
  }

  Future<Result<void>> _executeDeleteNotebook(String id) async {
    try {
      await _notebookService.delete(id);
      return const Success(null);
    } on DioException catch (e) {
      return handleDioError<void>(e, context: 'deleteNotebook');
    }
  }

  // === Filtros e Busca ===

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  final Set<NotebookType> _selectedTypes = {};
  Set<NotebookType> get selectedTypes => _selectedTypes;

  final Set<String> _selectedTags = {};
  Set<String> get selectedTags => _selectedTags;

  NotebookSortOrder _sortOrder = NotebookSortOrder.recentFirst;
  NotebookSortOrder get sortOrder => _sortOrder;

  /// Lista filtrada de cadernos baseado nos critérios ativos.
  List<NotebookDetails> get filteredNotebooks {
    if (_notebooks == null) return [];

    var filtered = _notebooks!;

    // Filtro por busca (título ou conteúdo)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((notebook) {
        final matchesTitle = notebook.title.toLowerCase().contains(query);
        final matchesContent = notebook.content.toLowerCase().contains(query);
        return matchesTitle || matchesContent;
      }).toList();
    }

    // Filtro por tipo
    if (_selectedTypes.isNotEmpty) {
      filtered = filtered.where((notebook) {
        return notebook.type != null && _selectedTypes.contains(notebook.type);
      }).toList();
    }

    // Filtro por tags
    if (_selectedTags.isNotEmpty) {
      filtered = filtered.where((notebook) {
        if (notebook.tags == null || notebook.tags!.isEmpty) return false;
        return _selectedTags.any((tag) => notebook.tags!.contains(tag));
      }).toList();
    }

    // Ordenação
    switch (_sortOrder) {
      case NotebookSortOrder.recentFirst:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NotebookSortOrder.oldestFirst:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NotebookSortOrder.alphabetical:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case NotebookSortOrder.reverseAlphabetical:
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
    }

    return filtered;
  }

  /// Define critério de busca por texto.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Toggle de filtro por tipo.
  void toggleTypeFilter(NotebookType type) {
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
    } else {
      _selectedTypes.add(type);
    }
    notifyListeners();
  }

  /// Toggle de filtro por tag.
  void toggleTagFilter(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  /// Define critério de ordenação.
  void setSortOrder(NotebookSortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  /// Limpa todos os filtros.
  void clearFilters() {
    _searchQuery = '';
    _selectedTypes.clear();
    _selectedTags.clear();
    _sortOrder = NotebookSortOrder.recentFirst;
    notifyListeners();
  }

  /// Obtém todas as tags únicas dos cadernos.
  Set<String> get availableTags {
    if (_notebooks == null) return {};

    final tags = <String>{};
    for (final notebook in _notebooks!) {
      if (notebook.tags != null) {
        tags.addAll(notebook.tags!);
      }
    }
    return tags;
  }

  /// Limpa erro atual.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Critérios de ordenação de cadernos.
enum NotebookSortOrder {
  recentFirst,
  oldestFirst,
  alphabetical,
  reverseAlphabetical,
}
