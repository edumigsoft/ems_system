import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:tag_ui/tag_ui.dart';
import 'package:tag_shared/tag_shared.dart';

import '../view_models/notebook_detail_view_model.dart';
import '../widgets/document_list_widget.dart';
import '../widgets/expansion_card_widget.dart';
import '../widgets/notebook_hierarchy_widget.dart';
import '../widgets/document_upload_widget.dart';
import '../widgets/notebook_edit_dialog.dart';
// O DocumentUploadWidget usa DocumentAddResult que deve estar acessível.

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
  bool _isMissingFieldsDismissed = false;

  @override
  void initState() {
    super.initState();
    // Carrega caderno ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadNotebook(widget.notebookId).then((_) {
        // Carrega hierarquia após carregar o caderno
        widget.viewModel.loadParent();
        widget.viewModel.loadChildren();
        // Carrega tags disponíveis para resolver nomes e cores
        widget.viewModel.loadAvailableTags();
      });
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
            onPressed: _navigateToEdit,
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _handleDelete,
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

          // Card de Expansão (Campos faltantes)
          if (_getMissingFields(notebook).isNotEmpty &&
              !_isMissingFieldsDismissed) ...[
            const SizedBox(height: 8),
            ExpansionCardWidget(
              missingFields: _getMissingFields(notebook),
              onExpand: _navigateToEdit,
              onDismiss: () {
                setState(() {
                  _isMissingFieldsDismissed = true;
                });
              },
              dismissible: true,
            ),
            const SizedBox(height: 8),
          ],

          // Tags
          if (notebook.tags != null && notebook.tags!.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tags',
                  style: theme.textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _showManageTagsDialog,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Gerenciar'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...notebook.tags!.map((tagId) {
                  // Tenta encontrar detalhes da tag
                  final tagDetails = widget.viewModel.availableTags
                      .where((t) => t.id == tagId)
                      .firstOrNull;

                  if (tagDetails != null) {
                    return TagChip(
                      tag: tagDetails,
                      showDelete: true,
                      onDelete: () =>
                          widget.viewModel.removeTagFromNotebook(tagId),
                    );
                  }

                  // Fallback para ID se não encontrar detalhes
                  return Chip(
                    // Using generic Chip from material
                    label: Text(tagId),
                    onDeleted: () =>
                        widget.viewModel.removeTagFromNotebook(tagId),
                  );
                }),
                // Botão rápido de adicionar
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar'),
                  onPressed: _showManageTagsDialog,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ] else ...[
            // Caso sem tags, mostra botão para adicionar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tags',
                  style: theme.textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _showManageTagsDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Lembrete Destacado
          if (notebook.type == NotebookType.reminder &&
              notebook.reminderDate != null) ...[
            Card(
              color: notebook.isReminderOverdue
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      notebook.isReminderOverdue
                          ? Icons.warning_amber
                          : Icons.notifications_active,
                      color: notebook.isReminderOverdue
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notebook.isReminderOverdue
                                ? 'Lembrete Atrasado'
                                : 'Lembrete',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: notebook.isReminderOverdue
                                  ? theme.colorScheme.onErrorContainer
                                  : theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            _formatDateTime(notebook.reminderDate!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: notebook.isReminderOverdue
                                  ? theme.colorScheme.onErrorContainer
                                  : theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Hierarquia
          if (widget.viewModel.parentNotebook != null ||
              (widget.viewModel.childNotebooks?.isNotEmpty ?? false)) ...[
            Text('Hierarquia', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            NotebookHierarchyWidget(
              notebooks: _buildHierarchyList(),
              currentNotebookId: notebook.id,
              onNotebookTap: (id) {
                if (id != notebook.id) {
                  // Navega para o outro caderno
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (context) => NotebookDetailPage(
                        viewModel: widget
                            .viewModel, // Ideal seria nova instancia ou reset, mas ok por agora
                        notebookId: id,
                      ),
                    ),
                  );
                }
              },
              maxDepth: 3,
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

          // Upload de Documentos
          DocumentUploadWidget(
            onDocumentAdded: _handleDocumentAdded,
            maxSizeMB: 50,
            allowedExtensions: const [
              'pdf',
              'doc',
              'docx',
              'jpg',
              'png',
              'jpeg',
            ],
            enabled: !widget.viewModel.isUploadingDocument,
          ),

          const SizedBox(height: 16),

          DocumentListWidget(
            documents: widget.viewModel.documents ?? [],
            onDelete: _handleDeleteDocument,
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

  Future<void> _navigateToEdit() async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => NotebookEditDialog(
        notebook: widget.viewModel.notebook!,
        viewModel: widget.viewModel,
      ),
    );

    if (updated == true && mounted) {
      widget.viewModel.loadNotebook(widget.notebookId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caderno atualizado')),
      );
    }
  }

  Future<void> _handleDelete() async {
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

    if (confirmed == true && mounted) {
      // Navega de volta antes de deletar
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleDeleteDocument(
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

    if (confirmed == true && mounted) {
      final success = await widget.viewModel.deleteDocument(documentId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento excluído com sucesso')),
        );
      } else if (mounted) {
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

  List<String> _getMissingFields(NotebookDetails notebook) {
    final missing = <String>[];

    if (notebook.tags == null || notebook.tags!.isEmpty) {
      missing.add('Tags');
    }
    if (notebook.projectId == null) {
      missing.add('Projeto');
    }
    if (notebook.parentId == null) {
      missing.add('Caderno Pai');
    }
    if (notebook.reminderDate == null &&
        notebook.type == NotebookType.reminder) {
      missing.add('Data do Lembrete');
    }

    return missing;
  }

  List<NotebookDetails> _buildHierarchyList() {
    final list = <NotebookDetails>[];

    if (widget.viewModel.parentNotebook != null) {
      list.add(widget.viewModel.parentNotebook!);
    }

    if (widget.viewModel.notebook != null) {
      list.add(widget.viewModel.notebook!);
    }

    if (widget.viewModel.childNotebooks != null) {
      list.addAll(widget.viewModel.childNotebooks!);
    }

    return list;
  }

  String _formatDateTime(DateTime dateTime) {
    final date = _formatDate(dateTime);
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$date às $hour:$minute';
  }

  Future<void> _handleDocumentAdded(
    DocumentAddResult result,
  ) async {
    bool success = false;

    if (result.type == DocumentAddType.upload) {
      // Upload de arquivo
      final file = result.file!.files.single;
      success = await widget.viewModel.uploadDocument(
        filePath: file.path!,
        fileName: result.name,
        mimeType: file.extension != null
            ? 'application/${file.extension}'
            : null,
      );
    } else if (result.type == DocumentAddType.url) {
      // Link externo
      success = await widget.viewModel.addDocumentReference(
        name: result.name,
        path: result.url!,
        storageType: DocumentStorageType.url,
      );
    } else if (result.type == DocumentAddType.localPath) {
      // Caminho local
      success = await widget.viewModel.addDocumentReference(
        name: result.name,
        path: result.path!,
        storageType: DocumentStorageType.local,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento adicionado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.viewModel.error ?? 'Erro ao adicionar documento',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _showManageTagsDialog() async {
    final notebook = widget.viewModel.notebook;
    if (notebook == null) return;

    // Resolve tags atuais para objetos TagDetails
    // Necessário para o TagSelector saber o que está selecionado
    final currentTags = widget.viewModel.notebookTagsWithDetails;

    // Se houver tags que não foram resolvidas (IDs sem detalhes),
    // elas infelizmente não aparecerão como selecionadas no Selector
    // pois o Selector trabalha com objetos TagDetails.
    // Mas ao salvar, pegamos a lista completa do Selector.
    // *Nota:* Tags perdidas (sem ID na lista de disponíveis) seriam removidas
    // se o usuário salvar o diálogo. Isso é comportamento aceitável para "limpeza",
    // ou deveríamos mesclar?
    // Dado que TagSelector é "o estado da verdade", vamos assumir que apenas
    // tags disponíveis podem ser selecionadas.

    List<TagDetails> newSelection = List.from(currentTags);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Gerenciar Tags'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecione as tags para este caderno:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  if (widget.viewModel.availableTags.isEmpty)
                    const Text('Nenhuma tag disponível cadastrada.')
                  else
                    TagSelector(
                      availableTags: widget.viewModel.availableTags,
                      selectedTags: newSelection,
                      onChanged: (tags) {
                        newSelection = tags;
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Atualiza o notebook com a nova lista de IDs
      final newTagIds = newSelection.map((t) => t.id).toList();
      await widget.viewModel.updateNotebook(
        NotebookUpdate(
          id: notebook.id,
          tags: newTagIds,
        ),
      );
    }
  }
}
