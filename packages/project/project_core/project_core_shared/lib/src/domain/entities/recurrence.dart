// Modelo para recorrência
import '../../value_objects/simple_time.dart';
import '../enums/recurrence_type.dart';

class Recurrence {
  final RecurrenceType type; // daily, weekly, monthly, custom
  final int interval; // A cada X dias/semanas/meses
  final SimpleTime? preferredTime;
  final DateTime? endDate; // Até quando repetir (opcional)

  const Recurrence({
    required this.type,
    this.interval = 1,
    this.preferredTime,
    this.endDate,
  });
}
