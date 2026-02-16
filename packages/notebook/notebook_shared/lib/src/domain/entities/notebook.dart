import '../enums/notebook_type.dart';

/// Entity de domínio pura para Notebook
///
/// Representa os conceitos de negócio de um notebook (caderno/anotação).
/// NÃO contém campos de persistência (id, createdAt, etc) - esses estão em [NotebookDetails].
class Notebook {
  final String title;
  final String content; // Markdown ou texto rico (resumo/anotações)

  // Campos OPCIONAIS de negócio
  final String? projectId; // Vinculação com projeto
  final String? parentId; // Para hierarquia (subpáginas)
  final List<String>? tags;
  final NotebookType? type; // quick, organized, reminder
  final DateTime? reminderDate; // Para tipo "reminder"
  final bool? notifyOnReminder;

  const Notebook({
    required this.title,
    required this.content,
    this.projectId,
    this.parentId,
    this.tags,
    this.type,
    this.reminderDate,
    this.notifyOnReminder,
  });

  /// Verifica se é uma nota rápida
  bool get isQuickNote => type == NotebookType.quick;

  /// Verifica se é um lembrete
  bool get isReminder => type == NotebookType.reminder;

  /// Verifica se é uma nota organizada
  bool get isOrganized => type == NotebookType.organized;

  /// Verifica se tem subpáginas (é pai)
  bool get hasChildren => parentId == null;

  /// Verifica se está vinculado a um projeto
  bool get hasProject => projectId != null;

  /// Verifica se tem tags
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Verifica se tem lembrete configurado
  bool get hasReminder => reminderDate != null;

  /// Verifica se o lembrete está no passado (atrasado)
  bool get isReminderOverdue {
    if (reminderDate == null) return false;
    return reminderDate!.isBefore(DateTime.now());
  }

  /// Verifica se o título está vazio
  bool get hasValidTitle => title.trim().isNotEmpty;

  /// Nome para exibição (formatado)
  String get displayName => title.trim();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notebook &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          content == other.content &&
          projectId == other.projectId &&
          parentId == other.parentId &&
          _listEquals(tags, other.tags) &&
          type == other.type &&
          reminderDate == other.reminderDate &&
          notifyOnReminder == other.notifyOnReminder;

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
  );

  @override
  String toString() => 'Notebook(title: $title, type: $type)';

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
