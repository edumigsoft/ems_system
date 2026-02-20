import 'package:core_ui/core_ui.dart' show DashboardWidgetEntry;
import 'package:flutter/material.dart';

/// Card container padrão para cada DashboardWidgetEntry.
///
/// Usa Card nativo (não DSCard) para evitar aninhamento com DSCardHeader,
/// que já embute seu próprio DSCard internamente.
class DashboardWidgetCard extends StatelessWidget {
  final DashboardWidgetEntry entry;

  const DashboardWidgetCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header inline — sem DSCardHeader para evitar DSCard aninhado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(entry.icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Conteúdo da entry
          Padding(
            padding: const EdgeInsets.all(12),
            child: entry.build(context),
          ),
        ],
      ),
    );
  }
}
