import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';
import '../view_models/notebook_detail_view_model.dart';
import '../widgets/tag_input_widget.dart';

/// Diálogo modal para edição de caderno.
class NotebookEditDialog extends StatefulWidget {
  final NotebookDetails notebook;
  final NotebookDetailViewModel viewModel;

  const NotebookEditDialog({
    super.key,
    required this.notebook,
    required this.viewModel,
  });

  @override
  State<NotebookEditDialog> createState() => _NotebookEditDialogState();
}

class _NotebookEditDialogState extends State<NotebookEditDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // Tags
  final List<String> _tags = [];

  // Reminder
  DateTime? _reminderDate;
  TimeOfDay? _reminderTime;
  bool _notifyOnReminder = true;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _titleController.text = widget.notebook.title;
    _contentController.text = widget.notebook.content;

    if (widget.notebook.tags != null) {
      _tags.addAll(widget.notebook.tags!);
    }

    _reminderDate = widget.notebook.reminderDate;
    if (_reminderDate != null) {
      _reminderTime = TimeOfDay.fromDateTime(_reminderDate!);
    }
    _notifyOnReminder = widget.notebook.notifyOnReminder ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Editar Caderno',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Formulário
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          hintText: 'Digite o título',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'O título é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Conteúdo
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Conteúdo',
                          hintText: 'Digite o conteúdo',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'O conteúdo é obrigatório';
                          }
                          return null;
                        },
                        maxLines: widget.notebook.type == NotebookType.quick
                            ? 5
                            : 8,
                        minLines: 3,
                      ),

                      // Tags (apenas se for organizado)
                      if (widget.notebook.type == NotebookType.organized) ...[
                        const SizedBox(height: 16),
                        TagInputWidget(
                          selectedTags: _tags,
                          onTagsChanged: (tags) {
                            setState(() {
                              _tags.clear();
                              _tags.addAll(tags);
                            });
                          },
                          onSearchTags: (query) async {
                            // Retorna lista de nomes de tags disponíveis
                            final availableTagNames = widget.viewModel.availableTags
                                .map((tag) => tag.name)
                                .toList();
                            return availableTagNames
                                .where(
                                  (name) => name.toLowerCase().contains(
                                    query.toLowerCase(),
                                  ),
                                )
                                .toList();
                          },
                        ),
                      ],

                      // Reminder (apenas se for lembrete)
                      if (widget.notebook.type == NotebookType.reminder) ...[
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            _reminderDate == null
                                ? 'Selecionar data do lembrete'
                                : 'Data: ${_formatDate(_reminderDate!)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _pickDate,
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.access_time),
                          title: Text(
                            _reminderTime == null
                                ? 'Selecionar horário'
                                : 'Horário: ${_reminderTime!.format(context)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _pickTime,
                        ),
                        const Divider(),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Notificar no horário definido'),
                          value: _notifyOnReminder,
                          onChanged: (value) {
                            setState(() => _notifyOnReminder = value);
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botões de ação
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _reminderDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.notebook.type == NotebookType.reminder) {
      if (_reminderDate == null) {
        _showError('Selecione a data do lembrete');
        return;
      }
      if (_reminderTime == null) {
        _showError('Selecione o horário do lembrete');
        return;
      }
    }

    setState(() => _isSaving = true);

    DateTime? reminderDateTime;
    if (_reminderDate != null && _reminderTime != null) {
      reminderDateTime = DateTime(
        _reminderDate!.year,
        _reminderDate!.month,
        _reminderDate!.day,
        _reminderTime!.hour,
        _reminderTime!.minute,
      );
    }

    final update = NotebookUpdate(
      id: widget.notebook.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      tags: widget.notebook.type == NotebookType.organized ? _tags : null,
      reminderDate: reminderDateTime,
      notifyOnReminder: _notifyOnReminder,
    );

    final success = await widget.viewModel.updateNotebook(update);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caderno atualizado com sucesso')),
      );
    } else {
      _showError(widget.viewModel.error ?? 'Erro ao atualizar caderno');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
