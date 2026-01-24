import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';

import '../view_models/notebook_list_view_model.dart';
import '../widgets/notebook_card.dart';
import '../widgets/notebook_create_dialog.dart';

/// Página de listagem de cadernos.
///
/// Recebe ViewModel via construtor (DI).
class NotebookListPage extends StatefulWidget {
  final NotebookListViewModel viewModel;

  const NotebookListPage({super.key, required this.viewModel});

  @override
  State<NotebookListPage> createState() => _NotebookListPageState();
}

class _NotebookListPageState extends State<NotebookListPage> {
  @override
  void initState() {
    super.initState();
    // Carrega lista ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadNotebooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadernos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.viewModel.loadNotebooks(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return _buildBody(context, theme);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo Caderno'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    // Estado de loading
    if (widget.viewModel.isLoading && widget.viewModel.notebooks == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Estado de erro
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
            Text(
              widget.viewModel.error!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => widget.viewModel.loadNotebooks(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final notebooks = widget.viewModel.notebooks ?? [];

    // Estado vazio
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
            Text(
              'Clique no botão abaixo para criar seu primeiro caderno',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Lista de cadernos
    return RefreshIndicator(
      onRefresh: () => widget.viewModel.loadNotebooks(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notebooks.length,
        itemBuilder: (context, index) {
          final notebook = notebooks[index];
          return NotebookCard(
            notebook: notebook,
            onTap: () => _navigateToDetail(context, notebook.id),
            onDelete: () => _handleDelete(context, notebook),
          );
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String notebookId) {
    Navigator.pushNamed(
      context,
      '/notebooks/$notebookId',
      arguments: notebookId,
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    NotebookDetails notebook,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o caderno "${notebook.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await widget.viewModel.deleteNotebook(notebook.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Caderno excluído com sucesso')),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.error ?? 'Erro ao excluir caderno'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => const NotebookCreateDialog(),
    );

    if (created == true && context.mounted) {
      widget.viewModel.loadNotebooks();
    }
  }
}
