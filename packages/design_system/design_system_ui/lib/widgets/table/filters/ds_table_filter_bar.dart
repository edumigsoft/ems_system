import 'package:design_system_shared/design_system_shared.dart';
import 'package:flutter/material.dart';
import 'ds_table_filter.dart';
import 'ds_table_filter_chip.dart';

/// Barra horizontal de filtros acima da tabela.
///
/// Renderiza chips de filtros ativos e permite gerenciá-los.
///
/// **Exemplo de uso:**
/// ```dart
/// DSTableFilterBar(
///   filters: activeFilters,
///   onFilterChanged: (filter) {
///     setState(() {
///       if (activeFilters.contains(filter)) {
///         activeFilters.remove(filter);
///       } else {
///         activeFilters.add(filter);
///       }
///     });
///   },
///   onClearAll: () {
///     setState(() => activeFilters.clear());
///   },
/// )
/// ```
class DSTableFilterBar<T> extends StatelessWidget {
  /// Lista de filtros ativos
  final List<DSTableFilter<T>> filters;

  /// Callback quando um filtro é alterado (adicionado/removido)
  final ValueChanged<DSTableFilter<T>>? onFilterChanged;

  /// Callback para limpar todos os filtros
  final VoidCallback? onClearAll;

  /// Label customizado para o botão "Limpar tudo"
  final String clearAllLabel;

  const DSTableFilterBar({
    super.key,
    required this.filters,
    this.onFilterChanged,
    this.onClearAll,
    this.clearAllLabel = 'Limpar tudo',
  });

  @override
  Widget build(BuildContext context) {
    final dsTheme = Theme.of(context).colorScheme;

    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: dsTheme.surface,
        border: const Border(
          bottom: BorderSide(
            // color: dsTheme?.border ?? Colors.white10,
            color: Colors.white10,
          ),
        ),
      ),
      child: Wrap(
        spacing: DSSpacing.sm,
        runSpacing: DSSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Ícone de filtro
          Icon(
            Icons.filter_list,
            size: 18,
            color: dsTheme.primary,
          ),
          const SizedBox(width: DSSpacing.xs),

          // Chips de filtros
          ...filters.map((filter) {
            return DSTableFilterChip(
              label: filter.label,
              isActive: filter.isActive,
              onTap: onFilterChanged != null
                  ? () => onFilterChanged!(filter)
                  : null,
              onRemove: onFilterChanged != null
                  ? () => onFilterChanged!(filter)
                  : null,
            );
          }),

          // Botão limpar tudo
          if (onClearAll != null && filters.isNotEmpty) ...[
            const SizedBox(width: DSSpacing.sm),
            TextButton.icon(
              onPressed: onClearAll,
              icon: const Icon(Icons.clear_all, size: 16),
              label: Text(clearAllLabel),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
