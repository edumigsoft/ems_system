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
  final Dio _dio;

  NotebookDetailViewModel({
    required NotebookApiService notebookService,
    required DocumentReferenceApiService documentService,
    required TagApiService tagService,
    required Dio dio,
  }) : _notebookService = notebookService,
       _documentService = documentService,
       _tagService = tagService,
       _dio = dio;

  NotebookDetails? _notebook;
  NotebookDetails? get notebook => _notebook;

  List<DocumentReferenceDetails>? _documents;
  List<DocumentReferenceDetails>? get documents => _documents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Lista de tags disponíveis.
  List<TagDetails> _availableTags = [];
  List<TagDetails> get availableTags => _availableTags;

  /// Carrega lista de tags disponíveis para autocomplete.
  Future<void> loadAvailableTags({String? searchTerm}) async {
    final result = await _executeLoadTags(searchTerm: searchTerm);

    if (result case Success(value: final data)) {
      _availableTags = data.map((model) => model.toDomain()).toList();
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

  /// Resolve tag IDs para entidades TagDetails.
  List<TagDetails> get notebookTagsWithDetails {
    if (_notebook?.tags == null || _notebook!.tags!.isEmpty) {
      return [];
    }
    return _availableTags
        .where((tag) => _notebook!.tags!.contains(tag.id))
        .toList();
  }

  /// Adiciona uma tag ao notebook atual.
  Future<bool> addTagToNotebook(TagDetails tag) async {
    if (_notebook == null) return false;

    final currentTags = _notebook!.tags ?? [];
    if (currentTags.contains(tag.id)) return true; // Já existe

    final updatedTags = [...currentTags, tag.id];
    final update = NotebookUpdate(
      id: _notebook!.id,
      tags: updatedTags,
    );

    final success = await updateNotebook(update);
    if (success) {
      // Atualiza estado local
      _notebook = _notebook!.copyWith(tags: updatedTags);
      notifyListeners();
    }
    return success;
  }

  /// Remove uma tag do notebook atual.
  Future<bool> removeTagFromNotebook(String tagId) async {
    if (_notebook == null) return false;

    final currentTags = _notebook!.tags ?? [];
    if (!currentTags.contains(tagId)) return true; // Não existe

    final updatedTags = currentTags.where((id) => id != tagId).toList();
    final update = NotebookUpdate(
      id: _notebook!.id,
      tags: updatedTags.isEmpty ? null : updatedTags,
    );

    final success = await updateNotebook(update);
    if (success) {
      // Atualiza estado local
      _notebook = _notebook!.copyWith(tags: updatedTags.isEmpty ? null : updatedTags);
      notifyListeners();
    }
    return success;
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

    final result = await _executeLoadChildren(_notebook!.id);

    if (result case Success(value: final data)) {
      _childNotebooks = data.map((model) => model.toDomain()).toList();
      notifyListeners();
    } else if (result case Failure(error: final error)) {
      logger.warning('Erro ao carregar cadernos filhos: $error');
      _childNotebooks = [];
      notifyListeners();
    }
  }

  Future<Result<List<NotebookDetailsModel>>> _executeLoadChildren(
    String parentId,
  ) async {
    try {
      final models = await _notebookService.getAll(
        parentId: parentId,
      );
      return Success(models);
    } on DioException catch (e) {
      return handleDioError<List<NotebookDetailsModel>>(
        e,
        context: 'loadChildren',
      );
    }
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
  Future<bool> uploadDocument({
    required String filePath,
    required String fileName,
    String? mimeType,
    void Function(double)? onProgress,
  }) async {
    if (_notebook == null) return false;

    _isUploadingDocument = true;
    _uploadProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/notebooks/${_notebook!.id}/documents/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            _uploadProgress = sent / total;
            if (onProgress != null) onProgress(_uploadProgress);
            notifyListeners();
          }
        },
      );

      final model = DocumentReferenceDetailsModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      _documents ??= [];
      _documents!.add(model.toDomain());
      _isUploadingDocument = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return true;
    } catch (e) {
      logger.severe('Erro ao fazer upload de documento', e);
      _error = 'Erro ao fazer upload: $e';
      _isUploadingDocument = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return false;
    }
  }

  /// Dio configurado com base URL e interceptores de auth.
  /// Exposto para widgets que precisam fazer downloads autenticados.
  Dio get dio => _dio;

  /// URL relativa para download de documento no servidor.
  /// Retorna null se o documento não for server-hosted ou notebook não carregado.
  String? getDocumentDownloadUrl(DocumentReferenceDetails document) {
    if (_notebook == null) return null;
    if (document.storageType != DocumentStorageType.server) return null;
    return '/notebooks/${_notebook!.id}/documents/${document.id}/download';
  }

  /// Limpa erro atual.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
