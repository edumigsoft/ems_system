import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:core_shared/core_shared.dart' show GetItInjector;
import '../../../../view_models/notebook_list_view_model.dart';
import '../../../../view_models/notebook_detail_view_model.dart';
import '../../../../view_models/notebook_create_view_model.dart';
import '../../../../pages/notebook_detail_page.dart';
import '../../../../pages/notebook_form_page.dart';
import '../../dialogs/dialogs.dart';

/// Tabela desktop para gerenciamento de cadernos.
///
/// DSDataTableContainer com sorting, filtros por tipo, paginação.
/// Criar via NotebookFormPage; editar via NotebookFormPage; detalhe via NotebookDetailPage.
class DesktopTableWidget extends StatefulWidget {
  final NotebookListViewModel viewModel;

  const DesktopTableWidget({super.key, required this.viewModel});

  @override
  State<DesktopTableWidget> createState() => _DesktopTableWidgetState();
}

class _DesktopTableWidgetState extends State<DesktopTableWidget> {
  late List<NotebookDetails> allNotebooks;
  late List<NotebookDetails> filteredNotebooks;
  late DSPaginationController<NotebookDetails> paginationController;
  late DSDataTableSortState sortState;
  late DSTableSelectionState<NotebookDetails> selectionState;

  String searchQuery = '';
  List<DSTableFilter<NotebookDetails>> activeFilters = [];
  List<DSTableFilter<NotebookDetails>> availableFilters = [];

  @override
  void initState() {
    super.initState();
    _updateData();

    availableFilters = NotebookType.values
        .map(
          (type) => DSTableFilter<NotebookDetails>(
            id: 'type_${type.name}',
            label: _getTypeLabel(type),
            predicate: (n) => n.type == type,
          ),
        )
        .toList();

    filteredNotebooks = allNotebooks;
    sortState = DSDataTableSortState();
    selectionState = DSTableSelectionState<NotebookDetails>();
    paginationController = DSPaginationController(
      allItems: filteredNotebooks,
      itemsPerPage: 10,
    );

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
    allNotebooks = widget.viewModel.notebooks ?? [];
  }

  @override
  void dispose() {
    sortState.dispose();
    selectionState.dispose();
    paginationController.dispose();
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _applyFilters() {
    filteredNotebooks = allNotebooks.where((notebook) {
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!notebook.title.toLowerCase().contains(query) &&
            !notebook.content.toLowerCase().contains(query)) {
          return false;
        }
      }
      for (final filter in activeFilters) {
        if (!filter.predicate(notebook)) return false;
      }
      return true;
    }).toList();

    if (sortState.isSorted) {
      _applySortingToList(filteredNotebooks);
    }

    paginationController = DSPaginationController(
      allItems: filteredNotebooks,
      itemsPerPage: paginationController.itemsPerPage,
    );

