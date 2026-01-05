import 'package:design_system_shared/design_system_shared.dart';
import 'package:flutter/material.dart';

import 'ds_card.dart';

/// Card de informação (variante)
///
/// Exibe um ícone, título e valor de forma compacta.
/// Ideal para dashboards e métricas.
class DSInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final String? footer;
  final IconData? trendIcon;
  final Color? trendColor;

  const DSInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.footer,
    this.trendIcon,
    this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;

    return DSCard(
      backgroundColor: backgroundColor,
      onTap: onTap,
      padding: const EdgeInsets.all(DSPaddings.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DSPaddings.extraSmall),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(DSRadius.medium),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: DSPaddings.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(192),
                      ),
                    ),
                    const SizedBox(height: DSPaddings.tiny),
                    Row(
                      children: [
                        Text(
                          value,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (trendIcon != null) ...[
                          const SizedBox(width: DSPaddings.extraSmall),
                          Icon(
                            trendIcon,
                            size: 20,
                            color: trendColor ?? theme.colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: DSPaddings.extraSmall),
            Text(
              footer!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(128),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
