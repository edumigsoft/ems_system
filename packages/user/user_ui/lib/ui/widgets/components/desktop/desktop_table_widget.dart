import 'package:core_shared/core_shared.dart' show UserRole;
import 'package:core_ui/core_ui.dart' show UserRoleExtension;
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:user_shared/user_shared.dart';
import '../../../../view_models/manage_users_view_model.dart';
import '../../../../pages/manage_users_form_page.dart';
import '../../dialogs/dialogs.dart';

/// Tabela desktop para gerenciamento de usuários.
///
/// DSDataTableContainer com sorting, filtros por role, paginação.
class DesktopTableWidget extends StatefulWidget {
  final ManageUsersViewModel viewModel;

  const DesktopTableWidget({super.key, required this.viewModel});

  @override
  State<DesktopTableWidget> createState() => _DesktopTableWidgetState();
}

class _DesktopTableWidgetState extends State<DesktopTableWidget> {
  late List<UserDetails> allUsers;
  late List<UserDetails> filteredUsers;
  late DSPaginationController<UserDetails> paginationController;
  late DSDataTableSortState sortState;
  late DSTableSelectionState<UserDetails> selectionState;

  String searchQuery = '';
  List<DSTableFilter<UserDetails>> activeFilters = [];
  List<DSTableFilter<UserDetails>> availableFilters = [];

  @override
  void initState() {
    super.initState();
    _updateData();

    availableFilters = [
      DSTableFilter<UserDetails>(
        id: 'role_admin',
        label: 'Admin',
        predicate: (u) => u.role == UserRole.admin,
      ),
      DSTableFilter<UserDetails>(
        id: 'role_manager',
        label: 'Manager',
        predicate: (u) => u.role == UserRole.manager,
      ),
      DSTableFilter<UserDetails>(
        id: 'role_user',
        label: 'Usuário',
        predicate: (u) => u.role == UserRole.user,
      ),
    ];

    filteredUsers = allUsers;
    sortState = DSDataTableSortState();
    selectionState = DSTableSelectionState<UserDetails>();
    paginationController = DSPaginationController(
      allItems: filteredUsers,
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
    allUsers = widget.viewModel.users;
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
    filteredUsers = allUsers.where((user) {
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!user.name.toLowerCase().contains(query) &&
            !user.email.toLowerCase().contains(query) &&
            !user.username.toLowerCase().contains(query)) {
          return false;
        }
      }
      for (final filter in activeFilters) {
        if (!filter.predicate(user)) return false;
      }
      return true;
    }).toList();

    if (sortState.isSorted) {
      _applySortingToList(filteredUsers);
    }

    paginationController = DSPaginationController(
      allItems: filteredUsers,
      itemsPerPage: paginationController.itemsPerPage,
    );

