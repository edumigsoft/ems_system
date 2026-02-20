import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:tag_shared/tag_shared.dart';
import '../../../view_models/tag_view_model.dart';
import '../../../pages/tag_form_page.dart';
import '../../dialogs/dialogs.dart';

/// Tabela desktop para gerenciamento de tags.
///
/// DSDataTableContainer com sorting, colunas de Tag, Descrição, Status, Ações.
/// Criar via TagCreateDialog; editar via TagFormPage.
class DesktopTableWidget extends StatefulWidget {
  final TagViewModel viewModel;

  const DesktopTableWidget({super.key, required this.viewModel});

  @override
  State<DesktopTableWidget> createState() => _DesktopTableWidgetState();
}

class _DesktopTableWidgetState extends State<DesktopTableWidget> {
  late List<TagDetails> allTags;
  late List<TagDetails> filteredTags;
  late DSPaginationController<TagDetails> paginationController;
  late DSDataTableSortState sortState;
  late DSTableSelectionState<TagDetails> selectionState;

  String searchQuery = '';
  List<DSTableFilter<TagDetails>> activeFilters = [];
  List<DSTableFilter<TagDetails>> availableFilters = [];

  @override
  void initState() {
    super.initState();
    _updateData();

    availableFilters = [
      DSTableFilter<TagDetails>(
        id: 'status_active',
        label: 'Ativas',
        predicate: (t) => t.isActive && !t.isDeleted,
      ),
      DSTableFilter<TagDetails>(
        id: 'status_inactive',
        label: 'Inativas',
        predicate: (t) => !t.isActive,
      ),
    ];

    filteredTags = allTags;
    sortState = DSDataTableSortState();
    selectionState = DSTableSelectionState<TagDetails>();
    paginationController = DSPaginationController(
      allItems: filteredTags,
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
    allTags = widget.viewModel.tags;
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
    filteredTags = allTags.where((tag) {
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!tag.name.toLowerCase().contains(query)) return false;
      }
      for (final filter in activeFilters) {
        if (!filter.predicate(tag)) return false;
      }
      return true;
    }).toList();

    if (sortState.isSorted) {
      _applySortingToList(filteredTags);
    }

    paginationController = DSPaginationController(
      allItems: filteredTags,
      itemsPerPage: paginationController.itemsPerPage,
    );

    setState(() {});
  }

  void _applySorting() {
    if (sortState.isSorted) {
      _applySortingToList(filteredTags);
      paginationController = DSPaginationController(
        allItems: filteredTags,
        itemsPerPage: paginationController.itemsPerPage,
      );
    }
    setState(() {});
  }

  void _applySortingToList(List<TagDetails> list) {
    final columnIndex = sortState.sortColumnIndex!;
    final ascending = sortState.sortAscending;

    list.sort((a, b) {
      int comparison = 0;
      switch (columnIndex) {
        case 0:
          comparison = a.name.compareTo(b.name);
        case 1:
          comparison = (a.description ?? '').compareTo(b.description ?? '');
        case 2:
          comparison =
              (a.isActive ? 0 : 1).compareTo(b.isActive ? 0 : 1);
        default:
          comparison = 0;
      }
      return ascending ? comparison : -comparison;
    });
  }

  Future<void> _showCreateDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => TagCreateDialog(viewModel: widget.viewModel),
    );
    if (created == true && mounted) {
      widget.viewModel.loadTags();
    }
  }

  Future<void> _navigateToEdit(TagDetails tag) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TagFormPage(
          viewModel: widget.viewModel,
          existingTag: tag,
        ),
      ),
    );
    if (result == true && mounted) {
      widget.viewModel.loadTags();
    }
  }

  Future<void> _confirmDelete(TagDetails tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => TagDeleteConfirmDialog(tagName: tag.name),
    );
    if (confirmed == true && mounted) {
      final success = await widget.viewModel.deleteTag(tag.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Tag deletada com sucesso'
                  : widget.viewModel.errorMessage ?? 'Erro ao deletar tag',
            ),
            backgroundColor: success ? null : Colors.red,
          ),
        );
      }
    }
  }

  Color _getTagColor(TagDetails tag) {
    if (tag.color == null || tag.color!.isEmpty) {
      return Colors.blue;
    }
    try {
      final hexColor = tag.color!.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (_) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.85;

    return DSDataTableContainer(
      width: width,
      searchField: Row(
        children: [
          Expanded(
            child: DSTableSearchField(
              hintText: 'Buscar tags...',
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
            onPressed: () => widget.viewModel.loadTags(),
            tooltip: 'Atualizar',
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add),
            label: const Text('Nova Tag'),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
      filterBar: DSTableFilterBar<TagDetails>(
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
                    for (final tag in selectionState.selectedItems) {
                      widget.viewModel.deleteTag(tag.id);
                    }
                    selectionState.clearSelection();
                  },
                  tooltip: 'Excluir selecionadas',
                ),
              ],
              onClearSelection: selectionState.clearSelection,
            )
          : null,
      dataTable: DSDataTable<TagDetails>(
        data: paginationController.currentItems,
        sortColumnIndex: sortState.sortColumnIndex,
        sortAscending: sortState.sortAscending,
        onSort: (columnIndex, ascending) {
          sortState.sort(columnIndex);
        },
        showCheckboxColumn: true,
        onSelectChanged: (tag) {
          selectionState.toggle(tag);
        },
        columns: [
          DSDataTableColumn<TagDetails>(
            label: 'TAG',
            builder: (tag) => DSTableCellWithIcon(
              icon: Icons.label,
              iconBackgroundColor: _getTagColor(tag),
              title: tag.name,
              subtitle: tag.color ?? '',
            ),
          ),
          DSDataTableColumn<TagDetails>(
            label: 'DESCRIÇÃO',
            builder: (tag) => Text(
              tag.description ?? '—',
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DSDataTableColumn<TagDetails>(
            label: 'STATUS',
            builder: (tag) => DSTableStatusIndicator(
              label: tag.isActive ? 'Ativa' : 'Inativa',
              color: tag.isActive ? Colors.green : Colors.red,
            ),
          ),
          DSDataTableColumn<TagDetails>(
            label: 'AÇÕES',
            builder: (tag) => DSTableActions(
              actions: [
                DSTableAction(
                  icon: Icons.edit,
                  onPressed: () => _navigateToEdit(tag),
                  tooltip: 'Editar',
                ),
                DSTableAction(
                  icon: Icons.delete_outline,
                  onPressed: () => _confirmDelete(tag),
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
