import 'package:core_ui/core_ui.dart'
    show DashboardRegistry, DashboardWidgetEntry;
import 'package:flutter/material.dart';

/// ViewModel para o DashboardPage.
///
/// Fornece a lista de DashboardWidgetEntry registradas no DashboardRegistry.
class DashboardViewModel extends ChangeNotifier {
  final DashboardRegistry _registry;

  DashboardViewModel({required DashboardRegistry registry})
    : _registry = registry;

  List<DashboardWidgetEntry> get entries => _registry.entries;
}
