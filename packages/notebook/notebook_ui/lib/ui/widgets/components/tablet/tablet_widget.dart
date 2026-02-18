import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart' show GetItInjector;
import 'package:notebook_shared/notebook_shared.dart';
import '../../../../view_models/notebook_list_view_model.dart';
import '../../../../view_models/notebook_detail_view_model.dart';
import '../../../../view_models/notebook_create_view_model.dart';
import '../../../../widgets/notebook_card.dart';
import '../../../../pages/notebook_detail_page.dart';
import '../../../../pages/notebook_form_page.dart';
import '../../dialogs/dialogs.dart';

/// Widget tablet para listagem e gerenciamento de cadernos.
///
/// Scaffold + AppBar + FAB. GridView 2 colunas com ações de edição.
class TabletWidget extends StatefulWidget {
  final NotebookListViewModel viewModel;

  const TabletWidget({super.key, required this.viewModel});

  @override
  State<TabletWidget> createState() => _TabletWidgetState();
}

class _TabletWidgetState extends State<TabletWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadernos'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<NotebookSortOrder>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            onSelected: (order) => widget.viewModel.setSortOrder(order),
            itemBuilder: (context) => [
              _sortItem(
                NotebookSortOrder.recentFirst,
                'Mais Recentes',
                Icons.calendar_today,
              ),
              _sortItem(
                NotebookSortOrder.oldestFirst,
                'Mais Antigas',
                Icons.history,
              ),
              const PopupMenuDivider(),
              _sortItem(
                NotebookSortOrder.alphabetical,
                'A → Z',
                Icons.sort_by_alpha,
              ),
              _sortItem(
                NotebookSortOrder.reverseAlphabetical,
                'Z → A',
                Icons.sort_by_alpha,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.viewModel.loadNotebooks,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.add),
        label: const Text('Novo Caderno'),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) => _buildBody(context),
      ),
    );
  }

  PopupMenuItem<NotebookSortOrder> _sortItem(
    NotebookSortOrder order,
    String label,
    IconData icon,
  ) {
    final isSelected = widget.viewModel.sortOrder == order;
    return PopupMenuItem(
      value: order,
      child: Row(
        children: [
          Icon(isSelected ? Icons.check : icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.viewModel.isLoading && widget.viewModel.notebooks == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.viewModel.error != null && widget.viewModel.notebooks == null) {
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
            Text(widget.viewModel.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: widget.viewModel.loadNotebooks,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final notebooks = widget.viewModel.filteredNotebooks;
    final tagsMap = {
      for (final tag in widget.viewModel.availableTags) tag.id: tag,
    };

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
            const SizedBox(height: 8),
            const Text('Clique no botão + para criar seu primeiro caderno'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: notebooks.length,
      itemBuilder: (context, index) {
        final notebook = notebooks[index];
        return NotebookCard(
          notebook: notebook,
          tagsMap: tagsMap,
          onTap: () => _navigateToDetail(notebook.id),
          onDelete: () => _confirmDelete(notebook),
        );
      },
    );
  }

  Future<void> _navigateToCreate() async {
    NotebookCreate? toCreate;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => NotebookFormPage(
          onCreate: (create) => toCreate = create,
        ),
      ),
    );
    if (result == true && toCreate != null && mounted) {
      final createVm = GetItInjector().get<NotebookCreateViewModel>();
      await createVm.createNotebook(toCreate!);
      widget.viewModel.loadNotebooks();
    }
  }

  Future<void> _navigateToDetail(String notebookId) async {
    final detailVm = GetItInjector().get<NotebookDetailViewModel>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => NotebookDetailPage(
          viewModel: detailVm,
          notebookId: notebookId,
        ),
      ),
    );
    if (mounted) widget.viewModel.loadNotebooks();
  }

  Future<void> _confirmDelete(NotebookDetails notebook) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          NotebookDeleteConfirmDialog(notebookTitle: notebook.title),
    );
    if (confirmed == true && mounted) {
      final success = await widget.viewModel.deleteNotebook(notebook.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Caderno excluído com sucesso'
                  : (widget.viewModel.error ?? 'Erro ao excluir caderno'),
            ),
            backgroundColor:
                success ? null : Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
