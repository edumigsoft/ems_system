import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:core_shared/core_shared.dart' show GetItInjector;
import 'package:tag_ui/tag_ui.dart';

import '../../../../view_models/notebook_list_view_model.dart';
import '../../../../view_models/notebook_detail_view_model.dart';
import '../../../../widgets/notebook_create_dialog.dart';
import '../../../../widgets/notebook_edit_dialog.dart';
import '../../dialogs/dialogs.dart';
import 'desktop_table_widget.dart';

/// Layout master-detail para desktop/tablet.
///
/// Painel esquerdo (45%): DesktopTableWidget com callbacks.
/// Painel direito (55%): detalhe do notebook selecionado ou placeholder.
/// CRUD via dialogs; sem Navigator.push.
class DesktopSplitWidget extends StatefulWidget {
  final NotebookListViewModel viewModel;

  const DesktopSplitWidget({super.key, required this.viewModel});

  @override
  State<DesktopSplitWidget> createState() => _DesktopSplitWidgetState();
}

class _DesktopSplitWidgetState extends State<DesktopSplitWidget> {
  NotebookDetails? _selectedNotebook;
  NotebookDetailViewModel? _detailViewModel;

  Future<void> _handleCreateTap() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => const NotebookCreateDialog(),
    );
    if (created == true && mounted) {
      widget.viewModel.loadNotebooks();
    }
  }

  Future<void> _handleEditTap(NotebookDetails notebook) async {
    final detailVm =
        _detailViewModel ?? GetItInjector().get<NotebookDetailViewModel>();
    if (_detailViewModel == null) {
      await detailVm.loadNotebook(notebook.id);
    }
    if (!mounted) return;
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => NotebookEditDialog(
        notebook: notebook,
        viewModel: detailVm,
      ),
    );
    if (updated == true && mounted) {
      widget.viewModel.loadNotebooks();
      if (_selectedNotebook?.id == notebook.id) {
        detailVm.loadNotebook(notebook.id);
      }
    }
  }

  void _handleViewTap(NotebookDetails notebook) {
    final detailVm = GetItInjector().get<NotebookDetailViewModel>();
    setState(() {
      _selectedNotebook = notebook;
      _detailViewModel = detailVm;
    });
    detailVm.loadNotebook(notebook.id).then((_) {
      if (mounted) detailVm.loadAvailableTags();
    });
  }

  Future<void> _handleDeleteSelected() async {
    final notebook = _selectedNotebook;
    if (notebook == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          NotebookDeleteConfirmDialog(notebookTitle: notebook.title),
    );
    if (confirmed == true && mounted) {
      final success = await widget.viewModel.deleteNotebook(notebook.id);
      if (mounted) {
        if (success) {
          setState(() {
            _selectedNotebook = null;
            _detailViewModel = null;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Caderno excluído com sucesso'
                  : (widget.viewModel.error ?? 'Erro ao excluir caderno'),
            ),
            backgroundColor: success
                ? null
                : Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Painel esquerdo — tabela
        Expanded(
          flex: 45,
          child: DesktopTableWidget(
            viewModel: widget.viewModel,
            onCreateTap: _handleCreateTap,
            onEditTap: _handleEditTap,
            onViewTap: _handleViewTap,
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        // Painel direito — detalhe
        Expanded(
          flex: 55,
          child: _selectedNotebook == null || _detailViewModel == null
              ? const _EmptyDetailPlaceholder()
              : _EmbeddedDetailPanel(
                  notebook: _selectedNotebook!,
                  viewModel: _detailViewModel!,
                  onClose: () => setState(() {
                    _selectedNotebook = null;
                    _detailViewModel = null;
                  }),
                  onEdit: () => _handleEditTap(_selectedNotebook!),
                  onDelete: _handleDeleteSelected,
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Placeholder quando nenhum item está selecionado
// ─────────────────────────────────────────────

class _EmptyDetailPlaceholder extends StatelessWidget {
  const _EmptyDetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 72,
            color: theme.colorScheme.onSurface.withAlpha(48),
          ),
          const SizedBox(height: 16),
          Text(
            'Selecione um caderno',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(128),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique em um caderno na lista para ver os detalhes',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(96),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Painel de detalhe embutido (sem Scaffold/DSCardHeader)
// ─────────────────────────────────────────────

class _EmbeddedDetailPanel extends StatelessWidget {
  final NotebookDetails notebook;
  final NotebookDetailViewModel viewModel;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmbeddedDetailPanel({
    required this.notebook,
    required this.viewModel,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barra de título inline
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  notebook.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
                tooltip: 'Editar',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                tooltip: 'Excluir',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                tooltip: 'Fechar painel',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => _buildContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    if (viewModel.isLoading && viewModel.notebook == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null && viewModel.notebook == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Erro ao carregar detalhes',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    final nb = viewModel.notebook ?? notebook;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chips de metadata
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: Icon(_iconForType(nb.type), size: 16),
                label: Text(_labelForType(nb.type)),
                visualDensity: VisualDensity.compact,
              ),
              Chip(
                avatar: const Icon(Icons.calendar_today, size: 16),
                label: Text(_formatDate(nb.createdAt)),
                visualDensity: VisualDensity.compact,
              ),
              if (nb.updatedAt != nb.createdAt)
                Chip(
                  avatar: const Icon(Icons.update, size: 16),
                  label: Text('Atualizado: ${_formatDate(nb.updatedAt)}'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Lembrete
          if (nb.type == NotebookType.reminder && nb.reminderDate != null) ...[
            Card(
              color: nb.isReminderOverdue
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      nb.isReminderOverdue
                          ? Icons.warning_amber
                          : Icons.notifications_active,
                      color: nb.isReminderOverdue
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nb.isReminderOverdue
                                ? 'Lembrete Atrasado'
                                : 'Lembrete',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: nb.isReminderOverdue
                                  ? theme.colorScheme.onErrorContainer
                                  : theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            _formatDateTime(nb.reminderDate!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: nb.isReminderOverdue
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

          // Tags
          if (nb.tags != null && nb.tags!.isNotEmpty) ...[
            Text('Tags', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: nb.tags!.map((tagId) {
                final tagDetails = viewModel.availableTags
                    .where((t) => t.id == tagId)
                    .firstOrNull;
                if (tagDetails != null) {
                  return TagChip(tag: tagDetails);
                }
                return Chip(
                  label: Text(tagId),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Conteúdo
          Text('Conteúdo', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                nb.content.isNotEmpty ? nb.content : 'Sem conteúdo',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(NotebookType? type) {
    return switch (type) {
      NotebookType.quick => Icons.flash_on,
      NotebookType.organized => Icons.folder_special,
      NotebookType.reminder => Icons.notifications_active,
      _ => Icons.note,
    };
  }

  String _labelForType(NotebookType? type) {
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

  String _formatDateTime(DateTime dt) {
    final date = _formatDate(dt);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$date às $h:$m';
  }
}
