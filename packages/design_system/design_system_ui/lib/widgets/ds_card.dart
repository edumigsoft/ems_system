import 'package:flutter/material.dart';

/// Card personalizado do Design System
///
/// Prefixo: DS (Design System)
///
/// Variantes disponíveis:
/// - DSCard: Card padrão personalizável
/// - DSInfoCard: Card de informação com ícone
/// - DSActionCard: Card com ação destacada
///
/// Exemplo de uso:
/// ```dart
/// DSCard(
///   title: 'Título do Card',
///   subtitle: 'Subtítulo opcional',
///   child: Text('Conteúdo'),
///   onTap: () => print('Card clicado'),
/// )
/// ```
class DSCard extends StatelessWidget {
  /// Título principal do card
  final String? title;

  /// Subtítulo ou descrição
  final String? subtitle;

  /// Conteúdo principal do card
  final Widget? child;

  /// Widget à esquerda do título (geralmente um ícone)
  final Widget? leading;

  /// Widget à direita do título
  final Widget? trailing;

  /// Callback quando o card é tocado
  final VoidCallback? onTap;

  /// Padding interno do card
  final EdgeInsets? padding;

  /// Cor de fundo customizada
  final Color? backgroundColor;

  /// Elevação (sombra) customizada
  final double? elevation;

  /// Border radius customizado
  final BorderRadius? borderRadius;

  /// Borda customizada
  final Border? border;

  /// Lista de widgets de ação no rodapé
  final List<Widget>? actions;

  /// Margem externa do card
  final EdgeInsets? margin;

  /// Se deve mostrar um indicador de carregamento
  final bool isLoading;

  /// Se o card está desabilitado
  final bool isDisabled;

  const DSCard({
    super.key,
    this.title,
    this.subtitle,
    this.child,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.actions,
    this.margin,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;

    final effectiveBorderRadius =
        borderRadius ??
        (cardTheme.shape as RoundedRectangleBorder?)?.borderRadius
            as BorderRadius? ??
        BorderRadius.circular(12);

    final cardContent = Padding(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: isLoading
          ? _buildLoadingState(context)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header com título, leading e trailing
                if (title != null || leading != null || trailing != null)
                  _buildHeader(context),

                if ((title != null || leading != null || trailing != null) &&
                    (child != null || actions != null))
                  const SizedBox(height: 12),

                // Conteúdo principal
                if (child != null)
                  Opacity(
                    opacity: isDisabled ? 0.5 : 1.0,
                    child: child!,
                  ),

                // Actions
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildActions(),
                ],
              ],
            ),
    );

    final card = Card(
      elevation: elevation ?? cardTheme.elevation,
      color: backgroundColor ?? cardTheme.color,
      margin: margin ?? cardTheme.margin,
      shape: border != null
          ? RoundedRectangleBorder(
              borderRadius: effectiveBorderRadius,
              side: border!.top,
            )
          : RoundedRectangleBorder(
              borderRadius: effectiveBorderRadius,
              side:
                  (cardTheme.shape as RoundedRectangleBorder?)?.side ??
                  BorderSide.none,
            ),
      child: cardContent,
    );

    if (onTap != null && !isDisabled && !isLoading) {
      return InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: card,
      );
    }

    return card;
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (leading != null) ...[
          Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: leading!,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDisabled
                        ? theme.colorScheme.onSurface.withAlpha(128)
                        : null,
                  ),
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(
                      isDisabled ? 128 : 192,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: trailing!,
          ),
        ],
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions!
          .map(
            (action) => Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Opacity(
                opacity: isDisabled ? 0.5 : 1.0,
                child: action,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
