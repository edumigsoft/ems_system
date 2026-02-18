import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart' show GetItInjector;
import 'package:notebook_shared/notebook_shared.dart';
import '../../../../view_models/notebook_list_view_model.dart';
import '../../../../view_models/notebook_detail_view_model.dart';
import '../../../../pages/notebook_detail_page.dart';

/// Widget mobile para listagem de cadernos.
///
/// Sem Scaffold — embutido no shell de navegação.
/// Read-only: apenas visualização via tap no card.
class MobileWidget extends StatelessWidget {
  final NotebookListViewModel viewModel;

  const MobileWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading && viewModel.notebooks == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null && viewModel.notebooks == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar cadernos',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(viewModel.error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: viewModel.loadNotebooks,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        final notebooks = viewModel.filteredNotebooks;

        if (notebooks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_add_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withAlpha(64),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum caderno encontrado',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notebooks.length,
          itemBuilder: (context, index) {
            final notebook = notebooks[index];
            return _ReadOnlyNotebookCard(
              notebook: notebook,
              onTap: () => _navigateToDetail(context, notebook.id),
            );
          },
        );
      },
    );
  }

  Future<void> _navigateToDetail(
    BuildContext context,
    String notebookId,
  ) async {
    final detailViewModel = GetItInjector().get<NotebookDetailViewModel>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (ctx) => NotebookDetailPage(
          viewModel: detailViewModel,
          notebookId: notebookId,
        ),
      ),
    );
    viewModel.loadNotebooks();
  }
}

/// Card de caderno somente leitura — sem ações de edição/exclusão.
class _ReadOnlyNotebookCard extends StatelessWidget {
  final NotebookDetails notebook;
  final VoidCallback onTap;

  const _ReadOnlyNotebookCard({
    required this.notebook,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getIconForType(notebook.type),
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notebook.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notebook.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(notebook.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(NotebookType? type) {
    return switch (type) {
      NotebookType.quick => Icons.flash_on,
      NotebookType.organized => Icons.folder_special,
      NotebookType.reminder => Icons.notifications_active,
      _ => Icons.note,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
