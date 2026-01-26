import 'package:flutter/material.dart';

/// Chip de filtro reutilizável.
///
/// Renderiza um chip que representa um filtro ativo, com opção de remoção.
///
/// **Exemplo de uso:**
/// ```dart
/// DSTableFilterChip(
///   label: 'Status: Ativa',
///   isActive: true,
///   onTap: () => toggleFilter(filter),
///   onRemove: () => removeFilter(filter),
/// )
/// ```
class DSTableFilterChip extends StatelessWidget {
  /// Label do filtro
  final String label;

  /// Se o filtro está ativo
  final bool isActive;

  /// Callback quando o chip é tocado
  final VoidCallback? onTap;

  /// Callback quando o botão de remoção é pressionado
  final VoidCallback? onRemove;

  /// Cor customizada do chip (opcional)
  final Color? backgroundColor;

  const DSTableFilterChip({
    super.key,
    required this.label,
    this.isActive = true,
    this.onTap,
    this.onRemove,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final dsTheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: onTap != null ? (_) => onTap!() : null,
      onDeleted: onRemove,
      backgroundColor: backgroundColor ?? dsTheme.surface,
      selectedColor: dsTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: dsTheme.primary,
      deleteIconColor: dsTheme.onSurface.withValues(alpha: 0.6),
      labelStyle: TextStyle(
        color: isActive ? dsTheme.primary : dsTheme.onSurface,
        fontSize: 13,
      ),
    );
  }
}
