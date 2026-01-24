import '../enums/task_priority.dart';
import '../enums/task_status.dart';
import 'recurrence.dart';

class Task {
  final String id;
  final String title;
  final DateTime createdAt;

  // Campos OPCIONAIS
  final String? projectId; // Vinculação com projeto
  final String? notebookId; // Vinculação com caderno
  final String? description;
  final DateTime? dueDate;
  final TaskPriority? priority;
  final TaskStatus? status;
  final List<String>? categories;
  final Recurrence? recurrence; // Para tarefas recorrentes
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.projectId,
    this.notebookId,
    this.description,
    this.dueDate,
    this.priority,
    this.status,
    this.categories,
    this.recurrence,
    this.completedAt,
  });

  /// Verifica se é uma tarefa "rápida" (mínimo de campos)
  bool get isQuick =>
      projectId == null && priority == null && categories == null;

  /// Verifica se é recorrente
  bool get isRecurring => recurrence != null;

  /// Verifica se está concluída
  bool get isCompleted => completedAt != null;
}
