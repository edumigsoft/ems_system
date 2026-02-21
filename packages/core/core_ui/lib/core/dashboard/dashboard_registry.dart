import 'dashboard_widget_entry.dart';

/// Registry centralizado de widgets do dashboard.
///
/// Cada módulo de feature registra suas DashboardWidgetEntry
/// durante a inicialização da DI. O DashboardPage lê as entries
/// registradas para montar seu layout responsivo.
class DashboardRegistry {
  final List<DashboardWidgetEntry> _entries = [];

  /// Registra uma nova entry no dashboard.
  void register(DashboardWidgetEntry entry) => _entries.add(entry);

  /// Retorna a lista imutável de entries registradas.
  List<DashboardWidgetEntry> get entries => List.unmodifiable(_entries);
}
