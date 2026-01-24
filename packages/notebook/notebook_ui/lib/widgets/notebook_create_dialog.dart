import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../view_models/notebook_create_view_model.dart';

/// Diálogo modal para criação rápida de nota.
class NotebookCreateDialog extends StatefulWidget {
  const NotebookCreateDialog({super.key});

  @override
  State<NotebookCreateDialog> createState() => _NotebookCreateDialogState();
}

class _NotebookCreateDialogState extends State<NotebookCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late NotebookCreateViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.I.get<NotebookCreateViewModel>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Nota Rápida'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            ),
            const SizedBox(height: 16),
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
              maxLines: 5,
              minLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isCreating) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            return ElevatedButton(
              onPressed: _handleCreate,
              child: const Text('Criar'),
            );
          },
        ),
      ],
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await _viewModel.createQuickNote(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota criada com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error ?? 'Erro ao criar nota'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
