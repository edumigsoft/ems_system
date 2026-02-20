import 'package:core_ui/core_ui.dart' show DashboardWidgetEntry;
import 'package:flutter/material.dart';
import 'package:notebook_client/notebook_client.dart' show NotebookApiService;
import 'package:notebook_shared/notebook_shared.dart';

/// Entry do dashboard: últimas notas rápidas com trecho do conteúdo.
///
/// Mostra as 3 notas rápidas mais recentes.
/// Tap navega para NotebookDetailPage.
class NotebookQuickNotesEntry extends DashboardWidgetEntry {
  final NotebookApiService _service;

  NotebookQuickNotesEntry({required NotebookApiService service})
    : _service = service;

  @override
  String get id => 'notebook_quick_notes';

  @override
  String get title => 'Notas Rápidas';

  @override
  IconData get icon => Icons.flash_on;

  @override
  Widget build(BuildContext context) {
    return _NotebookQuickNotesWidget(service: _service);
  }
}

class _NotebookQuickNotesWidget extends StatefulWidget {
  final NotebookApiService service;

  const _NotebookQuickNotesWidget({required this.service});

  @override
  State<_NotebookQuickNotesWidget> createState() =>
      _NotebookQuickNotesWidgetState();
}

class _NotebookQuickNotesWidgetState extends State<_NotebookQuickNotesWidget> {
  List<NotebookDetails>? _notes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final models = await widget.service.getAll(type: 'quick');
      final notes = models.map((m) => m.toDomain()).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (mounted) {
        setState(() {
          _notes = notes.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final notes = _notes ?? [];
    if (notes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Sem notas rápidas',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(128),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: notes.map((note) => _QuickNoteTile(notebook: note)).toList(),
    );
  }
}

class _QuickNoteTile extends StatelessWidget {
  final NotebookDetails notebook;

  const _QuickNoteTile({required this.notebook});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final excerpt = notebook.content.length > 80
        ? '${notebook.content.substring(0, 80)}…'
        : notebook.content;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notebook.title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (excerpt.isNotEmpty)
            Text(
              excerpt,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(160),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
