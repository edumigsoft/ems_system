import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';

/// Opção de modo de criação de caderno.
class NotebookCreationMode {
  final NotebookType type;
  final String icon;
  final String title;
  final String description;

  const NotebookCreationMode({
    required this.type,
    required this.icon,
    required this.title,
    required this.description,
  });

  static const quick = NotebookCreationMode(
    type: NotebookType.quick,
    icon: '⚡',
    title: 'Nota Rápida',
    description: 'Anotações simples e diretas',
  );

  static const organized = NotebookCreationMode(
    type: NotebookType.organized,
    icon: '📖',
    title: 'Caderno Organizado',
    description: 'Com tags, projeto e estrutura',
  );

  static const reminder = NotebookCreationMode(
    type: NotebookType.reminder,
    icon: '📌',
    title: 'Lembrete',
    description: 'Com data e notificação programada',
  );

  static const List<NotebookCreationMode> all = [quick, organized, reminder];
}

/// Widget para seleção de modo de criação de caderno.
///
/// Exibe cards clicáveis com ícone, título e descrição para cada modo.
class ModeSelectorWidget extends StatelessWidget {
  final NotebookCreationMode? selectedMode;
  final ValueChanged<NotebookCreationMode> onModeSelected;
  final bool compact;

  const ModeSelectorWidget({
    super.key,
    this.selectedMode,
    required this.onModeSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact) ...[
          Text(
            'Escolha o tipo de caderno',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
        ],
        ...NotebookCreationMode.all.map((mode) {
          final isSelected = selectedMode?.type == mode.type;

          return Padding(
            padding: EdgeInsets.only(bottom: compact ? 8 : 12),
            child: _ModeCard(
              mode: mode,
              isSelected: isSelected,
              onTap: () => onModeSelected(mode),
              compact: compact,
            ),
          );
        }),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final NotebookCreationMode mode;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  const _ModeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Ícone
            Text(
              mode.icon,
              style: TextStyle(fontSize: compact ? 28 : 32),
            ),
            SizedBox(width: compact ? 12 : 16),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colorScheme.primary : null,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 4),
                    Text(
                      mode.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Indicador de seleção
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: compact ? 20 : 24,
              ),
          ],
        ),
      ),
    );
  }
}
