import 'package:flutter/material.dart';
import 'package:tag_shared/tag_shared.dart';
import '../../view_models/tag_view_model.dart';

/// Dialog para criar uma tag (3 campos: nome, descrição, cor).
class TagCreateDialog extends StatefulWidget {
  final TagViewModel viewModel;

  const TagCreateDialog({super.key, required this.viewModel});

  @override
  State<TagCreateDialog> createState() => _TagCreateDialogState();
}

class _TagCreateDialogState extends State<TagCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final create = TagCreate(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      color: _colorController.text.trim().isEmpty
          ? null
          : _colorController.text.trim(),
    );

    final success = await widget.viewModel.createTag(create);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Tag'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  hintText: 'Ex: Frontend, Backend, Bug',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().length < TagConstants.minNameLength) {
                    return 'Nome deve ter no mínimo ${TagConstants.minNameLength} caractere';
                  }
                  if (value.trim().length > TagConstants.maxNameLength) {
                    return 'Nome deve ter no máximo ${TagConstants.maxNameLength} caracteres';
                  }
                  return null;
                },
                maxLength: TagConstants.maxNameLength,
                textCapitalization: TextCapitalization.words,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _colorController,
                decoration: InputDecoration(
                  labelText: 'Cor (opcional)',
                  hintText: 'Ex: #FF5722',
                  border: const OutlineInputBorder(),
                  prefixIcon: _colorController.text.isNotEmpty
                      ? _buildColorPreview()
                      : const Icon(Icons.palette),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final regex = RegExp(TagConstants.hexColorPattern);
                    if (!regex.hasMatch(value)) {
                      return 'Código hexadecimal inválido (ex: #FF5722)';
                    }
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
                enabled: !_isLoading,
              ),
              if (widget.viewModel.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.viewModel.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
              if (_isLoading) ...[
                const SizedBox(height: 12),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _onSubmit,
          child: const Text('Criar'),
        ),
      ],
    );
  }

  Widget _buildColorPreview() {
    try {
      final hexColor = _colorController.text.replaceAll('#', '');
      final color = Color(int.parse('FF$hexColor', radix: 16));
      return Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
        ),
      );
    } catch (_) {
      return const Icon(Icons.palette);
    }
  }
}
