import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:tag_shared/tag_shared.dart';
import '../view_models/tag_view_model.dart';

/// Página de formulário para editar uma tag (4 campos: nome, descrição, cor, ativo).
///
/// Sem Scaffold/AppBar — usa DSCardHeader com botão de voltar.
class TagFormPage extends StatefulWidget {
  final TagViewModel viewModel;
  final TagDetails existingTag;

  const TagFormPage({
    required this.viewModel,
    required this.existingTag,
    super.key,
  });

  @override
  State<TagFormPage> createState() => _TagFormPageState();
}

class _TagFormPageState extends State<TagFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.existingTag.name;
    _descriptionController.text = widget.existingTag.description ?? '';
    _colorController.text = widget.existingTag.color ?? '';
    _isActive = widget.existingTag.isActive;
  }

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

    final update = TagUpdate(
      id: widget.existingTag.id,
      name: _nameController.text.trim() != widget.existingTag.name
          ? _nameController.text.trim()
          : null,
      description:
          _descriptionController.text.trim() !=
                  (widget.existingTag.description ?? '')
              ? _descriptionController.text.trim()
              : null,
      color: _colorController.text.trim() != (widget.existingTag.color ?? '')
          ? _colorController.text.trim()
          : null,
      isActive: _isActive != widget.existingTag.isActive ? _isActive : null,
    );

    final success = await widget.viewModel.updateTag(update);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DSCardHeader(
          title: 'Editar Tag',
          subtitle: widget.existingTag.name,
          showSearch: false,
          actionButton: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Voltar',
          ),
        ),
        Expanded(
          child: DSCard(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nome
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
                    ),
                    const SizedBox(height: 16),

                    // Descrição
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)',
                        hintText: 'Descreva quando usar esta tag',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.length > TagConstants.maxDescriptionLength) {
                          return 'Descrição deve ter no máximo ${TagConstants.maxDescriptionLength} caracteres';
                        }
                        return null;
                      },
                      maxLength: TagConstants.maxDescriptionLength,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Cor
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
                          final regex =
                              RegExp(TagConstants.hexColorPattern);
                          if (!regex.hasMatch(value)) {
                            return 'Cor deve ser um código hexadecimal válido (ex: #FF5722)';
                          }
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Status ativo
                    SwitchListTile(
                      title: const Text('Tag ativa'),
                      subtitle: const Text(
                        'Tags inativas não aparecem por padrão',
                      ),
                      value: _isActive,
                      onChanged: (value) =>
                          setState(() => _isActive = value),
                    ),
                    const SizedBox(height: 16),

                    // Erro
                    if (widget.viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          color:
                              Theme.of(context).colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              widget.viewModel.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                            ),
                          ),
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _onSubmit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
