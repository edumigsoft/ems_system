import 'package:flutter/material.dart';

import 'ds_card.dart';

/// Card de informação (variante)
///
/// Exibe um ícone, título e valor de forma compacta.
/// Ideal para dashboards e métricas.
class DSInfoCard extends StatelessWidget {
  /// Ícone principal
  final IconData icon;

  /// Título/label da informação
  final String title;

  /// Valor principal a ser exibido
  final String value;

  /// Cor do ícone
  final Color? iconColor;

  /// Cor de fundo do card
  final Color? backgroundColor;

  /// Callback quando tocado
  final VoidCallback? onTap;

  /// Texto opcional no rodapé
  final String? footer;

  /// Ícone de tendência (opcional)
  final IconData? trendIcon;

  /// Cor da tendência
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          value,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (trendIcon != null) ...[
                          const SizedBox(width: 8),
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
            const SizedBox(height: 12),
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
