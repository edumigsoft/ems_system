import 'package:design_system_shared/design_system_shared.dart';
import 'package:flutter/material.dart';

import 'ds_card.dart';

/// Card com ação destacada (variante)
///
/// Exibe um card com foco em uma ação primária.
class DSActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
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
      padding: const EdgeInsets.all(DSPaddings.medium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DSPaddings.medium),
            decoration: BoxDecoration(
              color: effectiveAccentColor.withAlpha(25),
              borderRadius: BorderRadius.circular(DSRadius.large),
            ),
            child: Icon(
              icon,
              color: effectiveAccentColor,
              size: 32,
            ),
          ),
          const SizedBox(width: DSPaddings.medium),
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
                const SizedBox(height: DSPaddings.tiny),
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
