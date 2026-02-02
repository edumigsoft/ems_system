import 'package:design_system_shared/design_system_shared.dart';
import 'package:flutter/material.dart';

/// Célula de tabela com ícone circular e textos (título/subtítulo).
///
/// Componente especializado para renderizar células com um ícone em um
/// círculo colorido seguido de um título e um subtítulo opcional.
///
/// **Exemplo de uso:**
/// ```dart
/// DSTableCellWithIcon(
///   icon: Icons.school,
///   iconColor: DSColors.acquaPrimary,
///   title: 'Escola Est. Santos Dumont',
///   subtitle: 'Cod: 2024-001',
/// )
/// ```
class DSTableCellWithIcon extends StatelessWidget {
  /// Ícone a ser exibido.
  final IconData icon;

  /// Cor do ícone (opcional, usa primary do tema se null).
  final Color? iconColor;

  /// Cor do fundo do círculo (opcional, calcula do iconColor se null).
  final Color? iconBackgroundColor;

  /// Título principal da célula.
  final String title;

  /// Subtítulo opcional da célula.
  final String? subtitle;

  /// Tamanho do círculo do ícone (padrão: 32).
  final double iconSize;

  /// Tamanho do próprio ícone dentro do círculo (padrão: 18).
  final double iconGlyphSize;

  const DSTableCellWithIcon({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.iconBackgroundColor,
    this.subtitle,
    this.iconSize = 32,
    this.iconGlyphSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final dsTheme = Theme.of(context).colorScheme;

    final effectiveIconColor = iconColor ?? dsTheme.primary;
    final effectiveIconBgColor = iconBackgroundColor ?? effectiveIconColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: effectiveIconBgColor,
          ),
          child: Icon(
            icon,
            color: dsTheme.onPrimary,
            size: iconGlyphSize,
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dsTheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dsTheme.onSurface.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
