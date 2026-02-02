import '../enums/notebook_type.dart';

/// DTO para criação de Notebook
///
/// Contém apenas os campos necessários para criar um novo notebook.
/// O [id] é gerado pelo banco de dados e metadados são automáticos.
class NotebookCreate {
  final String title;
  final String content; // Markdown ou texto rico

  // Campos OPCIONAIS
  final String? projectId;
  final String? parentId;
  final List<String>? tags;
  final NotebookType? type;
  final DateTime? reminderDate;
  final bool? notifyOnReminder;
  final List<String>? documentIds; // IDs de documentos a serem anexados

  NotebookCreate({
    required this.title,
    required this.content,
    this.projectId,
    this.parentId,
    this.tags,
    this.type,
    this.reminderDate,
    this.notifyOnReminder,
    this.documentIds,
  });

  /// Validação básica de negócio
  bool get isValid =>
      title.trim().isNotEmpty && content.isNotEmpty && _validateReminder();

  /// Valida campos relacionados a lembretes
  bool _validateReminder() {
    // Se é lembrete, deve ter data de lembrete
    if (type == NotebookType.reminder && reminderDate == null) {
      return false;
    }
    // Se tem data de lembrete, deve ser tipo lembrete
    if (reminderDate != null && type != NotebookType.reminder) {
      return false;
    }
    return true;
  }

  /// Verifica se tem tags
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Verifica se tem documentos para anexar
  bool get hasDocuments => documentIds != null && documentIds!.isNotEmpty;

  @override
  String toString() => 'NotebookCreate(title: $title, type: $type)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotebookCreate &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          content == other.content &&
          projectId == other.projectId &&
          parentId == other.parentId &&
          _listEquals(tags, other.tags) &&
          type == other.type &&
          reminderDate == other.reminderDate &&
          notifyOnReminder == other.notifyOnReminder &&
          _listEquals(documentIds, other.documentIds);

  @override
  int get hashCode => Object.hash(
    title,
    content,
    projectId,
    parentId,
    Object.hashAll(tags ?? []),
    type,
    reminderDate,
    notifyOnReminder,
    Object.hashAll(documentIds ?? []),
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
