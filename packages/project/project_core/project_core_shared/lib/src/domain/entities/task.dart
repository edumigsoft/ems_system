import '../enums/recurrence_type.dart';

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

// Modelo para recorrência
class Recurrence {
  final RecurrenceType type; // daily, weekly, monthly, custom
  final int interval; // A cada X dias/semanas/meses
  final TimeOfDay? preferredTime;
  final DateTime? endDate; // Até quando repetir (opcional)

  const Recurrence({
    required this.type,
    this.interval = 1,
    this.preferredTime,
    this.endDate,
  });
}
