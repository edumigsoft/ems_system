import 'package:flutter/material.dart';

import 'ds_data_table_column.dart';
import 'ds_table_theme_data.dart';

/// Widget principal de tabela agnóstico ao tema.
///
/// `DSDataTable` renderiza uma tabela usando o [DataTable] do Flutter com
/// tema customizado. Suporta duas abordagens para definir colunas:
/// - **Células pré-prontas**: Use componentes especializados
/// - **Builders customizados**: Controle total sobre a renderização
///
/// **Exemplo básico:**
/// ```dart
/// DSDataTable<School>(
///   data: schools,
///   columns: [
///     DSDataTableColumn<School>(
///       label: 'ESCOLA',
///       builder: (school) => DSTableCellWithIcon(
///         icon: Icons.school,
///         title: school.name,
///         subtitle: 'Cod: ${school.code}',
///       ),
///     ),
///     DSDataTableColumn<School>(
///       label: 'LOCALIZAÇÃO',
///       builder: (school) => DSTableCellTwoLines(
///         primary: school.locationCity,
///         secondary: school.locationDistrict,
///       ),
///     ),
///   ],
/// )
/// ```
class DSDataTable<T> extends StatelessWidget {
  /// Lista de itens a serem exibidos na tabela.
  final List<T> data;

  /// Configuração das colunas da tabela.
  final List<DSDataTableColumn<T>> columns;

  /// Tema customizado para a tabela (opcional).
  ///
  /// Se não fornecido, usa o tema registrado no `Theme.of(context)`.
  final DSTableThemeData? themeData;

  /// Se deve mostrar coluna de checkbox para seleção (padrão: false).
  final bool showCheckboxColumn;

  /// Callback opcional quando uma linha é selecionada.
  final void Function(T item)? onSelectChanged;

  /// Configurações de ordenação
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending)? onSort;

  /// Se deve mostrar indicador de ordenação nas colunas
  final bool showSortIndicator;

  const DSDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.themeData,
    this.showCheckboxColumn = false,
    this.onSelectChanged,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.showSortIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final dsTheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: dsTheme.surface,
        // dividerColor: dsTheme?.border ?? Colors.white10,
        dividerColor: Colors.white10,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: dsTheme.surface,
          border: Border.all(
            // color: dsTheme?.border ?? Colors.white10,
            color: Colors.white10,
          ),
        ),
        child: DataTable(
          // Configurações do tema
          headingRowColor: WidgetStateProperty.all(dsTheme.surface),
          // headingRowHeight: tableTheme?.headingRowHeight ?? 48,
          headingRowHeight: 48,
          // dataRowMinHeight: tableTheme?.dataRowMinHeight ?? 72,
          dataRowMinHeight: 72,
          // dataRowMaxHeight: tableTheme?.dataRowMaxHeight ?? 72,
          dataRowMaxHeight: 72,
          // columnSpacing: tableTheme?.columnSpacing ?? 24,
          columnSpacing: 24,
          // horizontalMargin: tableTheme?.horizontalMargin ?? 16,
          horizontalMargin: 16,
          // dividerThickness: tableTheme?.dividerThickness ?? 1,
          dividerThickness: 1,
          // showBottomBorder: tableTheme?.showBottomBorder ?? true,
          showBottomBorder: true,

          // Configurações de seleção
          showCheckboxColumn: showCheckboxColumn,

          // Configurações de ordenação
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,

          // Cor das linhas
          dataRowColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return dsTheme.primary.withValues(alpha: 0.1);
              }
              return null;
            },
          ),

          // Colunas
          columns: columns.asMap().entries.map((entry) {
            final index = entry.key;
            final column = entry.value;

            return DataColumn(
              label: Text(
                column.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: dsTheme.primary,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              numeric: column.numeric,
              tooltip: column.tooltip,
              onSort: onSort != null
                  ? (columnIndex, ascending) {
                      onSort!(index, ascending);
                    }
                  : null,
            );
          }).toList(),

          // Linhas
          rows: data.map((item) {
            return DataRow(
              onSelectChanged: onSelectChanged != null
                  ? (_) => onSelectChanged!(item)
                  : null,
              cells: columns.map((column) {
                return DataCell(column.buildCell(item));
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
