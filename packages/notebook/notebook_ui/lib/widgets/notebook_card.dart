import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:tag_shared/tag_shared.dart';

/// Card para exibir preview de um caderno na lista.
class NotebookCard extends StatelessWidget {
  final NotebookDetails notebook;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Map<String, TagDetails> tagsMap;

  const NotebookCard({
    super.key,
    required this.notebook,
    required this.onTap,
    required this.onDelete,
    this.tagsMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com título e ícone de tipo
              Row(
                children: [
                  Icon(
                    _getIconForType(notebook.type),
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notebook.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Excluir',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Preview do conteúdo
              Text(
                notebook.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(64),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Tags e metadata
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Data
                  _buildMetadataChip(
                    context,
                    Icons.calendar_today,
                    _formatDate(notebook.createdAt),
                  ),

                  // Tags (mostra até 3)
                  if (notebook.tags != null && notebook.tags!.isNotEmpty)
                    ...notebook.tags!.take(3).map((tagId) {
                      return _buildTagChip(context, tagId);
                    }),

                  // Indicador de mais tags
                  if (notebook.tags != null && notebook.tags!.length > 3)
                    _buildMetadataChip(
                      context,
                      Icons.more_horiz,
                      '+${notebook.tags!.length - 3}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, String tagId) {
    final theme = Theme.of(context);
    final tagParams = tagsMap[tagId];

    // Resolve cor (se houver) ou usa padrão
    Color? tagColor;
    if (tagParams?.color != null) {
      try {
        tagColor = Color(int.parse(tagParams!.color!.replaceAll('#', '0xFF')));
      } catch (_) {
        // Ignora erro de parse
      }
    }

    final backgroundColor =
        tagColor?.withAlpha(40) ?? theme.colorScheme.primaryContainer;
    final textColor = tagColor ?? theme.colorScheme.onPrimaryContainer;
    final label = tagParams?.name ?? tagId; // Mostra nome ou ID se não achar

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tagParams != null ? label : '#$label', // Adiciona # se for ID
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getIconForType(NotebookType? type) {
    return switch (type) {
      NotebookType.quick => Icons.flash_on,
      NotebookType.organized => Icons.folder_special,
      NotebookType.reminder => Icons.notifications_active,
      _ => Icons.note,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
