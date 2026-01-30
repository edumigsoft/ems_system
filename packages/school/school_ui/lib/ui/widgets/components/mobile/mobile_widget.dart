import 'package:flutter/material.dart';
import 'package:school_shared/school_shared.dart';
import '../../../../school_ui.dart';
import '../../shared/shared.dart';

class MobileWidget extends StatefulWidget {
  final SchoolViewModel viewModel;
  const MobileWidget({super.key, required this.viewModel});

  @override
  State<MobileWidget> createState() => _MobileWidgetState();
}

class _MobileWidgetState extends State<MobileWidget> {
  String _searchQuery = '';
  SchoolStatus? _selectedStatus;

  void _showRestoreConfirmation(BuildContext context, String schoolName) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Escola'),
        content: Text('Deseja restaurar a escola "$schoolName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.viewModel.restoreCommand.execute();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Escola "$schoolName" restaurada com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String schoolName) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Escola'),
        content: Text(
          'Deseja realmente excluir a escola "$schoolName"? '
          'Esta ação pode ser desfeita posteriormente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.viewModel.deleteCommand.execute();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Escola "$schoolName" excluída!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  List<SchoolDetails> _filterSchools(List<SchoolDetails> schools) {
    return schools.where((school) {
      // Busca textual
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!school.name.toLowerCase().contains(query) &&
            !school.code.toLowerCase().contains(query) &&
            !school.locationCity.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtro por status (apenas para escolas ativas)
      if (!widget.viewModel.showDeleted &&
          _selectedStatus != null &&
          school.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolas'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: SchoolSearchField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
          ),
          // Barra de filtros
          SchoolFiltersBar(
            selectedStatus: _selectedStatus,
            onStatusChanged: (status) {
              setState(() {
                _selectedStatus = status;
              });
            },
            showDeleted: widget.viewModel.showDeleted,
            onToggleShowDeleted: () {
              widget.viewModel.toggleShowDeletedCommand.execute();
            },
          ),
          // Lista de escolas
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await widget.viewModel.refreshCommand.execute();
              },
              child: widget.viewModel.fetchAllCommand.running
                  ? const Center(child: CircularProgressIndicator())
                  : widget.viewModel.fetchAllCommand.result?.when(
                        success: (schools) {
                          final filteredSchools = _filterSchools(schools);

                          if (filteredSchools.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.viewModel.showDeleted
                                        ? Icons.delete_outline
                                        : Icons.school_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    widget.viewModel.showDeleted
                                        ? 'Nenhuma escola deletada'
                                        : 'Nenhuma escola encontrada',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty ||
                                      _selectedStatus != null) ...[
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _searchQuery = '';
                                          _selectedStatus = null;
                                        });
                                      },
                                      child: const Text('Limpar filtros'),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: filteredSchools.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final school = filteredSchools[index];
                              return SchoolCard(
                                school: school,
                                onTap: () {
                                  widget.viewModel.detailsCommand.execute(school);
                                  SchoolDetailsBottomSheet.show(
                                    context: context,
                                    school: school,
                                    onEdit: () {
                                      widget.viewModel.editCommand.execute();
                                      // TODO: Navigate to edit page
                                    },
                                    onDelete: () {
                                      _showDeleteConfirmation(
                                        context,
                                        school.name,
                                      );
                                    },
                                  );
                                },
                                onRestore: () {
                                  widget.viewModel.detailsCommand.execute(school);
                                  _showRestoreConfirmation(
                                    context,
                                    school.name,
                                  );
                                },
                              );
                            },
                          );
                        },
                        failure: (error) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48),
                              const SizedBox(height: 16),
                              Text('Erro: ${error.toString()}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    widget.viewModel.refreshCommand.execute(),
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        ),
                      ) ??
                      const Center(child: Text('Sem dados')),
            ),
          ),
        ],
      ),
    );
  }
}
