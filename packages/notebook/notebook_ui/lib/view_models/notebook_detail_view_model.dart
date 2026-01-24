import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:core_client/core_client.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:notebook_client/notebook_client.dart';

/// ViewModel para gerenciar detalhes e edição de um caderno.
///
/// Segue padrão MVVM + ADR-0001 (Result) + ADR-0002 (DioErrorHandler).
class NotebookDetailViewModel extends ChangeNotifier
    with Loggable, DioErrorHandler {
  final NotebookApiService _notebookService;
  final DocumentReferenceApiService _documentService;

  NotebookDetailViewModel({
    required NotebookApiService notebookService,
    required DocumentReferenceApiService documentService,
  }) : _notebookService = notebookService,
       _documentService = documentService;

  NotebookDetails? _notebook;
  NotebookDetails? get notebook => _notebook;

  List<DocumentReferenceDetails>? _documents;
  List<DocumentReferenceDetails>? get documents => _documents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Carrega detalhes de um caderno.
  Future<void> loadNotebook(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _executeLoadNotebook(id);

    if (result case Success(value: final data)) {
      _notebook = data.toDomain();
      _isLoading = false;
      notifyListeners();

      // Carrega documentos automaticamente
      await loadDocuments(id);
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Result<NotebookDetailsModel>> _executeLoadNotebook(String id) async {
    try {
      final model = await _notebookService.getById(id);
      return Success(model);
    } on DioException catch (e) {
      return handleDioError<NotebookDetailsModel>(e, context: 'loadNotebook');
    }
  }

  /// Carrega lista de documentos de um caderno.
  Future<void> loadDocuments(String notebookId) async {
    final result = await _executeLoadDocuments(notebookId);

    if (result case Success(value: final data)) {
      _documents = data.map((model) => model.toDomain()).toList();
      notifyListeners();
    } else if (result case Failure(error: final error)) {
      logger.warning('Erro ao carregar documentos: $error');
      _documents = [];
      notifyListeners();
    }
  }

  Future<Result<List<DocumentReferenceDetailsModel>>> _executeLoadDocuments(
    String notebookId,
  ) async {
    try {
      final models = await _notebookService.getDocuments(notebookId);
      return Success(models);
    } on DioException catch (e) {
      return handleDioError<List<DocumentReferenceDetailsModel>>(
        e,
        context: 'loadDocuments',
      );
    }
  }

  /// Atualiza um caderno.
  Future<bool> updateNotebook(NotebookUpdate update) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _executeUpdateNotebook(update);

    if (result case Success(value: final data)) {
      _notebook = data.toDomain();
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

  Future<Result<NotebookDetailsModel>> _executeUpdateNotebook(
    NotebookUpdate update,
  ) async {
    try {
      final updateModel = NotebookUpdateModel.fromDomain(update);
      final model = await _notebookService.update(
        _notebook!.id,
        updateModel.toJson(),
      );
      return Success(model);
    } on DioException catch (e) {
      return handleDioError<NotebookDetailsModel>(
        e,
        context: 'updateNotebook',
      );
    }
  }

  /// Deleta um documento.
  Future<bool> deleteDocument(String documentId) async {
    final result = await _executeDeleteDocument(documentId);

    if (result case Success()) {
      _documents?.removeWhere((doc) => doc.id == documentId);
      notifyListeners();
      return true;
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      notifyListeners();
      return false;
    }

    return false;
  }

  Future<Result<void>> _executeDeleteDocument(String documentId) async {
    try {
      await _documentService.delete(documentId);
      return const Success(null);
    } on DioException catch (e) {
      return handleDioError<void>(e, context: 'deleteDocument');
    }
  }

  /// Limpa erro atual.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
