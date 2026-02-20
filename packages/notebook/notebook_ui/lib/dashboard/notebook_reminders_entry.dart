import 'package:core_ui/core_ui.dart' show DashboardWidgetEntry;
import 'package:flutter/material.dart';
import 'package:notebook_client/notebook_client.dart' show NotebookApiService;
import 'package:notebook_shared/notebook_shared.dart';

/// Entry do dashboard: lista de lembretes com destaque para vencidos.
///
/// Mostra vencidos com badge vermelho e os próximos 3 com data.
/// Tap navega para NotebookDetailPage.
class NotebookRemindersEntry extends DashboardWidgetEntry {
  final NotebookApiService _service;

  NotebookRemindersEntry({required NotebookApiService service})
    : _service = service;

  @override
  String get id => 'notebook_reminders';

  @override
  String get title => 'Lembretes';

  @override
  IconData get icon => Icons.notifications_active;

  @override
  Widget build(BuildContext context) {
    return _NotebookRemindersWidget(service: _service);
  }
}

class _NotebookRemindersWidget extends StatefulWidget {
  final NotebookApiService service;

  const _NotebookRemindersWidget({required this.service});

  @override
  State<_NotebookRemindersWidget> createState() =>
      _NotebookRemindersWidgetState();
}

class _NotebookRemindersWidgetState extends State<_NotebookRemindersWidget> {
  List<NotebookDetails>? _reminders;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final models = await widget.service.getAll(type: 'reminder');
      final reminders =
          models
              .map((m) => m.toDomain())
              .where((n) => n.reminderDate != null)
              .toList()
            ..sort((a, b) => a.reminderDate!.compareTo(b.reminderDate!));
      if (mounted) {
        setState(() {
          _reminders = reminders;
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

    final reminders = _reminders ?? [];
    if (reminders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Sem lembretes',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(128),
          ),
        ),
      );
    }

    final overdue = reminders.where((n) => n.isReminderOverdue).toList();
    final upcoming = reminders
        .where((n) => !n.isReminderOverdue)
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overdue.isNotEmpty) ...[
          Row(
            children: [
              Badge(
                label: Text('${overdue.length}'),
                backgroundColor: theme.colorScheme.error,
                child: Icon(
                  Icons.warning_amber,
                  color: theme.colorScheme.error,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Vencidos',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...overdue.take(3).map((n) => _ReminderTile(notebook: n)),
          const SizedBox(height: 8),
        ],
        if (upcoming.isNotEmpty) ...[
          Text(
            'Próximos',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(160),
            ),
          ),
          const SizedBox(height: 4),
          ...upcoming.map((n) => _ReminderTile(notebook: n)),
        ],
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final NotebookDetails notebook;

  const _ReminderTile({required this.notebook});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = notebook.reminderDate;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              notebook.title,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (date != null) ...[
            const SizedBox(width: 8),
            Text(
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: notebook.isReminderOverdue
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface.withAlpha(160),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
