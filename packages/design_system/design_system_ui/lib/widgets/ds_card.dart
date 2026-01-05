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
  //
  final bool isBorderRadius;
  final EdgeInsets margin;
  final EdgeInsets padding;

  // final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  // final bool isBorderRadius;
  final List<Widget>? actions;
  // final EdgeInsets? margin;
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
    //
    this.isBorderRadius = true,
    this.margin = const EdgeInsets.all(DSPaddings.extraSmall),
    this.padding = const EdgeInsets.all(DSPaddings.extraSmall),
    //
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.actions,
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
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;

    final cardBackgroundColor = colorScheme.surface;

    final shadowColor = brightness == Brightness.dark
        ? colorScheme.shadow.withValues(alpha: 0.3)
        : colorScheme.shadow.withValues(alpha: 0.4);

    final borderRadius = isBorderRadius
        ? BorderRadius.circular(12)
        : BorderRadius.zero;

    final container1 = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: borderRadius,
      ),
      child: isLoading ? _buildLoadingState(context) : child,
      // child: isLoading
      //     ? _buildLoadingState(context)
      //     : Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         mainAxisSize: MainAxisSize.max,
      //         children: [
      //           if (title != null || leading != null || trailing != null)
      //             _buildHeader(context),

      //           if ((title != null || leading != null || trailing != null) &&
      //               (child != null || actions != null))
      //             const SizedBox(height: DSPaddings.extraSmall),

      //           if (child != null)
      //             Opacity(
      //               opacity: isDisabled ? 0.5 : 1.0,
      //               child: child!,
      //             ),

      //           if (actions != null && actions!.isNotEmpty) ...[
      //             const SizedBox(height: DSPaddings.medium),
      //             _buildActions(),
      //           ],
      //         ],
      //       ),
    );

    final card = Card(
      elevation: 0,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide.none,
      ),
      color: cardBackgroundColor,
      child: container1,
    );

    final container2 = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: card,
    );

    if (onTap != null && !isDisabled && !isLoading) {
      return InkWell(
        onTap: onTap,
        borderRadius: null,
        child: container2,
      );
    }

    return container2;
  }

  // Widget _buildHeader(BuildContext context) {
  //   final theme = Theme.of(context);

  //   return Row(
  //     children: [
  //       if (leading != null) ...[
  //         Opacity(
  //           opacity: isDisabled ? 0.5 : 1.0,
  //           child: leading!,
  //         ),
  //         const SizedBox(width: DSPaddings.extraSmall),
  //       ],
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             if (title != null)
  //               Text(
  //                 title!,
  //                 style: theme.textTheme.titleMedium?.copyWith(
  //                   fontWeight: FontWeight.bold,
  //                   color: isDisabled
  //                       ? theme.colorScheme.onSurface.withAlpha(128)
  //                       : null,
  //                 ),
  //               ),
  //             if (subtitle != null) ...[
  //               const SizedBox(height: DSPaddings.tiny),
  //               Text(
  //                 subtitle!,
  //                 style: theme.textTheme.bodySmall?.copyWith(
  //                   color: theme.colorScheme.onSurface.withAlpha(
  //                     isDisabled ? 128 : 192,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ],
  //         ),
  //       ),
  //       if (trailing != null) ...[
  //         const SizedBox(width: DSPaddings.extraSmall),
  //         Opacity(
  //           opacity: isDisabled ? 0.5 : 1.0,
  //           child: trailing!,
  //         ),
  //       ],
  //     ],
  //   );
  // }

  // Widget _buildActions() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.end,
  //     children: actions!
  //         .map(
  //           (action) => Padding(
  //             padding: const EdgeInsets.only(left: DSPaddings.extraSmall),
  //             child: Opacity(
  //               opacity: isDisabled ? 0.5 : 1.0,
  //               child: action,
  //             ),
  //           ),
  //         )
  //         .toList(),
  //   );
  // }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(DSPaddings.medium),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
