import 'package:design_system_shared/design_system_shared.dart';
import 'package:flutter/material.dart';

import '../actions/ds_table_action.dart';

/// Barra de ferramentas exibida quando há itens selecionados na tabela.
///
/// Mostra a quantidade de itens selecionados e permite executar ações
/// em massa (excluir, exportar, etc.) ou limpar a seleção.
///
/// **Exemplo de uso:**
/// ```dart
/// if (selectionState.hasSelection)
///   DSTableSelectionToolbar(
///     selectedCount: selectionState.selectedCount,
///     actions: [
///       DSTableAction(
///         icon: Icons.delete,
///         onPressed: () => _deleteSelected(),
///         tooltip: 'Excluir selecionados',
///       ),
///       DSTableAction(
///         icon: Icons.file_download,
///         onPressed: () => _exportSelected(),
///         tooltip: 'Exportar selecionados',
///       ),
///     ],
///     onClearSelection: selectionState.clearSelection,
///   ),
/// ```
class DSTableSelectionToolbar extends StatelessWidget {
  /// Quantidade de itens selecionados.
  final int selectedCount;

  /// Lista de ações a serem executadas nos itens selecionados.
  final List<DSTableAction> actions;

  /// Callback para limpar a seleção.
  final VoidCallback? onClearSelection;

  /// Label customizado (padrão: "$selectedCount selecionado(s)").
  final String? selectedLabel;

  /// Cor de fundo da toolbar (opcional).
  final Color? backgroundColor;

  const DSTableSelectionToolbar({
    super.key,
    required this.selectedCount,
    required this.actions,
    this.onClearSelection,
    this.selectedLabel,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final dsTheme = Theme.of(context).colorScheme;

    final label = selectedLabel ?? '$selectedCount selecionado(s)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? dsTheme.primary.withValues(alpha: 0.1),
        border: const Border(
          bottom: BorderSide(
            // color: dsTheme?.border ?? Colors.white10,
            color: Colors.white10,
          ),
        ),
      ),
      child: Row(
        children: [
          // Ícone de seleção
          Icon(
            Icons.check_circle,
            color: dsTheme.primary,
            size: 20,
          ),
          const SizedBox(width: DSSpacing.sm),

          // Label de contagem
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: dsTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          // Ações em massa
          ...actions.map((action) {
            return Padding(
              padding: const EdgeInsets.only(left: DSSpacing.sm),
              child: IconButton(
                onPressed: action.onPressed,
                icon: Icon(
                  action.icon,
                  color: action.color ?? dsTheme.onSurface,
                ),
                tooltip: action.tooltip,
              ),
            );
          }),

          // Botão limpar seleção
          if (onClearSelection != null) ...[
            const SizedBox(width: DSSpacing.xs),
            TextButton.icon(
              onPressed: onClearSelection,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Limpar'),
            ),
          ],
        ],
      ),
    );
  }
}
