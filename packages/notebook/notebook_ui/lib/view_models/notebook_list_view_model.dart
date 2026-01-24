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

  /// Limpa erro atual.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
