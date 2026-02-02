import '../enums/notebook_type.dart';

/// DTO para atualização de Notebook
///
/// Contém [id] obrigatório e campos opcionais para atualização parcial.
/// Inclui [isActive] e [isDeleted] para controle de estado.
class NotebookUpdate {
  final String id; // Obrigatório - identifica qual registro atualizar

  // Campos de negócio opcionais
  final String? title;
  final String? content;
  final String? projectId;
  final String? parentId;
  final List<String>? tags;
  final NotebookType? type;
  final DateTime? reminderDate;
  final bool? notifyOnReminder;
  final List<String>? documentIds;

  // Campos de BaseDetails para controle
  final bool? isActive; // Permite ativar/desativar
  final bool? isDeleted; // Permite soft delete

  NotebookUpdate({
    required this.id,
    this.title,
    this.content,
    this.projectId,
    this.parentId,
    this.tags,
    this.type,
    this.reminderDate,
    this.notifyOnReminder,
    this.documentIds,
    this.isActive,
    this.isDeleted,
  });

  /// Verifica se há alguma mudança
  bool get hasChanges =>
      title != null ||
      content != null ||
      projectId != null ||
      parentId != null ||
      tags != null ||
      type != null ||
      reminderDate != null ||
      notifyOnReminder != null ||
      documentIds != null ||
      isActive != null ||
      isDeleted != null;

  /// Verifica se está sendo desativado
  bool get isBeingDeactivated => isActive == false;

  /// Verifica se está sendo ativado
  bool get isBeingActivated => isActive == true;

  /// Verifica se está sendo deletado (soft delete)
  bool get isBeingDeleted => isDeleted == true;

  /// Verifica se está sendo restaurado
  bool get isBeingRestored => isDeleted == false;

  @override
  String toString() => 'NotebookUpdate(id: $id, hasChanges: $hasChanges)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotebookUpdate &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          projectId == other.projectId &&
          parentId == other.parentId &&
          _listEquals(tags, other.tags) &&
          type == other.type &&
          reminderDate == other.reminderDate &&
          notifyOnReminder == other.notifyOnReminder &&
          _listEquals(documentIds, other.documentIds) &&
          isActive == other.isActive &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    content,
    projectId,
    parentId,
    Object.hashAll(tags ?? []),
    type,
    reminderDate,
    notifyOnReminder,
    Object.hashAll(documentIds ?? []),
    isActive,
    isDeleted,
  );

  /// Helper para comparação de listas
  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
