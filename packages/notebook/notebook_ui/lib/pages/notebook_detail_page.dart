import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';

import '../view_models/notebook_detail_view_model.dart';
import '../widgets/document_list_widget.dart';

/// Página de detalhes de um caderno.
///
/// Recebe ViewModel via construtor (DI).
class NotebookDetailPage extends StatefulWidget {
  final NotebookDetailViewModel viewModel;
  final String notebookId;

  const NotebookDetailPage({
    super.key,
    required this.viewModel,
    required this.notebookId,
  });

  @override
  State<NotebookDetailPage> createState() => _NotebookDetailPageState();
}

class _NotebookDetailPageState extends State<NotebookDetailPage> {
  @override
  void initState() {
    super.initState();
    // Carrega caderno ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadNotebook(widget.notebookId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Caderno'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _handleDelete(context),
            tooltip: 'Excluir',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return _buildBody(context, theme);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    // Estado de loading
    if (widget.viewModel.isLoading && widget.viewModel.notebook == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Estado de erro
    if (widget.viewModel.error != null && widget.viewModel.notebook == null) {
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
              'Erro ao carregar caderno',
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
              onPressed: () => widget.viewModel.loadNotebook(widget.notebookId),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final notebook = widget.viewModel.notebook;
    if (notebook == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            notebook.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Metadata (tipo, data)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: Icon(
                  _getIconForType(notebook.type),
                  size: 18,
                ),
                label: Text(_getLabelForType(notebook.type)),
              ),
              Chip(
                avatar: const Icon(Icons.calendar_today, size: 18),
                label: Text(_formatDate(notebook.createdAt)),
              ),
              Chip(
                avatar: const Icon(Icons.update, size: 18),
                label: Text(
                  'Atualizado: ${_formatDate(notebook.updatedAt)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tags
          if (notebook.tags != null && notebook.tags!.isNotEmpty) ...[
            Text(
              'Tags',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: notebook.tags!.map((tag) {
                return Chip(label: Text('#$tag'));
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Conteúdo
          Text(
            'Conteúdo',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                notebook.content.isNotEmpty ? notebook.content : 'Sem conteúdo',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Documentos anexados
          Text(
            'Documentos Anexados',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DocumentListWidget(
            documents: widget.viewModel.documents ?? [],
            onDelete: (docId) => _handleDeleteDocument(context, docId),
          ),
        ],
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

  String _getLabelForType(NotebookType? type) {
    return switch (type) {
      NotebookType.quick => 'Nota Rápida',
      NotebookType.organized => 'Organizado',
      NotebookType.reminder => 'Lembrete',
      _ => 'Caderno',
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    // Implementar navegação para edição
    // Quando a página de edição for implementada, seguir o mesmo padrão:
    // final formViewModel = GetItInjector().get<NotebookFormViewModel>();
    // await Navigator.of(context).push<void>(
    //   MaterialPageRoute<void>(
    //     builder: (context) => NotebookFormPage(
    //       viewModel: formViewModel,
    //       notebookId: widget.notebookId,
    //     ),
    //   ),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Função de edição ainda não implementada')),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir este caderno?',
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
      // Navega de volta antes de deletar
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleDeleteDocument(
    BuildContext context,
    String documentId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este documento?'),
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
      final success = await widget.viewModel.deleteDocument(documentId);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento excluído com sucesso')),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.viewModel.error ?? 'Erro ao excluir documento',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
