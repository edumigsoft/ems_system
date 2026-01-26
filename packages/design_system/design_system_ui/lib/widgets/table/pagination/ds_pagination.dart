import 'package:design_system_shared/design_system_shared.dart';
import 'package:flutter/material.dart';

/// Widget de paginação agnóstico.
///
/// Renderiza controles de paginação com informações sobre os itens sendo
/// exibidos e botões para navegar entre páginas. Opcionalmente inclui um
/// seletor de itens por página.
///
/// **Exemplo básico:**
/// ```dart
/// DSPagination(
///   currentPage: controller.currentPage,
///   totalItems: controller.totalItems,
///   itemsPerPage: controller.itemsPerPage,
///   onPreviousPage: controller.previousPage,
///   onNextPage: controller.nextPage,
///   hasPreviousPage: controller.hasPreviousPage,
///   hasNextPage: controller.hasNextPage,
/// )
/// ```
///
/// **Exemplo com seletor de itens por página:**
/// ```dart
/// DSPagination(
///   // ... parâmetros básicos
///   onItemsPerPageChanged: (newValue) {
///     controller.setItemsPerPage(newValue);
///   },
///   itemsPerPageOptions: [5, 10, 20, 50, 100],
/// )
/// ```
class DSPagination extends StatelessWidget {
  /// Página atual (1-indexed).
  final int currentPage;

  /// Total de itens na lista completa.
  final int totalItems;

  /// Quantidade atual de itens por página.
  final int itemsPerPage;

  /// Callback para navegar para a página anterior.
  final VoidCallback onPreviousPage;

  /// Callback para navegar para a próxima página.
  final VoidCallback onNextPage;

  /// Se existe uma página anterior.
  final bool hasPreviousPage;

  /// Se existe uma próxima página.
  final bool hasNextPage;

  /// Callback opcional para quando o usuário altera itens por página.
  ///
  /// Se fornecido, um dropdown será exibido permitindo escolher a quantidade.
  final ValueChanged<int>? onItemsPerPageChanged;

  /// Opções disponíveis no dropdown de itens por página.
  ///
  /// Apenas usado se [onItemsPerPageChanged] for fornecido.
  final List<int>? itemsPerPageOptions;

  /// Template para o texto de informação (não implementado ainda).
  final String? labelTemplate;

  /// Label do botão "Anterior" (padrão: 'Anterior').
  final String previousLabel;

  /// Label do botão "Próxima" (padrão: 'Próxima').
  final String nextLabel;

  /// Label para o seletor de itens por página (padrão: 'Itens por página:').
  final String itemsPerPageLabel;

  const DSPagination({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.hasPreviousPage,
    required this.hasNextPage,
    this.onItemsPerPageChanged,
    this.itemsPerPageOptions = const [5, 10, 20, 50],
    this.labelTemplate,
    this.previousLabel = 'Anterior',
    this.nextLabel = 'Próxima',
    this.itemsPerPageLabel = 'Itens por página:',
  });

  @override
  Widget build(BuildContext context) {
    final dsTheme = Theme.of(context).colorScheme;

    final startItem = totalItems > 0 ? (currentPage - 1) * itemsPerPage + 1 : 0;
    final endItem = totalItems > 0
        ? (startItem + itemsPerPage - 1).clamp(startItem, totalItems)
        : 0;

    return Container(
      padding: const EdgeInsets.all(DSPaddings.medium),
      decoration: BoxDecoration(
        color: dsTheme.surface,
        border: const Border(
          top: BorderSide(
            // color: dsTheme?.border ?? Colors.white10,
            color: Colors.white10,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Informação de página atual
          Text(
            totalItems > 0
                ? 'Mostrando $startItem a $endItem de $totalItems'
                : 'Nenhum item',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: dsTheme.onSurface.withValues(alpha: 0.6),
            ),
          ),

          // Controles de navegação
          Row(
            children: [
              // Seletor de itens por página (opcional)
              if (onItemsPerPageChanged != null &&
                  itemsPerPageOptions != null) ...[
                Text(
                  itemsPerPageLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dsTheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: DSSpacing.xs),
                DropdownButton<int>(
                  value: itemsPerPage,
                  items: itemsPerPageOptions!.map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && onItemsPerPageChanged != null) {
                      onItemsPerPageChanged!(value);
                    }
                  },
                  underline: const SizedBox(),
                  dropdownColor: dsTheme.surface,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dsTheme.onSurface,
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
              ],

              // Botões de navegação
              ElevatedButton(
                onPressed: hasPreviousPage ? onPreviousPage : null,
                child: Text(previousLabel),
              ),
              const SizedBox(width: DSSpacing.sm),
              ElevatedButton(
                onPressed: hasNextPage ? onNextPage : null,
                child: Text(nextLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
