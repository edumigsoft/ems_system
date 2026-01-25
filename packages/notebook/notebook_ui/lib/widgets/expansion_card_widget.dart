import 'package:flutter/material.dart';

/// Card que sugere adicionar mais informações a um caderno.
///
/// Exibido quando o caderno tem campos opcionais vazios.
/// Pode ser dispensado (dismissed) pelo usuário.
class ExpansionCardWidget extends StatelessWidget {
  final List<String> missingFields;
  final VoidCallback onExpand;
  final VoidCallback? onDismiss;
  final bool dismissible;

  const ExpansionCardWidget({
    super.key,
    required this.missingFields,
    required this.onExpand,
    this.onDismiss,
    this.dismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (missingFields.isEmpty) {
      return const SizedBox.shrink();
    }

    final widget = Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onExpand,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adicionar mais informações',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complete o caderno adicionando:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (dismissible && onDismiss != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: onDismiss,
                      tooltip: 'Dispensar',
                      color: colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: missingFields.map((field) {
                  return Chip(
                    label: Text(field),
                    labelStyle: theme.textTheme.bodySmall,
                    backgroundColor: colorScheme.surface,
                    side: BorderSide(color: colorScheme.outline),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: onExpand,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Completar agora'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Se for dismissible, envolve em Dismissible
    if (dismissible && onDismiss != null) {
      return Dismissible(
        key: const Key('expansion_card'),
        direction: DismissDirection.horizontal,
        onDismissed: (_) => onDismiss!(),
        background: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: Icon(
            Icons.delete_outline,
            color: colorScheme.onErrorContainer,
          ),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Icon(
            Icons.delete_outline,
            color: colorScheme.onErrorContainer,
          ),
        ),
        child: widget,
      );
    }

    return widget;
  }
}
