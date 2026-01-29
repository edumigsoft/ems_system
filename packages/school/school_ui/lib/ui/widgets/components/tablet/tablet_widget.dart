import 'package:flutter/material.dart';
import '../../../../school_ui.dart';

class TabletWidget extends StatelessWidget {
  final SchoolViewModel viewModel;
  const TabletWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schools')),
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
                        child: InkWell(
                          onTap: () => viewModel.detailsCommand.execute(school),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        school.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
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
                                  'Code: ${school.code}',
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
