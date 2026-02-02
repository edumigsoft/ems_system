import 'package:flutter/material.dart';

/// Container genérico e agnóstico para tabelas.
///
/// Fornece a estrutura visual padrão para tabelas no sistema:
/// - Campo de busca (opcional)
/// - Barra de filtros (opcional)
/// - Botões de adicionar filtros (opcional)
/// - Toolbar de seleção (opcional, aparece quando há seleção)
/// - Tabela de dados
/// - Paginação
///
/// Este componente é completamente agnóstico aos dados e pode ser usado
/// em qualquer feature do sistema. Ele apenas define a estrutura visual,
/// delegando o conteúdo específico aos widgets fornecidos.
///
/// **Exemplo de uso:**
/// ```dart
/// DSDataTableContainer(
///   width: MediaQuery.of(context).size.width * 0.8,
///   searchField: DSTableSearchField(
///     hintText: 'Buscar escolas...',
///     onChanged: (value) => _applySearch(value),
///   ),
///   filterBar: DSTableFilterBar(
///     filters: activeFilters,
///     onFilterChanged: _toggleFilter,
///   ),
///   addFiltersButtons: _buildAddFiltersButtons(),
///   selectionToolbar: selectionState.hasSelection
///       ? DSTableSelectionToolbar(
///           selectedCount: selectionState.selectedCount,
///           actions: [/* ações */],
///         )
///       : null,
///   dataTable: DSDataTable<School>(
///     data: schools,
///     columns: [/* colunas */],
///   ),
///   pagination: DSPagination(
///     currentPage: controller.currentPage,
///     // ... outros parâmetros
///   ),
/// )
/// ```
class DSDataTableContainer extends StatelessWidget {
  /// Largura do container (opcional, padrão: double.infinity).
  final double? width;

  /// Widget de campo de busca (opcional).
  final Widget? searchField;

  /// Widget de barra de filtros (opcional).
  final Widget? filterBar;

  /// Widget com botões para adicionar filtros (opcional).
  final Widget? addFiltersButtons;

  /// Widget de toolbar de seleção (opcional).
  ///
  /// Geralmente exibido condicionalmente quando há itens selecionados.
  final Widget? selectionToolbar;

  /// Widget da tabela de dados (obrigatório).
  final Widget dataTable;

  /// Widget de paginação (obrigatório).
  final Widget pagination;

  /// Espaçamento entre os componentes (padrão: 0).
  final double spacing;

  const DSDataTableContainer({
    super.key,
    this.width,
    this.searchField,
    this.filterBar,
    this.addFiltersButtons,
    this.selectionToolbar,
    required this.dataTable,
    required this.pagination,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo de busca (se fornecido)
              if (searchField != null) ...[
                SizedBox(
                  width: width,
                  child: searchField!,
                ),
                if (spacing > 0) SizedBox(height: spacing),
              ],

              // Barra de filtros (se fornecida)
              if (filterBar != null) ...[
                SizedBox(
                  width: width,
                  child: filterBar!,
                ),
                if (spacing > 0) SizedBox(height: spacing),
              ],

              // Botões de adicionar filtros (se fornecidos)
              if (addFiltersButtons != null) ...[
                SizedBox(
                  width: width,
                  child: addFiltersButtons!,
                ),
                if (spacing > 0) SizedBox(height: spacing),
              ],

              // Toolbar de seleção (se fornecida)
              if (selectionToolbar != null) ...[
                SizedBox(
                  width: width,
                  child: selectionToolbar!,
                ),
                if (spacing > 0) SizedBox(height: spacing),
              ],

              // Tabela de dados (obrigatória)
              SizedBox(
                width: width,
                child: dataTable,
              ),
              if (spacing > 0) SizedBox(height: spacing),

              // Paginação (obrigatória)
              pagination,
            ],
          ),
        ),
      ),
    );
  }
}
