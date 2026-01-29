import 'package:flutter/material.dart';
import '../../../../school_ui.dart';

class MobileWidget extends StatelessWidget {
  final SchoolViewModel viewModel;
  const MobileWidget({super.key, required this.viewModel});

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
                  success: (schools) => ListView.builder(
                    itemCount: schools.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final school = schools[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(school.name[0].toUpperCase()),
                          ),
                          title: Text(school.name),
                          subtitle: Text(school.code),
                          trailing: Chip(
                            label: Text(school.status.name),
                            backgroundColor:
                                school.status.name == 'active'
                                    ? Colors.green.shade100
                                    : Colors.grey.shade300,
                          ),
                          onTap: () => viewModel.detailsCommand.execute(school),
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
