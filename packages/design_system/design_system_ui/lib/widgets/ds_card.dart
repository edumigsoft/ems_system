import 'package:design_system_shared/design_system_shared.dart';
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
  final String? title;
  final String? subtitle;
  final Widget? child;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<Widget>? actions;
  final EdgeInsets? margin;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final bool hasShadow;
  final bool hasBorder;
  final List<BoxShadow>? boxShadow;

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
    this.width,
    this.height,
    this.hasShadow = true,
    this.hasBorder = false,
    this.boxShadow,

    // this.borderRadius,
    // this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;

    final effectiveBorderRadius =
        borderRadius ??
        (cardTheme.shape as RoundedRectangleBorder?)?.borderRadius
            as BorderRadius? ??
        BorderRadius.circular(DSRadius.large);

    final effectivePadding = padding ?? const EdgeInsets.all(DSPaddings.medium);

    List<BoxShadow> effectiveBoxShadow = [];
    if (hasShadow) {
      const dsBoxShadow = DSBoxShadow.small;
      effectiveBoxShadow =
          boxShadow ??
          <BoxShadow>[
            BoxShadow(
              color: cardTheme.shadowColor!,
              blurRadius: dsBoxShadow.blurRadius,
              spreadRadius: dsBoxShadow.spreadRadius,
              offset: Offset(
                dsBoxShadow.offset.dx,
                dsBoxShadow.offset.dy,
              ),
            ),
            BoxShadow(
              color: cardTheme.shadowColor!,
              blurRadius: dsBoxShadow.blurRadius,
              spreadRadius: dsBoxShadow.spreadRadius,
              offset: Offset(
                dsBoxShadow.offset.dx,
                dsBoxShadow.offset.dy,
              ),
            ),
          ];
    }

    // final effectiveBorderColor =
    //     borderColor ?? dsTheme?.border ?? DSPrimitiveColors.neutralGrey300;

    final container = Container(
      width: width,
      height: height,
      padding: effectivePadding,
      decoration: BoxDecoration(
        // color: backgroundColor ?? cardTheme.color?.withAlpha(125),
        color: Colors.transparent,
        borderRadius: effectiveBorderRadius,
        //   // border: hasBorder ? Border.all(color: effectiveBorderColor) : null,
        boxShadow: effectiveBoxShadow,
        shape: BoxShape.rectangle,
      ),
      child: isLoading
          ? _buildLoadingState(context)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (title != null || leading != null || trailing != null)
                  _buildHeader(context),

                if ((title != null || leading != null || trailing != null) &&
                    (child != null || actions != null))
                  const SizedBox(height: DSPaddings.extraSmall),

                if (child != null)
                  Opacity(
                    opacity: isDisabled ? 0.5 : 1.0,
                    child: child!,
                  ),

                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: DSPaddings.medium),
                  _buildActions(),
                ],
              ],
            ),
    );

    final card = Card(
      elevation: elevation ?? cardTheme.elevation,
      color: backgroundColor ?? cardTheme.color,
      // color: backgroundColor ?? cardTheme.color?.withAlpha(200),
      // color: Colors.transparent,
      margin: margin ?? cardTheme.margin,
      // shape: border != null
      //     ? RoundedRectangleBorder(
      //         borderRadius: effectiveBorderRadius,
      //         side: border!.top,
      //       )
      //     : RoundedRectangleBorder(
      //         borderRadius: effectiveBorderRadius,
      //         side:
      //             (cardTheme.shape as RoundedRectangleBorder?)?.side ??
      //             BorderSide.none,
      //       ),
      // child: child,
      child: container,
    );

    if (onTap != null && !isDisabled && !isLoading) {
      return InkWell(
        onTap: onTap,
        // borderRadius: effectiveBorderRadius,
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
          const SizedBox(width: DSPaddings.extraSmall),
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
                const SizedBox(height: DSPaddings.tiny),
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
          const SizedBox(width: DSPaddings.extraSmall),
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
              padding: const EdgeInsets.only(left: DSPaddings.extraSmall),
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
        padding: EdgeInsets.all(DSPaddings.medium),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
