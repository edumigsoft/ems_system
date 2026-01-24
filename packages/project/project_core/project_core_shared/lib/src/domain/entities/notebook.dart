import '../enums/notebook_type.dart';
import 'document_reference.dart';

class Notebook {
  final String id;
  final String title;
  final String content; // Markdown ou texto rico (resumo/anotações)
  final DateTime createdAt;

  // Campos OPCIONAIS
  final String? projectId; // Vinculação com projeto
  final String? parentId; // Para hierarquia (subpáginas)
  final List<String>? tags;
  final NotebookType? type; // quick, organized, reminder
  final DateTime? reminderDate; // Para tipo "reminder"
  final bool? notifyOnReminder;
  final DateTime? updatedAt;

  // NOVO: Documentos anexados/referenciados
  final List<DocumentReference>? documents;

  const Notebook({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.projectId,
    this.parentId,
    this.tags,
    this.type,
    this.reminderDate,
    this.notifyOnReminder,
    this.updatedAt,
    this.documents,
  });

  /// Verifica se é uma nota rápida
  bool get isQuickNote => type == NotebookType.quick;

  /// Verifica se é um lembrete
  bool get isReminder => type == NotebookType.reminder;

  /// Verifica se tem subpáginas (é pai)
  bool get hasChildren => parentId == null;

  /// Verifica se tem documentos anexados
  bool get hasDocuments => documents != null && documents!.isNotEmpty;
}
