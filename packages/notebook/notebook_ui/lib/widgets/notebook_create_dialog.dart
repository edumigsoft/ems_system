import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../view_models/notebook_create_view_model.dart';
import '../widgets/mode_selector_widget.dart';
import 'package:notebook_shared/notebook_shared.dart';

/// Diálogo modal para criação de caderno com seleção de modo.
class NotebookCreateDialog extends StatefulWidget {
  const NotebookCreateDialog({super.key});

  @override
  State<NotebookCreateDialog> createState() => _NotebookCreateDialogState();
}

class _NotebookCreateDialogState extends State<NotebookCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  late NotebookCreateViewModel _viewModel;

  NotebookCreationMode? _selectedMode;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  DateTime? _reminderDate;
  TimeOfDay? _reminderTime;
  bool _notifyOnReminder = true;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.I.get<NotebookCreateViewModel>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _selectedMode = null;
      _titleController.clear();
      _contentController.clear();
      _tagsController.clear();
      _reminderDate = null;
      _reminderTime = null;
      _notifyOnReminder = true;
    });
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
                        _selectedMode == null
                            ? 'Novo Caderno'
                            : _selectedMode!.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Seletor de modo OU formulário
                if (_selectedMode == null)
                  ModeSelectorWidget(
                    selectedMode: _selectedMode,
                    onModeSelected: (mode) {
                      setState(() => _selectedMode = mode);
                    },
                  )
                else ...[
                  // Botão voltar
                  TextButton.icon(
                    onPressed: _resetForm,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Escolher outro tipo'),
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Formulário
                  Form(
                    key: _formKey,
                    child: _buildFormForMode(_selectedMode!),
                  ),

                  const SizedBox(height: 24),

                  // Botões de ação
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) {
                      if (_viewModel.isCreating) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _resetForm,
                            child: const Text('Voltar'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _handleCreate,
                            child: const Text('Criar'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormForMode(NotebookCreationMode mode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Título (todos os modos)
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
          autofocus: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // Conteúdo (todos os modos)
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
          maxLines: mode.type == NotebookType.quick ? 5 : 8,
          minLines: 3,
          textInputAction: TextInputAction.newline,
        ),

        // Campos específicos por modo
        if (mode.type == NotebookType.organized) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Tags (separadas por vírgula)',
              hintText: 'trabalho, importante, projeto',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
          ),
        ],

        if (mode.type == NotebookType.reminder) ...[
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
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _reminderDate = date);
              }
            },
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
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                setState(() => _reminderTime = time);
              }
            },
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validações específicas por modo
    if (_selectedMode!.type == NotebookType.reminder) {
      if (_reminderDate == null) {
        _showError('Selecione a data do lembrete');
        return;
      }
      if (_reminderTime == null) {
        _showError('Selecione o horário do lembrete');
        return;
      }
    }

    bool success = false;

    if (_selectedMode!.type == NotebookType.quick) {
      success = await _viewModel.createQuickNote(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );
    } else if (_selectedMode!.type == NotebookType.organized) {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      success = await _viewModel.createOrganized(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: tags.isEmpty ? null : tags,
      );
    } else if (_selectedMode!.type == NotebookType.reminder) {
      final reminderDateTime = DateTime(
        _reminderDate!.year,
        _reminderDate!.month,
        _reminderDate!.day,
        _reminderTime!.hour,
        _reminderTime!.minute,
      );

      success = await _viewModel.createReminder(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        reminderDate: reminderDateTime,
        notifyOnReminder: _notifyOnReminder,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caderno criado com sucesso')),
      );
    } else {
      _showError(_viewModel.error ?? 'Erro ao criar caderno');
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
