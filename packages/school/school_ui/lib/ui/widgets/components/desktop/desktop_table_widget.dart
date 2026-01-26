import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';

// Modelo de dados para a escola
class School {
  final String name;
  final String code;
  final String locationCity;
  final String locationDistrict;
  final String phone;
  final String email;
  final String director;
  final SchoolStatus status;
  final IconData icon;

  School({
    required this.name,
    required this.code,
    required this.locationCity,
    required this.locationDistrict,
    required this.phone,
    required this.email,
    required this.director,
    required this.status,
    required this.icon,
  });
}

// Enum para status da escola
enum SchoolStatus { active, maintenance }

// Widget que combina tabela com todas as funcionalidades do Design System
class DesktopTableWidget extends StatefulWidget {
  const DesktopTableWidget({super.key});

  @override
  State<DesktopTableWidget> createState() => _DesktopTableWidgetState();
}

class _DesktopTableWidgetState extends State<DesktopTableWidget> {
  late List<School> allSchools;
  late List<School> filteredSchools;
  late DSPaginationController<School> paginationController;
  late DSDataTableSortState sortState;
  late DSTableSelectionState<School> selectionState;

  // Estado de filtros
  String searchQuery = '';
  List<DSTableFilter<School>> activeFilters = [];
  List<DSTableFilter<School>> availableFilters = [];

  @override
  void initState() {
    super.initState();

    // Dados mockados
    allSchools = [
      School(
        name: 'Escola Est. Santos Dumont',
        code: '2024-001',
        locationCity: 'São Paulo, SP',
        locationDistrict: 'Centro',
        phone: '(11) 3322-1100',
        email: 'contato@santosdumont...',
        director: 'Marcos Oliveira',
        status: SchoolStatus.active,
        icon: Icons.school,
      ),
      School(
        name: 'Colégio Futuro Brilhante',
        code: '2024-002',
        locationCity: 'Rio de Janeiro, RJ',
        locationDistrict: 'Barra da Tijuca',
        phone: '(21) 2244-5588',
        email: 'adm@futuro.com.br',
        director: 'Fernanda Lima',
        status: SchoolStatus.active,
        icon: Icons.book,
      ),
      School(
        name: 'Escola Técnica Inovação',
        code: '2024-005',
        locationCity: 'Curitiba, PR',
        locationDistrict: 'Centro Cívico',
        phone: '(41) 3333-9999',
        email: 'tec@inovacao.edu.br',
        director: 'Roberto Almeida',
        status: SchoolStatus.maintenance,
        icon: Icons.science,
      ),
      School(
        name: 'Jardim de Infância Alegria',
        code: '2024-008',
        locationCity: 'Belo Horizonte, MG',
        locationDistrict: 'Savassi',
        phone: '(31) 3210-5050',
        email: 'contato@alegria.com',
        director: 'Ana Clara',
        status: SchoolStatus.active,
        icon: Icons.child_care,
      ),
      // Adicionando mais dados para demonstrar paginação
      ...List.generate(
        38,
        (index) => School(
          name: 'Escola ${index + 5}',
          code: '2024-${(index + 5).toString().padLeft(3, '0')}',
          locationCity: 'Cidade ${index + 5}, UF',
          locationDistrict: 'Bairro ${index + 5}',
          phone: '(99) 9999-${(index + 5000).toString()}',
          email: 'escola${index + 5}@exemplo.com',
          director: 'Diretor ${index + 5}',
          status: index % 3 == 0
              ? SchoolStatus.maintenance
              : SchoolStatus.active,
          icon: index % 4 == 0
              ? Icons.school
              : index % 4 == 1
              ? Icons.book
              : index % 4 == 2
              ? Icons.science
              : Icons.child_care,
        ),
      ),
    ];

    // Filtros disponíveis
    availableFilters = [
      DSTableFilter<School>(
        id: 'status_active',
        label: 'Ativas',
        predicate: (school) => school.status == SchoolStatus.active,
      ),
      DSTableFilter<School>(
        id: 'status_maintenance',
        label: 'Em Manutenção',
        predicate: (school) => school.status == SchoolStatus.maintenance,
      ),
    ];

    filteredSchools = allSchools;
    sortState = DSDataTableSortState();
    selectionState = DSTableSelectionState<School>();
    paginationController = DSPaginationController(
      allItems: filteredSchools,
      itemsPerPage: 5,
    );

    // Listeners
    sortState.addListener(_applySorting);
    selectionState.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    sortState.dispose();
    selectionState.dispose();
    paginationController.dispose();
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
  void _applySortingToList(List<School> list) {
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

  String _getStatusLabel(SchoolStatus status) {
    switch (status) {
      case SchoolStatus.active:
        return 'Ativa';
      case SchoolStatus.maintenance:
        return 'Manutenção';
    }
  }

  Color _getStatusColor(SchoolStatus status) {
    switch (status) {
      case SchoolStatus.active:
        return Colors.green;
      case SchoolStatus.maintenance:
        return Colors.yellow;
    }
  }

  void _editSchool(School school) {
    debugPrint('Editar escola: ${school.name}');
  }

  void _deleteSchool(School school) {
    debugPrint('Excluir escola: ${school.name}');
  }

  void _deleteSelected() {
    debugPrint('Excluir ${selectionState.selectedCount} escolas selecionadas');
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
      filterBar: DSTableFilterBar<School>(
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
      dataTable: DSDataTable<School>(
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
          DSDataTableColumn<School>(
            label: 'ESCOLA',
            builder: (school) => DSTableCellWithIcon(
              icon: school.icon,
              iconBackgroundColor: _getIconBackgroundColor(
                school.icon,
              ),
              title: school.name,
              subtitle: 'Cod: ${school.code}',
            ),
          ),
          DSDataTableColumn<School>(
            label: 'LOCALIZAÇÃO',
            builder: (school) => DSTableCellTwoLines(
              primary: school.locationCity,
              secondary: school.locationDistrict,
            ),
          ),
          DSDataTableColumn<School>(
            label: 'CONTATO',
            builder: (school) => DSTableCellTwoLines(
              primary: school.phone,
              secondary: school.email,
            ),
          ),
          DSDataTableColumn<School>(
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
          DSDataTableColumn<School>(
            label: 'STATUS',
            builder: (school) => DSTableStatusIndicator(
              label: _getStatusLabel(school.status),
              color: _getStatusColor(school.status),
            ),
          ),
          DSDataTableColumn<School>(
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
