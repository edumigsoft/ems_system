import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:core_client/core_client.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:notebook_client/notebook_client.dart';

/// ViewModel para gerenciar criação de cadernos.
///
/// Segue padrão MVVM + ADR-0001 (Result) + ADR-0002 (DioErrorHandler).
class NotebookCreateViewModel extends ChangeNotifier
    with Loggable, DioErrorHandler {
  final NotebookApiService _notebookService;

  NotebookCreateViewModel({required NotebookApiService notebookService})
    : _notebookService = notebookService;

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  String? _error;
  String? get error => _error;

  NotebookDetails? _createdNotebook;
  NotebookDetails? get createdNotebook => _createdNotebook;

  /// Cria um novo caderno completo.
  Future<bool> createNotebook(NotebookCreate data) async {
    _isCreating = true;
    _error = null;
    _createdNotebook = null;
    notifyListeners();

    final result = await _executeCreateNotebook(data);

    if (result case Success(value: final notebook)) {
      _createdNotebook = notebook.toDomain();
      _isCreating = false;
      notifyListeners();
      return true;
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isCreating = false;
      notifyListeners();
      return false;
    }

    return false;
  }

  Future<Result<NotebookDetailsModel>> _executeCreateNotebook(
    NotebookCreate data,
  ) async {
    try {
      final createModel = NotebookCreateModel.fromDomain(data);
      final model = await _notebookService.create(createModel.toJson());
      return Success(model);
    } on DioException catch (e) {
      return handleDioError<NotebookDetailsModel>(
        e,
        context: 'createNotebook',
      );
    }
  }

  /// Cria uma nota rápida (apenas conteúdo texto).
  Future<bool> createQuickNote({
    required String title,
    required String content,
  }) async {
    final data = NotebookCreate(
      title: title,
      content: content,
      type: NotebookType.quick,
    );
    return await createNotebook(data);
  }

  /// Cria um caderno organizado (com tags e projeto opcional).
  Future<bool> createOrganized({
    required String title,
    required String content,
    List<String>? tags,
    String? projectId,
  }) async {
    final data = NotebookCreate(
      title: title,
      content: content,
      type: NotebookType.organized,
      tags: tags,
      projectId: projectId,
    );
    return await createNotebook(data);
  }

  /// Cria um lembrete (com data/hora programada).
  Future<bool> createReminder({
    required String title,
    required String content,
    required DateTime reminderDate,
    bool notifyOnReminder = true,
  }) async {
    final data = NotebookCreate(
      title: title,
      content: content,
      type: NotebookType.reminder,
      reminderDate: reminderDate,
      notifyOnReminder: notifyOnReminder,
    );
    return await createNotebook(data);
  }

  /// Limpa erro atual.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reseta o estado para criar um novo caderno.
  void reset() {
    _createdNotebook = null;
    _error = null;
    _isCreating = false;
    notifyListeners();
  }
}
