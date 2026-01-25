import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:core_client/core_client.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:notebook_client/notebook_client.dart';
import 'package:tag_client/tag_client.dart';
import 'package:tag_shared/tag_shared.dart';

/// ViewModel para gerenciar detalhes e edição de um caderno.
///
/// Segue padrão MVVM + ADR-0001 (Result) + ADR-0002 (DioErrorHandler).
class NotebookDetailViewModel extends ChangeNotifier
    with Loggable, DioErrorHandler {
  final NotebookApiService _notebookService;
  final DocumentReferenceApiService _documentService;
  final TagApiService _tagService;

  NotebookDetailViewModel({
    required NotebookApiService notebookService,
    required DocumentReferenceApiService documentService,
    required TagApiService tagService,
  }) : _notebookService = notebookService,
       _documentService = documentService,
       _tagService = tagService;

  NotebookDetails? _notebook;
  NotebookDetails? get notebook => _notebook;

  List<DocumentReferenceDetails>? _documents;
  List<DocumentReferenceDetails>? get documents => _documents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Lista de tags disponíveis.
  List<String> _availableTags = [];
  List<String> get availableTags => _availableTags;

  /// Carrega lista de tags disponíveis para autocomplete.
  Future<void> loadAvailableTags({String? searchTerm}) async {
    final result = await _executeLoadTags(searchTerm: searchTerm);

    if (result case Success(value: final data)) {
      _availableTags = data.map((model) => model.toDomain().name).toList();
      notifyListeners();
    } else if (result case Failure(error: final error)) {
      logger.warning('Erro ao carregar tags: $error');
      _availableTags = [];
      notifyListeners();
    }
  }

  Future<Result<List<TagDetailsModel>>> _executeLoadTags({
    String? searchTerm,
  }) async {
    try {
      final models = await _tagService.getAll(
        activeOnly: true,
        search: searchTerm,
      );
      return Success(models);
    } on DioException catch (e) {
      return handleDioError<List<TagDetailsModel>>(
        e,
        context: 'loadAvailableTags',
      );
    }
  }

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

  // === Hierarquia (Pai/Filhos) ===

  NotebookDetails? _parentNotebook;
  NotebookDetails? get parentNotebook => _parentNotebook;

  List<NotebookDetails>? _childNotebooks;
  List<NotebookDetails>? get childNotebooks => _childNotebooks;

  /// Carrega caderno pai (se existir).
  Future<void> loadParent() async {
    if (_notebook?.parentId == null) {
      _parentNotebook = null;
      return;
    }

    final result = await _executeLoadNotebook(_notebook!.parentId!);

    if (result case Success(value: final data)) {
      _parentNotebook = data.toDomain();
      notifyListeners();
    }
  }

  /// Carrega cadernos filhos (subpáginas).
  Future<void> loadChildren() async {
    if (_notebook == null) return;

    // TODO: Implementar endpoint no backend para buscar filhos por parentId
    // Por enquanto, não faz nada
    _childNotebooks = [];
    notifyListeners();
  }

  // === Upload de Documentos ===

  bool _isUploadingDocument = false;
  bool get isUploadingDocument => _isUploadingDocument;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  /// Adiciona referência de documento (URL ou caminho local).
  Future<bool> addDocumentReference({
    required String name,
    required String path,
    required DocumentStorageType storageType,
    String? mimeType,
  }) async {
    if (_notebook == null) return false;

    final reference = DocumentReferenceCreate(
      notebookId: _notebook!.id,
      name: name,
      path: path,
      storageType: storageType,
      mimeType: mimeType,
    );

    final result = await _executeAddDocumentReference(reference);

    if (result case Success(value: final data)) {
      _documents ??= [];
      _documents!.add(data.toDomain());
      notifyListeners();
      return true;
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      notifyListeners();
      return false;
    }

    return false;
  }

  Future<Result<DocumentReferenceDetailsModel>> _executeAddDocumentReference(
    DocumentReferenceCreate reference,
  ) async {
    try {
      final createModel = DocumentReferenceCreateModel.fromDomain(reference);
      final model = await _documentService.create(createModel.toJson());
      return Success(model);
    } on DioException catch (e) {
      return handleDioError<DocumentReferenceDetailsModel>(
        e,
        context: 'addDocumentReference',
      );
    }
  }

  /// Upload de arquivo para o servidor.
  ///
  /// Nota: Requer implementação de multipart/form-data no backend.
  Future<bool> uploadDocument({
    required String filePath,
    required String fileName,
    String? mimeType,
    void Function(double)? onProgress,
  }) async {
    if (_notebook == null) return false;

    _isUploadingDocument = true;
    _uploadProgress = 0.0;
    notifyListeners();

    // TODO: Implementar upload real quando backend suportar
    // Por enquanto, simula upload
    _error = 'Upload de arquivos ainda não implementado no backend';
    _isUploadingDocument = false;
    notifyListeners();
    return false;

    /* Implementação futura:
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
        'notebookId': _notebook!.id,
      });

      final response = await _dio.post(
        '/documents/upload',
        data: formData,
        onSendProgress: (sent, total) {
          _uploadProgress = sent / total;
          if (onProgress != null) onProgress(_uploadProgress);
          notifyListeners();
        },
      );

      final model = DocumentReferenceDetailsModel.fromJson(response.data);
      _documents ??= [];
      _documents!.add(model.toDomain());
      _isUploadingDocument = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao fazer upload: $e';
      _isUploadingDocument = false;
      notifyListeners();
      return false;
    }
    */
  }

  /// Limpa erro atual.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
