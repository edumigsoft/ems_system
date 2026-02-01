import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart';
import 'package:school_shared/school_shared.dart';
import '../../../../school_ui.dart';
import '../../dialogs/dialogs.dart';
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

  Future<void> _showRestoreConfirmation(
    BuildContext context,
    SchoolDetails school,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SchoolRestoreConfirmDialog(schoolName: school.name),
    );

    if (result == true && mounted) {
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

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    SchoolDetails school,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SchoolDeleteConfirmDialog(schoolName: school.name),
    );

    if (result == true && mounted) {
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

  Future<void> _navigateToCreate(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const SchoolEditPage(),
      ),
    );

    if (result == true && context.mounted) {
      // Recarregar lista após criação
      widget.viewModel.refreshCommand.execute();
    }
  }

  Future<void> _navigateToEdit(
    BuildContext context,
    SchoolDetails school,
  ) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => SchoolEditPage(school: school),
      ),
    );

    if (result == true && context.mounted) {
      // Recarregar lista após edição
      widget.viewModel.refreshCommand.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.school),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(context),
        child: const Icon(Icons.add),
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
                                          ? l10n.noData
                                          : l10n.noData,
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
                                        child: Text(
                                          l10n.cancel,
                                        ), // Ou algum "clear filters" se tivesse
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
                                    widget.viewModel.detailsCommand.execute(
                                      school,
                                    );
                                    SchoolDetailsBottomSheet.show(
                                      context: context,
                                      school: school,
                                      onEdit: () {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Fechar bottom sheet
                                        _navigateToEdit(context, school);
                                      },
                                      onDelete: () {
                                        _showDeleteConfirmation(
                                          context,
                                          school,
                                        );
                                      },
                                    );
                                  },
                                  onRestore: () {
                                    _showRestoreConfirmation(
                                      context,
                                      school,
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
                                Text('${l10n.error}: ${error.toString()}'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () =>
                                      widget.viewModel.refreshCommand.execute(),
                                  child: Text(l10n.retry),
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
