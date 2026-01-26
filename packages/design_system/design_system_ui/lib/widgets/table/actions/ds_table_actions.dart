import 'package:flutter/material.dart';
import '../actions/ds_table_action.dart';

/// Widget para renderizar ações de tabela.
///
/// Renderiza uma lista de ações ([DSTableAction]) como botões de ícone
/// alinhados horizontalmente. Ideal para colunas de ações em tabelas.
///
/// **Exemplo de uso:**
/// ```dart
/// DSTableActions(
///   actions: [
///     DSTableAction(
///       icon: Icons.edit,
///       onPressed: () => editItem(item),
///       tooltip: 'Editar',
///     ),
///     DSTableAction(
///       icon: Icons.delete_outline,
///       onPressed: () => deleteItem(item),
///       color: DSColors.error,
///       tooltip: 'Excluir',
///     ),
///   ],
/// )
/// ```
class DSTableActions extends StatelessWidget {
  /// Lista de ações a serem renderizadas.
  final List<DSTableAction> actions;

  /// Tamanho dos ícones (padrão: 18).
  final double iconSize;

  const DSTableActions({
    super.key,
    required this.actions,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final dsTheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions.map((action) {
        return IconButton(
          onPressed: action.onPressed,
          icon: Icon(
            action.icon,
            color: action.color ?? dsTheme.onSurface.withValues(alpha: 0.6),
            size: iconSize,
          ),
          tooltip: action.tooltip,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }).toList(),
    );
  }
}
