import 'package:flutter/material.dart';
import '../../../../school_ui.dart';

class TabletWidget extends StatelessWidget {
  final SchoolViewModel viewModel;
  const TabletWidget({super.key, required this.viewModel});

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FilterChip(
              label: Text(
                viewModel.showDeleted ? 'Deletadas' : 'Ativas',
              ),
              selected: viewModel.showDeleted,
              onSelected: (selected) {
                viewModel.toggleShowDeletedCommand.execute();
              },
              avatar: Icon(
                viewModel.showDeleted
                    ? Icons.delete_outline
                    : Icons.check_circle_outline,
                size: 18,
              ),
            ),
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
                  success: (schools) => GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: schools.length,
                    itemBuilder: (context, index) {
                      final school = schools[index];
                      return Card(
                        color: school.isDeleted
                            ? Colors.grey.shade100
                            : null,
                        child: InkWell(
                          onTap: school.isDeleted
                              ? null
                              : () => viewModel.detailsCommand.execute(school),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  school.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        decoration: school.isDeleted
                                                            ? TextDecoration.lineThrough
                                                            : null,
                                                      ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
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
                                        ),
                                        if (!school.isDeleted)
                                          Chip(
                                            label: Text(
                                              school.status.name,
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                            backgroundColor:
                                                school.status.name == 'active'
                                                    ? Colors.green.shade100
                                                    : Colors.grey.shade300,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      school.isDeleted
                                          ? 'Code: ${school.code} (Deletada)'
                                          : 'Code: ${school.code}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      school.locationCity,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      'Director: ${school.director}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (school.isDeleted)
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(Icons.restore_from_trash),
                                    tooltip: 'Restaurar',
                                    onPressed: () {
                                      viewModel.detailsCommand.execute(school);
                                      _showRestoreConfirmation(
                                        context,
                                        school.name,
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
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