    setState(() {});
  }

  void _applySorting() {
    if (sortState.isSorted) {
      _applySortingToList(filteredUsers);
      paginationController = DSPaginationController(
        allItems: filteredUsers,
        itemsPerPage: paginationController.itemsPerPage,
      );
    }
    setState(() {});
  }

  void _applySortingToList(List<UserDetails> list) {
    final columnIndex = sortState.sortColumnIndex!;
    final ascending = sortState.sortAscending;

    list.sort((a, b) {
      int comparison = 0;
      switch (columnIndex) {
        case 0:
          comparison = a.name.compareTo(b.name);
        case 1:
          comparison = a.email.compareTo(b.email);
        case 2:
          comparison = a.role.index.compareTo(b.role.index);
        case 3:
          comparison = (a.isActive ? 0 : 1).compareTo(b.isActive ? 0 : 1);
        default:
          comparison = 0;
      }
      return ascending ? comparison : -comparison;
    });
  }

  Future<void> _navigateToEdit(UserDetails user) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ManageUsersFormPage(
          viewModel: widget.viewModel,
          user: user,
        ),
      ),
    );
    if (mounted) widget.viewModel.loadUsers(refresh: true);
  }

  Future<void> _navigateToCreate() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            ManageUsersFormPage(viewModel: widget.viewModel),
      ),
    );
    if (mounted) widget.viewModel.loadUsers(refresh: true);
  }

  Future<void> _confirmDelete(UserDetails user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => UserDeleteConfirmDialog(user: user),
    );
    if (confirmed == true && mounted) {
      final success = await widget.viewModel.deleteUser(user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Usuário deletado com sucesso'
                  : widget.viewModel.error ?? 'Erro ao deletar usuário',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmResetPassword(UserDetails user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => UserResetPasswordDialog(user: user),
    );
    if (confirmed == true && mounted) {
      final success = await widget.viewModel.resetUserPassword(user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Senha resetada. ${user.name} deverá alterar a senha no próximo login.'
                  : widget.viewModel.error ?? 'Erro ao resetar senha',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: Duration(seconds: success ? 4 : 3),
          ),
        );
      }
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
              hintText: 'Buscar por nome, email ou username...',
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
            onPressed: widget.viewModel.isLoading
                ? null
                : () => widget.viewModel.loadUsers(refresh: true),
            tooltip: 'Atualizar',
          ),
          const SizedBox(width: 8),
          if (widget.viewModel.isOwner)
            ElevatedButton.icon(
              onPressed: _navigateToCreate,
              icon: const Icon(Icons.person_add),
              label: const Text('Adicionar'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
        ],
      ),
      filterBar: DSTableFilterBar<UserDetails>(
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
                    for (final user in selectionState.selectedItems) {
                      widget.viewModel.deleteUser(user.id);
                    }
                    selectionState.clearSelection();
                  },
                  tooltip: 'Excluir selecionados',
                ),
              ],
              onClearSelection: selectionState.clearSelection,
            )
          : null,
      dataTable: DSDataTable<UserDetails>(
        data: paginationController.currentItems,
        sortColumnIndex: sortState.sortColumnIndex,
        sortAscending: sortState.sortAscending,
        onSort: (columnIndex, ascending) {
          sortState.sort(columnIndex);
        },
        showCheckboxColumn: true,
        onSelectChanged: (user) {
          selectionState.toggle(user);
        },
        columns: [
          DSDataTableColumn<UserDetails>(
            label: 'USUÁRIO',
            builder: (user) => DSTableCellWithIcon(
              icon: Icons.person,
              iconBackgroundColor:
                  user.isActive ? Colors.blue : Colors.grey,
              title: user.name,
              subtitle: '@${user.username}',
            ),
          ),
          DSDataTableColumn<UserDetails>(
            label: 'CONTATO',
            builder: (user) => DSTableCellTwoLines(
              primary: user.email,
              secondary: user.phone ?? '—',
            ),
          ),
          DSDataTableColumn<UserDetails>(
            label: 'FUNÇÃO',
            builder: (user) => Text(
              user.role.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          DSDataTableColumn<UserDetails>(
            label: 'STATUS',
            builder: (user) => DSTableStatusIndicator(
              label: user.isActive ? 'Ativo' : 'Inativo',
              color: user.isActive ? Colors.green : Colors.red,
            ),
          ),
          DSDataTableColumn<UserDetails>(
            label: 'AÇÕES',
            builder: (user) => DSTableActions(
              actions: [
                DSTableAction(
                  icon: Icons.edit,
                  onPressed: () => _navigateToEdit(user),
                  tooltip: 'Editar',
                ),
                if (widget.viewModel.isOwner && !user.isDeleted)
                  DSTableAction(
                    icon: Icons.delete_outline,
                    onPressed: () => _confirmDelete(user),
                    tooltip: 'Deletar',
                  ),
                if (widget.viewModel.canResetPassword(user))
                  DSTableAction(
                    icon: Icons.lock_reset,
                    onPressed: () => _confirmResetPassword(user),
                    tooltip: 'Resetar senha',
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
