import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:core_client/core_client.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:notebook_client/notebook_client.dart';
import 'package:tag_shared/tag_shared.dart' show TagDetails;
import 'package:tag_client/tag_client.dart' show TagApiService;

/// ViewModel para gerenciar lista de cadernos.
///
/// Segue padrão MVVM + ADR-0001 (Result) + ADR-0002 (DioErrorHandler).
class NotebookListViewModel extends ChangeNotifier
    with Loggable, DioErrorHandler {
  final NotebookApiService _notebookService;
  final TagApiService _tagService;

  NotebookListViewModel({
    required NotebookApiService notebookService,
    required TagApiService tagService,
  }) : _notebookService = notebookService,
       _tagService = tagService;

  List<NotebookDetails>? _notebooks;
  List<NotebookDetails>? get notebooks => _notebooks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Tags disponíveis para filtro.
  List<TagDetails> _allAvailableTags = [];
  List<TagDetails> get allAvailableTags => _allAvailableTags;

  /// Alias para compatibilidade com páginas existentes.
  List<TagDetails> get availableTags => _allAvailableTags;

  /// Carrega todas as tags disponíveis.
  Future<void> loadAvailableTags() async {
    try {
      final models = await _tagService.getAll(activeOnly: true);
      _allAvailableTags = models.map((m) => m.toDomain()).toList();
      notifyListeners();
    } catch (e) {
      logger.warning('Erro ao carregar tags: $e');
      _allAvailableTags = [];
    }
  }

  /// Carrega lista de cadernos com filtros server-side.
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
      // Passa filtro de tags para o servidor (comma-separated IDs)
      final tagsParam = _selectedTags.isNotEmpty
          ? _selectedTags.map((tag) => tag.id).join(',')
          : null;

      // Passa filtro de tipo (enum name)
      final typeParam = _selectedTypes.isNotEmpty
          ? _selectedTypes.first.name
          : null;

      final models = await _notebookService.getAll(
        tags: tagsParam,
        type: typeParam,
      );
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

  final Set<TagDetails> _selectedTags = {};
  Set<TagDetails> get selectedTags => _selectedTags;

  NotebookSortOrder _sortOrder = NotebookSortOrder.recentFirst;
  NotebookSortOrder get sortOrder => _sortOrder;

  /// Lista filtrada de cadernos baseado nos critérios ativos.
  ///
  /// **Nota:** Filtro por tags agora é server-side via `loadNotebooks()`.
  /// Filtros de busca (texto) e ordenação ainda são client-side.
  List<NotebookDetails> get filteredNotebooks {
    if (_notebooks == null) return [];

    var filtered = _notebooks!;

    // Filtro por busca (título ou conteúdo) - CLIENT-SIDE
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((notebook) {
        final matchesTitle = notebook.title.toLowerCase().contains(query);
        final matchesContent = notebook.content.toLowerCase().contains(query);
        return matchesTitle || matchesContent;
      }).toList();
    }

    // Ordenação - CLIENT-SIDE
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

  /// Toggle de filtro por tipo (recarrega dados do servidor).
  void toggleTypeFilter(NotebookType type) {
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
    } else {
      _selectedTypes.clear(); // API suporta apenas 1 tipo
      _selectedTypes.add(type);
    }
    loadNotebooks(); // Recarrega com novo filtro
  }

  /// Toggle de filtro por tag (recarrega dados do servidor).
  void toggleTagFilter(TagDetails tag) {
    if (_selectedTags.any((t) => t.id == tag.id)) {
      _selectedTags.removeWhere((t) => t.id == tag.id);
    } else {
      _selectedTags.add(tag);
    }
    loadNotebooks(); // Recarrega com novo filtro server-side
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
    loadNotebooks(); // Recarrega sem filtros
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