    setState(() {});
  }

  void _applySorting() {
    if (sortState.isSorted) {
      _applySortingToList(filteredNotebooks);
      paginationController = DSPaginationController(
        allItems: filteredNotebooks,
        itemsPerPage: paginationController.itemsPerPage,
      );
    }
    setState(() {});
  }

  void _applySortingToList(List<NotebookDetails> list) {
    final columnIndex = sortState.sortColumnIndex!;
    final ascending = sortState.sortAscending;

    list.sort((a, b) {
      int comparison = 0;
      switch (columnIndex) {
        case 0:
          comparison = a.title.compareTo(b.title);
        case 1:
          comparison =
              (a.type?.name ?? '').compareTo(b.type?.name ?? '');
        case 2:
          comparison = a.createdAt.compareTo(b.createdAt);
        default:
          comparison = 0;
      }
      return ascending ? comparison : -comparison;
    });
  }

  Future<void> _navigateToCreate() async {
    NotebookCreate? toCreate;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => NotebookFormPage(
          onCreate: (create) => toCreate = create,
        ),
      ),
    );
    if (result == true && toCreate != null && mounted) {
      final createVm = GetItInjector().get<NotebookCreateViewModel>();
      await createVm.createNotebook(toCreate!);
      widget.viewModel.loadNotebooks();
    }
  }

  Future<void> _navigateToDetail(NotebookDetails notebook) async {
    final detailVm = GetItInjector().get<NotebookDetailViewModel>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => NotebookDetailPage(
          viewModel: detailVm,
          notebookId: notebook.id,
        ),
      ),
    );
    if (mounted) widget.viewModel.loadNotebooks();
  }

  Future<void> _navigateToEdit(NotebookDetails notebook) async {
    NotebookUpdate? toUpdate;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => NotebookFormPage(
          notebook: notebook,
          onCreate: (_) {},
          onUpdate: (update) => toUpdate = update,
        ),
      ),
    );
    if (result == true && toUpdate != null && mounted) {
      final detailVm = GetItInjector().get<NotebookDetailViewModel>();
      await detailVm.loadNotebook(notebook.id);
      await detailVm.updateNotebook(toUpdate!);
      widget.viewModel.loadNotebooks();
    }
  }

  Future<void> _confirmDelete(NotebookDetails notebook) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          NotebookDeleteConfirmDialog(notebookTitle: notebook.title),
    );
    if (confirmed == true && mounted) {
      final success = await widget.viewModel.deleteNotebook(notebook.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Caderno deletado com sucesso'
                  : (widget.viewModel.error ?? 'Erro ao deletar caderno'),
            ),
            backgroundColor: success ? null : Colors.red,
          ),
        );
      }
    }
  }

  IconData _getIconForType(NotebookType? type) {
    return switch (type) {
      NotebookType.quick => Icons.flash_on,
      NotebookType.organized => Icons.folder_special,
      NotebookType.reminder => Icons.notifications_active,
      _ => Icons.note,
    };
  }

  Color _getColorForType(NotebookType? type) {
    return switch (type) {
      NotebookType.quick => Colors.orange,
      NotebookType.organized => Colors.blue,
      NotebookType.reminder => Colors.purple,
      _ => Colors.grey,
    };
  }

  String _getTypeLabel(NotebookType? type) {
    return switch (type) {
      NotebookType.quick => 'Nota Rápida',
      NotebookType.organized => 'Organizado',
      NotebookType.reminder => 'Lembrete',
      _ => 'Caderno',
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.isLoading && widget.viewModel.notebooks == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final width = MediaQuery.of(context).size.width * 0.85;

    return DSDataTableContainer(
      width: width,
      searchField: Row(
        children: [
          Expanded(
            child: DSTableSearchField(
              hintText: 'Buscar cadernos...',
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.viewModel.loadNotebooks(),
            tooltip: 'Atualizar',
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _navigateToCreate,
            icon: const Icon(Icons.add),
            label: const Text('Novo Caderno'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
      filterBar: DSTableFilterBar<NotebookDetails>(
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
      addFiltersButtons: activeFilters.length < availableFilters.length
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                children: availableFilters
                    .where((f) => !activeFilters.contains(f))
                    .map(
                      (filter) => OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            activeFilters.add(filter);
                            _applyFilters();
                          });
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(filter.label),
                      ),
                    )
                    .toList(),
              ),
            )
          : null,
      selectionToolbar: selectionState.hasSelection
          ? DSTableSelectionToolbar(
              selectedCount: selectionState.selectedCount,
              actions: [
                DSTableAction(
                  icon: Icons.delete,
                  onPressed: () {
                    for (final notebook in selectionState.selectedItems) {
                      widget.viewModel.deleteNotebook(notebook.id);
                    }
                    selectionState.clearSelection();
                  },
                  tooltip: 'Excluir selecionados',
                ),
              ],
              onClearSelection: selectionState.clearSelection,
            )
          : null,
      dataTable: DSDataTable<NotebookDetails>(
        data: paginationController.currentItems,
        sortColumnIndex: sortState.sortColumnIndex,
        sortAscending: sortState.sortAscending,
        onSort: (columnIndex, ascending) {
          sortState.sort(columnIndex);
        },
        showCheckboxColumn: true,
        onSelectChanged: (notebook) {
          selectionState.toggle(notebook);
        },
        columns: [
          DSDataTableColumn<NotebookDetails>(
            label: 'CADERNO',
            builder: (notebook) => DSTableCellWithIcon(
              icon: _getIconForType(notebook.type),
              iconBackgroundColor: _getColorForType(notebook.type),
              title: notebook.title,
              subtitle: _getTypeLabel(notebook.type),
            ),
          ),
          DSDataTableColumn<NotebookDetails>(
            label: 'TIPO',
            builder: (notebook) => Text(
              _getTypeLabel(notebook.type),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          DSDataTableColumn<NotebookDetails>(
            label: 'DATA',
            builder: (notebook) => Text(
              _formatDate(notebook.createdAt),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          DSDataTableColumn<NotebookDetails>(
            label: 'AÇÕES',
            builder: (notebook) => DSTableActions(
              actions: [
                DSTableAction(
                  icon: Icons.visibility,
                  onPressed: () => _navigateToDetail(notebook),
                  tooltip: 'Ver detalhes',
                ),
                DSTableAction(
                  icon: Icons.edit,
                  onPressed: () => _navigateToEdit(notebook),
                  tooltip: 'Editar',
                ),
                DSTableAction(
                  icon: Icons.delete_outline,
                  onPressed: () => _confirmDelete(notebook),
                  tooltip: 'Deletar',
                ),
              ],
            ),
          ),
        ],
      ),
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
