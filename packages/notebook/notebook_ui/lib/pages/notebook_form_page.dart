import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';

/// Página de formulário para criar/editar caderno.
///
/// Versão simplificada sem usar zard_form por enquanto.
class NotebookFormPage extends StatefulWidget {
  final NotebookDetails? notebook;
  final void Function(NotebookCreate) onCreate;
  final void Function(NotebookUpdate)? onUpdate;

  const NotebookFormPage({
    super.key,
    this.notebook,
    required this.onCreate,
    this.onUpdate,
  });

  @override
  State<NotebookFormPage> createState() => _NotebookFormPageState();
}

class _NotebookFormPageState extends State<NotebookFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  NotebookType _selectedType = NotebookType.organized;

  bool get isEditing => widget.notebook != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.notebook?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.notebook?.content ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.notebook?.tags?.join(', ') ?? '',
    );
    _selectedType = widget.notebook?.type ?? NotebookType.organized;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Caderno' : 'Novo Caderno'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Digite o título do caderno',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O título é obrigatório';
                }
                return null;
              },
              maxLength: 255,
            ),
            const SizedBox(height: 16),

            // Conteúdo
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Conteúdo *',
                hintText: 'Digite o conteúdo ou resumo',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O conteúdo é obrigatório';
                }
                return null;
              },
              maxLines: 10,
              minLines: 5,
            ),
            const SizedBox(height: 16),

            // Tipo
            DropdownButtonFormField<NotebookType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: NotebookType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getLabelForType(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (separadas por vírgula)',
                hintText: 'Ex: trabalho, importante, pessoal',
                border: OutlineInputBorder(),
                helperText: 'Separe as tags com vírgulas',
              ),
            ),
            const SizedBox(height: 24),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(isEditing ? 'Salvar' : 'Criar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLabelForType(NotebookType type) {
    return switch (type) {
      NotebookType.quick => 'Nota Rápida',
      NotebookType.organized => 'Organizado',
      NotebookType.reminder => 'Lembrete',
    };
  }

  List<String>? _parseTags(String tagsText) {
    if (tagsText.trim().isEmpty) return null;
    return tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final tags = _parseTags(_tagsController.text);

    if (isEditing) {
      final update = NotebookUpdate(
        id: widget.notebook!.id,
        title: title,
        content: content,
        type: _selectedType,
        tags: tags,
      );
      widget.onUpdate?.call(update);
    } else {
      final create = NotebookCreate(
        title: title,
        content: content,
        type: _selectedType,
        tags: tags,
      );
      widget.onCreate(create);
    }

    Navigator.of(context).pop(true);
  }
}
