import 'package:flutter/material.dart';
import 'package:tag_shared/tag_shared.dart';

/// A chip widget displaying a tag with optional actions.
///
/// Shows the tag name with optional color and supports tap and delete actions.
class TagChip extends StatelessWidget {
  final TagDetails tag;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDelete;

  const TagChip({
    required this.tag,
    this.onTap,
    this.onDelete,
    this.showDelete = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Parse color from hex if available
    Color? chipColor;
    if (tag.color != null && tag.color!.isNotEmpty) {
      try {
        final hexColor = tag.color!.replaceAll('#', '');
        chipColor = Color(int.parse('FF$hexColor', radix: 16));
      } catch (_) {
        // Ignore invalid colors
      }
    }

    return Chip(
      label: Text(tag.name),
      backgroundColor: chipColor ?? colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: chipColor != null
            ? _getContrastColor(chipColor)
            : colorScheme.onPrimaryContainer,
      ),
      deleteIcon: showDelete && onDelete != null
          ? Icon(
              Icons.close,
              size: 18,
              color: chipColor != null
                  ? _getContrastColor(chipColor)
                  : colorScheme.onPrimaryContainer,
            )
          : null,
      onDeleted: showDelete && onDelete != null ? onDelete : null,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  /// Gets a contrasting color (black or white) for the given background color.
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
