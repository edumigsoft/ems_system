import 'package:flutter/foundation.dart';
import 'package:core_shared/core_shared.dart' show Result, Success, Failure;
import 'package:core_ui/core_ui.dart' show FormValidationMixin;
import 'package:notebook_shared/notebook_shared.dart';
import 'package:tag_shared/tag_shared.dart' show TagDetails;
import 'package:tag_client/tag_client.dart' show TagApiService;

/// ViewModel para formulário de criação/edição de notebooks.
///
/// Utiliza [FormValidationMixin] para gerenciamento de estado de formulários.
///
/// **Nota:** Este ViewModel não integra com UseCases (ainda não existem).
/// Ele apenas gerencia o estado do formulário e fornece dados validados.
class NotebookFormViewModel extends ChangeNotifier with FormValidationMixin {
  final NotebookDetails? _initialData;
  final TagApiService _tagService;

  NotebookType _selectedType = NotebookType.organized;
  List<TagDetails> _selectedTags = [];
  List<TagDetails> _availableTags = [];
  bool _isLoadingTags = false;

  /// Indica se é modo de edição (true) ou criação (false).
  bool get isEditing => _initialData != null;

  /// Tipo de notebook selecionado
  NotebookType get selectedType => _selectedType;

  /// Tags selecionadas
  List<TagDetails> get selectedTags => List.unmodifiable(_selectedTags);

  /// Tags disponíveis
  List<TagDetails> get availableTags => List.unmodifiable(_availableTags);

  /// Indica se está carregando tags
  bool get isLoadingTags => _isLoadingTags;

  set selectedType(NotebookType value) {
    if (_selectedType != value) {
      _selectedType = value;
      notifyListeners();
    }
  }

  NotebookFormViewModel({
    NotebookDetails? initialData,
    required TagApiService tagService,
  })  : _initialData = initialData,
        _tagService = tagService {
    _initializeFieldsSync();
  }

  /// Inicializa os campos do formulário de forma síncrona.
  void _initializeFieldsSync() {
    final data = _initialData;
    if (data != null) {
      // Modo edição - preenche com dados existentes
      registerField(
        notebookTitleField,
        initialValue: data.title,
      );
      registerField(
        notebookContentField,
        initialValue: data.content,
      );
      _selectedType = data.type ?? NotebookType.organized;
    } else {
      // Modo criação - campos vazios
      registerField(notebookTitleField);
      registerField(notebookContentField);
    }
  }

  /// Inicializa tags e dados assíncronos.
  ///
  /// **IMPORTANTE:** Deve ser chamado após a construção do ViewModel.
  Future<void> initialize() async {
    await loadAvailableTags();

    // Carrega tags selecionadas (modo edição)
    final data = _initialData;
    if (data != null && data.tags != null && data.tags!.isNotEmpty) {
      await _loadTagDetailsFromIds(data.tags!);
    }
  }

  /// Carrega detalhes das tags a partir de IDs.
  Future<void> _loadTagDetailsFromIds(List<String> tagIds) async {
    try {
      final allTagsModels = await _tagService.getAll();
      final allTags = allTagsModels.map((model) => model.toDomain()).toList();
      _selectedTags = allTags
          .where((tag) => tagIds.contains(tag.id))
          .toList();
      notifyListeners();
    } catch (_) {
      // Silenciosamente ignora erro (tags não críticas)
    }
  }

  /// Carrega todas as tags disponíveis.
  Future<void> loadAvailableTags() async {
    _isLoadingTags = true;
    notifyListeners();

    try {
      final tagsModels = await _tagService.getAll(activeOnly: true);
      _availableTags = tagsModels.map((model) => model.toDomain()).toList();
    } catch (_) {
      _availableTags = [];
    } finally {
      _isLoadingTags = false;
      notifyListeners();
    }
  }

  /// Define as tags selecionadas.
  void setTags(List<TagDetails> tags) {
    _selectedTags = tags;
    notifyListeners();
  }

  /// Adiciona uma tag à seleção.
  void addTag(TagDetails tag) {
    if (!_selectedTags.any((t) => t.id == tag.id)) {
      _selectedTags.add(tag);
      notifyListeners();
    }
  }

  /// Remove uma tag da seleção.
  void removeTag(String tagId) {
    _selectedTags.removeWhere((tag) => tag.id == tagId);
    notifyListeners();
  }

  /// Coleta dados atuais do formulário.
  Map<String, dynamic> _getFormData() {
    return {
      notebookTitleField: getFieldValue(notebookTitleField),
      notebookContentField: getFieldValue(notebookContentField),
    };
  }

  /// Valida o formulário e retorna os dados.
  ///
  /// Retorna [Success] com dados validados ou [Failure] com erros.
  Future<Result<Map<String, dynamic>>> validateAndGetData() async {
    final formData = _getFormData();

    return submitForm<Map<String, dynamic>>(
      data: formData,
      schema: NotebookValidator.schema,
      onValid: (validatedData) async {
        return Success(validatedData);
      },
    );
  }

  /// Cria objeto [NotebookCreate] com dados validados.
  ///
  /// **Importante:** Chame [validateAndGetData] antes para garantir validação.
  NotebookCreate createNotebookCreate() {
    return NotebookCreate(
      title: getFieldValue(notebookTitleField).trim(),
      content: getFieldValue(notebookContentField).trim(),
      type: _selectedType,
      tags: _selectedTags.isNotEmpty
          ? _selectedTags.map((t) => t.id).toList()
          : null,
    );
  }

  /// Cria objeto [NotebookUpdate] com dados validados.
  ///
  /// **Importante:** Chame [validateAndGetData] antes para garantir validação.
  /// Requer que [isEditing] seja true.
  NotebookUpdate createNotebookUpdate() {
    if (!isEditing) {
      throw StateError('Cannot create NotebookUpdate in creation mode');
    }

    return NotebookUpdate(
      id: _initialData!.id,
      title: getFieldValue(notebookTitleField).trim(),
      content: getFieldValue(notebookContentField).trim(),
      type: _selectedType,
      tags: _selectedTags.isNotEmpty
          ? _selectedTags.map((t) => t.id).toList()
          : null,
    );
  }

  /// Reseta o formulário para valores iniciais.
  void reset() {
    final data = _initialData;
    if (data != null) {
      resetForm({
        notebookTitleField: data.title,
        notebookContentField: data.content,
      });
      _selectedType = data.type ?? NotebookType.organized;
      _selectedTags = [];
      if (data.tags != null && data.tags!.isNotEmpty) {
        _loadTagDetailsFromIds(data.tags!);
      }
    } else {
      resetForm();
      _selectedType = NotebookType.organized;
      _selectedTags = [];
    }
    notifyListeners();
  }

  @override
  void dispose() {
    disposeFormResources();
    super.dispose();
  }
}
