import 'package:core_shared/core_shared.dart' show Success, Failure;
import 'package:flutter/foundation.dart';
import 'package:tag_shared/tag_shared.dart';

/// ViewModel for tag management using MVVM pattern.
///
/// Manages state and business logic for tag operations.
/// Uses Result Pattern for explicit error handling.
class TagViewModel extends ChangeNotifier {
  final GetAllTagsUseCase _getAllUseCase;
  final CreateTagUseCase _createUseCase;
  final UpdateTagUseCase _updateUseCase;
  final DeleteTagUseCase _deleteUseCase;

  List<TagDetails> _tags = [];
  String? _errorMessage;
  bool _isLoading = false;
  String _searchQuery = '';
  bool _activeOnly = true;

  /// All tags currently loaded.
  List<TagDetails> get tags => _tags;

  /// Current error message, if any.
  String? get errorMessage => _errorMessage;

  /// Whether an operation is in progress.
  bool get isLoading => _isLoading;

  /// Current search query.
  String get searchQuery => _searchQuery;

  /// Whether to show only active tags.
  bool get activeOnly => _activeOnly;

  /// Filtered tags based on search and active status.
  List<TagDetails> get filteredTags {
    return _tags.where((tag) {
      final matchesSearch = _searchQuery.isEmpty ||
          tag.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesActive = !_activeOnly || (tag.isActive && !tag.isDeleted);
      return matchesSearch && matchesActive;
    }).toList();
  }

  TagViewModel(
    this._getAllUseCase,
    this._createUseCase,
    this._updateUseCase,
    this._deleteUseCase,
  );

  /// Loads all tags from the repository.
  Future<void> loadTags() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getAllUseCase(
      activeOnly: _activeOnly,
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );

    switch (result) {
      case Success<List<TagDetails>>(:final value):
        _tags = value;
        _errorMessage = null;
      case Failure<List<TagDetails>>(:final error):
        _errorMessage = 'Erro ao carregar tags: ${error.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Creates a new tag.
  Future<bool> createTag(TagCreate data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _createUseCase(data);

    final success = result.when(
      success: (tag) {
        _tags.add(tag);
        _errorMessage = null;
        return true;
      },
      failure: (error) {
        _errorMessage = 'Erro ao criar tag: ${error.toString()}';
        return false;
      },
    );

    _isLoading = false;
    notifyListeners();

    return success;
  }

  /// Updates an existing tag.
  Future<bool> updateTag(TagUpdate data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _updateUseCase(data);

    final success = result.when(
      success: (updatedTag) {
        final index = _tags.indexWhere((t) => t.id == updatedTag.id);
        if (index != -1) {
          _tags[index] = updatedTag;
        }
        _errorMessage = null;
        return true;
      },
      failure: (error) {
        _errorMessage = 'Erro ao atualizar tag: ${error.toString()}';
        return false;
      },
    );

    _isLoading = false;
    notifyListeners();

    return success;
  }

  /// Deletes a tag (soft delete).
  Future<bool> deleteTag(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _deleteUseCase(id);

    final success = result.when(
      success: (_) {
        _tags.removeWhere((t) => t.id == id);
        _errorMessage = null;
        return true;
      },
      failure: (error) {
        _errorMessage = 'Erro ao deletar tag: ${error.toString()}';
        return false;
      },
    );

    _isLoading = false;
    notifyListeners();

    return success;
  }

  /// Sets the search query and reloads tags.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    loadTags();
  }

  /// Toggles active-only filter and reloads tags.
  void toggleActiveOnly() {
    _activeOnly = !_activeOnly;
    notifyListeners();
    loadTags();
  }

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
