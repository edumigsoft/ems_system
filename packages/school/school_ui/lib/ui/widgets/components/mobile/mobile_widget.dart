import 'package:flutter/material.dart';
import '../../../../school_ui.dart';

class MobileWidget extends StatelessWidget {
  final SchoolViewModel viewModel;
  const MobileWidget({super.key, required this.viewModel});

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
              viewModel.restoreCommand.execute();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schools'),
        actions: [
          // Toggle para mostrar deletadas/ativas
          IconButton(
            icon: Icon(
              viewModel.showDeleted
                  ? Icons.check_circle_outline
                  : Icons.delete_outline,
            ),
            tooltip: viewModel.showDeleted
                ? 'Mostrar escolas ativas'
                : 'Mostrar escolas deletadas',
            onPressed: () => viewModel.toggleShowDeletedCommand.execute(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await viewModel.refreshCommand.execute();
        },
        child: viewModel.fetchAllCommand.running
            ? const Center(child: CircularProgressIndicator())
            : viewModel.fetchAllCommand.result?.when(
                  success: (schools) => ListView.builder(
                    itemCount: schools.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final school = schools[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: school.isDeleted
                            ? Colors.grey.shade100
                            : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: school.isDeleted
                                ? Colors.grey
                                : null,
                            child: Text(school.name[0].toUpperCase()),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  school.name,
                                  style: TextStyle(
                                    decoration: school.isDeleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              if (school.isDeleted)
                                Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                            ],
                          ),
                          subtitle: Text(
                            school.isDeleted
                                ? '${school.code} (Deletada)'
                                : school.code,
                          ),
                          trailing: school.isDeleted
                              ? IconButton(
                                  icon: const Icon(Icons.restore_from_trash),
                                  tooltip: 'Restaurar',
                                  onPressed: () {
                                    viewModel.detailsCommand.execute(school);
                                    _showRestoreConfirmation(
                                      context,
                                      school.name,
                                    );
                                  },
                                )
                              : Chip(
                                  label: Text(school.status.name),
                                  backgroundColor:
                                      school.status.name == 'active'
                                          ? Colors.green.shade100
                                          : Colors.grey.shade300,
                                ),
                          onTap: school.isDeleted
                              ? null
                              : () => viewModel.detailsCommand.execute(school),
                        ),
                      );
                    },
                  ),
                  failure: (error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 16),
                        Text('Error: ${error.toString()}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.refreshCommand.execute(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ) ??
                const Center(child: Text('No data')),
      ),
    );
  }
}
