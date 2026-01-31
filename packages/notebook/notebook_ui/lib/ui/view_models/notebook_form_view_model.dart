import 'package:flutter/foundation.dart';
import 'package:core_shared/core_shared.dart' show Result, Success, Failure;
import 'package:core_ui/core_ui.dart' show FormValidationMixin;
import 'package:notebook_shared/notebook_shared.dart';

/// ViewModel para formulário de criação/edição de notebooks.
///
/// Utiliza [FormValidationMixin] para gerenciamento de estado de formulários.
///
/// **Nota:** Este ViewModel não integra com UseCases (ainda não existem).
/// Ele apenas gerencia o estado do formulário e fornece dados validados.
class NotebookFormViewModel extends ChangeNotifier with FormValidationMixin {
  final NotebookDetails? _initialData;
  NotebookType _selectedType = NotebookType.organized;

  /// Indica se é modo de edição (true) ou criação (false).
  bool get isEditing => _initialData != null;

  /// Tipo de notebook selecionado
  NotebookType get selectedType => _selectedType;

  set selectedType(NotebookType value) {
    if (_selectedType != value) {
      _selectedType = value;
      notifyListeners();
    }
  }

  NotebookFormViewModel({
    NotebookDetails? initialData,
  }) : _initialData = initialData {
    _initializeFields();
  }

  /// Inicializa os campos do formulário.
  void _initializeFields() {
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
      registerField(
        notebookTagsField,
        initialValue: data.tags?.join(', ') ?? '',
      );
      _selectedType = data.type ?? NotebookType.organized;
    } else {
      // Modo criação - campos vazios
      registerField(notebookTitleField);
      registerField(notebookContentField);
      registerField(notebookTagsField);
    }
  }

  /// Coleta dados atuais do formulário.
  Map<String, dynamic> _getFormData() {
    return {
      notebookTitleField: getFieldValue(notebookTitleField),
      notebookContentField: getFieldValue(notebookContentField),
      notebookTagsField: getFieldValue(notebookTagsField),
    };
  }

  /// Converte string de tags separadas por vírgula em lista.
  List<String>? _parseTags(String tagsText) {
    if (tagsText.trim().isEmpty) return null;
    return tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
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
      tags: _parseTags(getFieldValue(notebookTagsField)),
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
      tags: _parseTags(getFieldValue(notebookTagsField)),
    );
  }

  /// Reseta o formulário para valores iniciais.
  void reset() {
    final data = _initialData;
    if (data != null) {
      resetForm({
        notebookTitleField: data.title,
        notebookContentField: data.content,
        notebookTagsField: data.tags?.join(', ') ?? '',
      });
      _selectedType = data.type ?? NotebookType.organized;
    } else {
      resetForm();
      _selectedType = NotebookType.organized;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    disposeFormResources();
    super.dispose();
  }
}
