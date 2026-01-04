import 'package:flutter/material.dart';

import 'ds_card.dart';

/// Card com ação destacada (variante)
///
/// Exibe um card com foco em uma ação primária.
class DSActionCard extends StatelessWidget {
  /// Ícone da ação
  final IconData icon;

  /// Título da ação
  final String title;

  /// Descrição da ação
  final String description;

  /// Callback da ação
  final VoidCallback onTap;

  /// Cor de destaque
  final Color? accentColor;

  const DSActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveAccentColor = accentColor ?? theme.colorScheme.primary;

    return DSCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: effectiveAccentColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: effectiveAccentColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(192),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: effectiveAccentColor,
            size: 20,
          ),
        ],
      ),
    );
  }
}
