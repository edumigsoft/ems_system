import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:tag_ui/tag_ui.dart';

import '../../../../view_models/notebook_detail_view_model.dart';

/// Detalhe de caderno embutido — ocupa toda a área disponível.
///
/// Usado por desktop e tablet para exibir o detalhe in-place,
/// sem Navigator.push nem Scaffold.
///
/// Estrutura:
///   [ ← Voltar ]  Cadernos  ›  Título  [ Editar ]  [ Excluir ]
///   ─────────────────────────────────────────────────────────
///   [ conteúdo scrollável ]
class NotebookInlineDetail extends StatelessWidget {
  final NotebookDetails notebook;
  final NotebookDetailViewModel viewModel;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NotebookInlineDetail({
    super.key,
    required this.notebook,
    required this.viewModel,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Breadcrumb + ações
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Cadernos'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  notebook.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
        const Divider(height: 1),

        // Conteúdo
        Expanded(
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => _buildContent(context, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
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
          // Metadata chips
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
                if (tagDetails != null) return TagChip(tag: tagDetails);
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

  IconData _iconForType(NotebookType? type) => switch (type) {
    NotebookType.quick => Icons.flash_on,
    NotebookType.organized => Icons.folder_special,
    NotebookType.reminder => Icons.notifications_active,
    _ => Icons.note,
  };

  String _labelForType(NotebookType? type) => switch (type) {
    NotebookType.quick => 'Nota Rápida',
    NotebookType.organized => 'Organizado',
    NotebookType.reminder => 'Lembrete',
    _ => 'Caderno',
  };

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${_formatDate(dt)} às $h:$m';
  }
}
