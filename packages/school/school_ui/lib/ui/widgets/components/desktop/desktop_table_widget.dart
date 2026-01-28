import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:school_shared/school_shared.dart'
    show SchoolDetails, SchoolStatus;
import '../../../view_models/school_view_model.dart';

// Widget que combina tabela com todas as funcionalidades do Design System
class DesktopTableWidget extends StatefulWidget {
  final SchoolViewModel viewModel;

  const DesktopTableWidget({super.key, required this.viewModel});

  @override
  State<DesktopTableWidget> createState() => _DesktopTableWidgetState();
}

class _DesktopTableWidgetState extends State<DesktopTableWidget> {
  late List<SchoolDetails> allSchools;
  late List<SchoolDetails> filteredSchools;
  late DSPaginationController<SchoolDetails> paginationController;
  late DSDataTableSortState sortState;
  late DSTableSelectionState<SchoolDetails> selectionState;

  // Estado de filtros
  String searchQuery = '';
  List<DSTableFilter<SchoolDetails>> activeFilters = [];
  List<DSTableFilter<SchoolDetails>> availableFilters = [];

  @override
  void initState() {
    super.initState();

    // Carregar dados iniciais
    _updateData();

    // Filtros disponíveis
    availableFilters = [
      DSTableFilter<SchoolDetails>(
        id: 'status_active',
        label: 'Ativas',
        predicate: (school) => school.status == SchoolStatus.active,
      ),
      DSTableFilter<SchoolDetails>(
        id: 'status_maintenance',
        label: 'Em Manutenção',
        predicate: (school) => school.status == SchoolStatus.maintenance,
      ),
    ];

    filteredSchools = allSchools;
    sortState = DSDataTableSortState();
    selectionState = DSTableSelectionState<SchoolDetails>();
    paginationController = DSPaginationController(
      allItems: filteredSchools,
      itemsPerPage: 5,
    );

    // Listeners
    sortState.addListener(_applySorting);
    selectionState.addListener(() => setState(() {}));
    widget.viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) {
      _updateData();
      _applyFilters();
    }
  }

  void _updateData() {
    allSchools = widget.viewModel.fetchAllCommand.result?.valueOrNull ?? [];
  }

  @override
  void dispose() {
    sortState.dispose();
    selectionState.dispose();
    paginationController.dispose();
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  /// Aplica filtros e atualiza paginação
  void _applyFilters() {
    filteredSchools = allSchools.where((school) {
      // Busca textual
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!school.name.toLowerCase().contains(query) &&
            !school.code.toLowerCase().contains(query) &&
            !school.locationCity.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtros ativos
      for (final filter in activeFilters) {
        if (!filter.predicate(school)) return false;
      }

      return true;
    }).toList();

    // Reordenar se necessário
    if (sortState.isSorted) {
      _applySortingToList(filteredSchools);
    }

    // Atualizar paginação
    paginationController = DSPaginationController(
      allItems: filteredSchools,
      itemsPerPage: paginationController.itemsPerPage,
    );

    setState(() {});
  }

  /// Aplica ordenação
  void _applySorting() {
    if (sortState.isSorted) {
      _applySortingToList(filteredSchools);
      paginationController = DSPaginationController(
        allItems: filteredSchools,
        itemsPerPage: paginationController.itemsPerPage,
      );
    }
    setState(() {});
  }

  /// Aplica ordenação à lista
  void _applySortingToList(List<SchoolDetails> list) {
    final columnIndex = sortState.sortColumnIndex!;
    final ascending = sortState.sortAscending;

    list.sort((a, b) {
      int comparison = 0;
      switch (columnIndex) {
        case 0: // ESCOLA
          comparison = a.name.compareTo(b.name);
        case 1: // LOCALIZAÇÃO
          comparison = a.locationCity.compareTo(b.locationCity);
        case 2: // CONTATO
          comparison = a.phone.compareTo(b.phone);
        case 3: // DIREÇÃO
          comparison = a.director.compareTo(b.director);
        case 4: // STATUS
          comparison = a.status.index.compareTo(b.status.index);
        default:
          comparison = 0;
      }
      return ascending ? comparison : -comparison;
    });
  }

  Color _getIconBackgroundColor(IconData icon) {
    switch (icon) {
      case Icons.school:
        return Colors.blue;
      case Icons.book:
        return Colors.green;
      case Icons.science:
        return Colors.yellow;
      case Icons.child_care:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(SchoolStatus status) {
    switch (status) {
      case SchoolStatus.active:
        return Colors.green;
      case SchoolStatus.maintenance:
        return Colors.yellow;
      case SchoolStatus.inactive:
        return Colors.red;
    }
  }

  void _editSchool(SchoolDetails school) {
    widget.viewModel.detailsCommand.execute(school);
    widget.viewModel.editCommand.execute();
  }

  void _deleteSchool(SchoolDetails school) {
    widget.viewModel.detailsCommand.execute(school);
    widget.viewModel.deleteCommand.execute();
  }

  void _deleteSelected() {
    // Implementação simplificada: deleta um por um ou via comando específico se existisse
    for (final school in selectionState.selectedItems) {
      widget.viewModel.detailsCommand.execute(school);
      widget.viewModel.deleteCommand.execute();
    }
    selectionState.clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.8;

    return DSDataTableContainer(
      width: width,
      // Campo de busca
      searchField: DSTableSearchField(
        hintText: 'Buscar escolas por nome, código ou cidade...',
        onChanged: (value) {
          searchQuery = value;
          _applyFilters();
        },
        onClear: () {
          searchQuery = '';
          _applyFilters();
        },
      ),
      // Barra de filtros
      filterBar: DSTableFilterBar<SchoolDetails>(
        filters: activeFilters,
        onFilterChanged: (filter) {
          setState(() {
            if (activeFilters.contains(filter)) {
              activeFilters.remove(filter);
            } else {
              activeFilters.add(filter);
            }
            _applyFilters();
          });
        },
        onClearAll: () {
          setState(() {
            activeFilters.clear();
            _applyFilters();
          });
        },
      ),
      // Botões de adicionar filtros
      addFiltersButtons: activeFilters.length < availableFilters.length
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                children: availableFilters
                    .where((f) => !activeFilters.contains(f))
                    .map((filter) {
                      return OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            activeFilters.add(filter);
                            _applyFilters();
                          });
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(filter.label),
                      );
                    })
                    .toList(),
              ),
            )
          : null,
      // Toolbar de seleção (quando há itens selecionados)
      selectionToolbar: selectionState.hasSelection
          ? DSTableSelectionToolbar(
              selectedCount: selectionState.selectedCount,
              actions: [
                DSTableAction(
                  icon: Icons.delete,
                  onPressed: _deleteSelected,
                  tooltip: 'Excluir selecionados',
                ),
              ],
              onClearSelection: selectionState.clearSelection,
            )
          : null,
      // Tabela de dados
      dataTable: DSDataTable<SchoolDetails>(
        data: paginationController.currentItems,
        sortColumnIndex: sortState.sortColumnIndex,
        sortAscending: sortState.sortAscending,
        onSort: (columnIndex, ascending) {
          sortState.sort(columnIndex);
        },
        showCheckboxColumn: true,
        onSelectChanged: (school) {
          selectionState.toggle(school);
        },
        columns: [
          DSDataTableColumn<SchoolDetails>(
            label: 'ESCOLA',
            builder: (school) => DSTableCellWithIcon(
              icon: Icons.school,
              iconBackgroundColor: _getIconBackgroundColor(
                Icons.school,
              ),
              title: school.name,
              subtitle: 'Cod: ${school.code}',
            ),
          ),
          DSDataTableColumn<SchoolDetails>(
            label: 'LOCALIZAÇÃO',
            builder: (school) => DSTableCellTwoLines(
              primary: school.locationCity,
              secondary: school.locationDistrict,
            ),
          ),
          DSDataTableColumn<SchoolDetails>(
            label: 'CONTATO',
            builder: (school) => DSTableCellTwoLines(
              primary: school.phone,
              secondary: school.email,
            ),
          ),
          DSDataTableColumn<SchoolDetails>(
            label: 'DIREÇÃO',
            builder: (school) {
              final dsTheme = Theme.of(
                context,
              ).colorScheme;
              final tableTheme = Theme.of(
                context,
              ).extension<DSTableThemeData>();

              return Text(
                school.director,
                style: tableTheme?.textStyles.cellPrimary.copyWith(
                  color: dsTheme.onSurface,
                ),
              );
            },
          ),
          DSDataTableColumn<SchoolDetails>(
            label: 'STATUS',
            builder: (school) => DSTableStatusIndicator(
              label: school.status.name,
              color: _getStatusColor(school.status),
            ),
          ),
          DSDataTableColumn<SchoolDetails>(
            label: 'AÇÕES',
            builder: (school) => DSTableActions(
              actions: [
                DSTableAction(
                  icon: Icons.edit,
                  onPressed: () => _editSchool(school),
                  tooltip: 'Editar',
                ),
                DSTableAction(
                  icon: Icons.delete_outline,
                  onPressed: () => _deleteSchool(school),
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ),
        ],
      ),
      // Paginação
      pagination: DSPagination(
        currentPage: paginationController.currentPage,
        totalItems: paginationController.totalItems,
        itemsPerPage: paginationController.itemsPerPage,
        onPreviousPage: () {
          setState(() {
            paginationController.previousPage();
          });
        },
        onNextPage: () {
          setState(() {
            paginationController.nextPage();
          });
        },
        hasPreviousPage: paginationController.hasPreviousPage,
        hasNextPage: paginationController.hasNextPage,
        onItemsPerPageChanged: (newValue) {
          setState(() {
            paginationController.setItemsPerPage(newValue);
          });
        },
        itemsPerPageOptions: const [5, 10, 20, 50],
      ),
    );
  }
}
