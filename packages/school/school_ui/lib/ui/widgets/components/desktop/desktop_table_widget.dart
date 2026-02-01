import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart';
import 'package:school_shared/school_shared.dart'
    show SchoolDetails, SchoolStatus;
import '../../../view_models/school_view_model.dart';
import '../../dialogs/dialogs.dart';

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

  Future<void> _editSchool(SchoolDetails school) async {
    final result = await showDialog<SchoolDetails>(
      context: context,
      builder: (context) => SchoolFormDialog(
        createUseCase: widget.viewModel.createUseCase,
        updateUseCase: widget.viewModel.updateUseCase,
        initialData: school,
      ),
    );

    if (result != null && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.schoolUpdateSuccess),
          backgroundColor: Colors.green,
        ),
      );
      widget.viewModel.fetchAllCommand.execute();
    }
  }

  Future<void> _deleteSchool(BuildContext context, SchoolDetails school) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SchoolDeleteConfirmDialog(schoolName: school.name),
    );

    if (result == true && context.mounted) {
      widget.viewModel.detailsCommand.execute(school);
      await widget.viewModel.deleteCommand.execute();

      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.schoolDeleteSuccess),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _restoreSchool(
    BuildContext context,
    SchoolDetails school,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SchoolRestoreConfirmDialog(schoolName: school.name),
    );

    if (result == true && context.mounted) {
      widget.viewModel.detailsCommand.execute(school);
      await widget.viewModel.restoreCommand.execute();

      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.schoolRestoreSuccess),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteSelected() {
    // Implementação simplificada: deleta um por um ou via comando específico se existisse
    for (final school in selectionState.selectedItems) {
      widget.viewModel.detailsCommand.execute(school);
      widget.viewModel.deleteCommand.execute();
    }
    selectionState.clearSelection();
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<SchoolDetails>(
      context: context,
      builder: (context) => SchoolFormDialog(
        createUseCase: widget.viewModel.createUseCase,
        updateUseCase: widget.viewModel.updateUseCase,
      ),
    );

    if (result != null && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.schoolCreateSuccess),
          backgroundColor: Colors.green,
        ),
      );
      widget.viewModel.fetchAllCommand.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width * 0.8;

    return DSDataTableContainer(
      width: width,
      // Campo de busca com botão de refresh e toggle de deletados
      searchField: Row(
        children: [
          Expanded(
            child: DSTableSearchField(
              hintText: l10n.searchSchoolsHint,
              onChanged: (value) {
                searchQuery = value;
                _applyFilters();
              },
              onClear: () {
                searchQuery = '';
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 8),
          // Toggle para mostrar/ocultar deletados
          Tooltip(
            message: widget.viewModel.showDeleted
                ? l10n.showActiveSchools
                : l10n.showDeletedSchools,
            child: FilterChip(
              label: Text(
                widget.viewModel.showDeleted
                    ? l10n.deletedSchoolsLabel
                    : l10n.activeSchoolsLabel,
              ),
              selected: widget.viewModel.showDeleted,
              onSelected: (selected) {
                widget.viewModel.toggleShowDeletedCommand.execute();
              },
              avatar: Icon(
                widget.viewModel.showDeleted
                    ? Icons.delete_outline
                    : Icons.check_circle_outline,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.viewModel.fetchAllCommand.running
                ? null
                : () => widget.viewModel.refreshCommand.execute(),
            tooltip: l10n.updateList,
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add),
            label: Text(l10n.addSchool),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
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
            label: l10n.schoolColumn,
            builder: (school) => Row(
              children: [
                DSTableCellWithIcon(
                  icon: Icons.school,
                  iconBackgroundColor: school.isDeleted
                      ? Colors.grey
                      : _getIconBackgroundColor(Icons.school),
                  title: school.name,
                  subtitle: school.isDeleted
                      ? '${l10n.cie}: ${school.code} (${l10n.deletedSchoolsLabel})'
                      : '${l10n.cie}: ${school.code}',
                ),
                if (school.isDeleted) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: l10n.schoolDeletedTooltip,
                    child: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          DSDataTableColumn<SchoolDetails>(
            label: l10n.locationColumn,
            builder: (school) => DSTableCellTwoLines(
              primary: school.locationCity,
              secondary: school.locationDistrict,
            ),
          ),
          DSDataTableColumn<SchoolDetails>(
            label: l10n.contactColumn,
            builder: (school) => DSTableCellTwoLines(
              primary: school.phone,
              secondary: school.email,
            ),
          ),
          DSDataTableColumn<SchoolDetails>(
            label: l10n.manager.toUpperCase(),
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
            label: l10n.status.toUpperCase(),
            builder: (school) => DSTableStatusIndicator(
              label: school.status.name,
              color: _getStatusColor(school.status),
            ),
          ),
          DSDataTableColumn<SchoolDetails>(
            label: l10n.actions.toUpperCase(),
            builder: (school) => DSTableActions(
              actions: school.isDeleted
                  ? [
                      // Ações para escolas deletadas
                      DSTableAction(
                        icon: Icons.restore_from_trash,
                        onPressed: () => _restoreSchool(context, school),
                        tooltip: l10n.restore,
                      ),
                    ]
                  : [
                      // Ações para escolas ativas
                      DSTableAction(
                        icon: Icons.edit,
                        onPressed: () => _editSchool(school),
                        tooltip: l10n.edit,
                      ),
                      DSTableAction(
                        icon: Icons.delete_outline,
                        onPressed: () => _deleteSchool(context, school),
                        tooltip: l10n.delete,
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
