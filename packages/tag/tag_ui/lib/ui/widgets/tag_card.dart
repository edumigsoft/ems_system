import 'package:flutter/material.dart';
import 'package:tag_shared/tag_shared.dart';

/// A card widget displaying tag details.
///
/// Shows tag information in a card format with edit and delete actions.
class TagCard extends StatelessWidget {
  final TagDetails tag;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TagCard({
    required this.tag,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      child: ListTile(
        leading: _buildColorIndicator(context),
        title: Text(
          tag.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tag.description != null && tag.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                tag.description!,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Usado ${tag.usageCount} vez${tag.usageCount != 1 ? 'es' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!tag.isActive)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: const Text('Inativo'),
                  backgroundColor: colorScheme.errorContainer,
                  labelStyle: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontSize: 12,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'Editar',
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
                tooltip: 'Deletar',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorIndicator(BuildContext context) {
    if (tag.color == null || tag.color!.isEmpty) {
      return const CircleAvatar(
        child: Icon(Icons.label),
      );
    }

    try {
      final hexColor = tag.color!.replaceAll('#', '');
      final color = Color(int.parse('FF$hexColor', radix: 16));

      return CircleAvatar(
        backgroundColor: color,
        child: Icon(
          Icons.label,
          color: _getContrastColor(color),
        ),
      );
    } catch (_) {
      return const CircleAvatar(
        child: Icon(Icons.label),
      );
    }
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
