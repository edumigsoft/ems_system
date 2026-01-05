import 'package:flutter/material.dart';

class CustomSeedCard extends StatelessWidget {
  final Widget child;
  final bool isBorderRadius;
  final EdgeInsets margin;
  final EdgeInsets padding;

  const CustomSeedCard({
    super.key,
    required this.child,
    this.isBorderRadius = true,
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.all(8.0),
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

    return Container(
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
      child: Card(
        elevation: 0,
        margin: margin,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide.none,
        ),
        color: cardBackgroundColor,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
