import 'package:design_system_shared/design_system_shared.dart';
import 'package:flutter/material.dart';
import '../icons/ds_icons.dart';
import 'ds_card.dart';

class DSCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? actionButton;
  final bool showSearch;
  final String? hintTextSearch;
  final ValueChanged<String>? onSearchChanged;
  final int notificationCount;
  final VoidCallback? onNotificationPressed;
  final bool isBorderRadius;
  final bool hasShadow;
  final Color? backgroundColor;

  const DSCardHeader({
    super.key,
    this.title = 'Visão Geral',
    this.subtitle,
    this.actionButton,
    this.showSearch = true,
    this.hintTextSearch,
    this.onSearchChanged,
    this.notificationCount = 0,
    this.onNotificationPressed,
    this.isBorderRadius = true,
    this.hasShadow = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return DSCard(
      isBorderRadius: isBorderRadius,
      hasShadow: hasShadow,
      backgroundColor: backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(DSRadius.xxlarge),
          ),
        ),
        padding: const EdgeInsets.all(DSPaddings.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (subtitle == null) ...[
                  Icon(
                    DSIcons.dashboard,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: DSSpacing.extraSmall),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: DSSpacing.xs),
                        child: Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                // if (showSearch) ...[
                //   SearchField(
                //     hintText: hintTextSearch ?? 'Buscar aluno, turma...',
                //     width: 300,
                //     height: 40,
                //     onChanged: onSearchChanged,
                //   ),
                //   const SizedBox(width: DSSpacing.md),
                // ],
                if (actionButton != null) ...[
                  actionButton!,
                  const SizedBox(width: DSSpacing.md),
                ],
                // if (notificationCount > -1)
                //   NotificationBadge(
                //     count: notificationCount,
                //     onPressed: onNotificationPressed,
                //   ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
