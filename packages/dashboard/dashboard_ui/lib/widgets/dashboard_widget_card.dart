import 'package:core_ui/core_ui.dart' show DashboardWidgetEntry;
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';

/// Card container padrão para cada DashboardWidgetEntry.
///
/// Usa DSCard + DSCardHeader com o título e ícone da entry.
class DashboardWidgetCard extends StatelessWidget {
  final DashboardWidgetEntry entry;

  const DashboardWidgetCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DSCardHeader(
            title: entry.title,
            showSearch: false,
            actionButton: Icon(
              entry.icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: entry.build(context),
          ),
        ],
      ),
    );
  }
}
