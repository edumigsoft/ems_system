import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:core_shared/core_shared.dart' show Failure;
import 'package:notebook_shared/notebook_shared.dart';
import 'package:tag_client/tag_client.dart' show TagApiService;
import 'package:tag_ui/tag_ui.dart' show TagSelector;
import '../ui/view_models/notebook_form_view_model.dart';

/// Página de formulário para criar/editar caderno.
///
/// Sem Scaffold/AppBar — usa DSCardHeader com botão de voltar.
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
  late NotebookFormViewModel _viewModel;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeViewModel();
  }

  Future<void> _initializeViewModel() async {
    final tagService = GetIt.I.get<TagApiService>();
    _viewModel = NotebookFormViewModel(
      initialData: widget.notebook,
      tagService: tagService,
    );

    await _viewModel.initialize();

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final validation = await _viewModel.validateAndGetData();

    if (validation case Failure()) {
      return;
    }

    if (!mounted) return;

    if (_viewModel.isEditing) {
      final update = _viewModel.createNotebookUpdate();
      widget.onUpdate?.call(update);
    } else {
      final create = _viewModel.createNotebookCreate();
      widget.onCreate(create);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DSCardHeader(
          title: _isInitializing
              ? 'Carregando...'
              : (_viewModel.isEditing ? 'Editar Caderno' : 'Novo Caderno'),
          subtitle: _isInitializing
              ? null
              : (_viewModel.isEditing
                  ? 'Edite os dados do caderno'
                  : 'Preencha os dados do novo caderno'),
          showSearch: false,
          actionButton: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Voltar',
          ),
        ),
        Expanded(
          child: DSCard(
            child: _isInitializing
                ? const Center(child: CircularProgressIndicator())
                : ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) {
                      return ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          // Título
                          TextField(
                            controller: _viewModel.registerField(
                              notebookTitleField,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Título *',
                              hintText: 'Digite o título do caderno',
                              border: const OutlineInputBorder(),
                              errorText: _viewModel.getFieldError(
                                notebookTitleField,
                              ),
                            ),
                            maxLength: 255,
                          ),
                          const SizedBox(height: 16),

                          // Conteúdo
                          TextField(
                            controller: _viewModel.registerField(
                              notebookContentField,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Conteúdo *',
                              hintText: 'Digite o conteúdo ou resumo',
                              border: const OutlineInputBorder(),
                              alignLabelWithHint: true,
                              errorText: _viewModel.getFieldError(
                                notebookContentField,
                              ),
                            ),
                            maxLines: 10,
                            minLines: 5,
                          ),
                          const SizedBox(height: 16),

                          // Tipo
                          DropdownButtonFormField<NotebookType>(
                            initialValue: _viewModel.selectedType,
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
                                _viewModel.selectedType = value;
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Tags
                          if (_viewModel.isLoadingTags)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tags',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TagSelector(
                                  availableTags: _viewModel.availableTags,
                                  selectedTags: _viewModel.selectedTags,
                                  onChanged: (newTags) =>
                                      _viewModel.setTags(newTags),
                                ),
                              ],
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
                                onPressed: _viewModel.isSubmitting
                                    ? null
                                    : (_viewModel.isFormValid &&
                                              _viewModel.isFormDirty
                                          ? _handleSubmit
                                          : null),
                                child: _viewModel.isSubmitting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _viewModel.isEditing
                                            ? 'Salvar'
                                            : 'Criar',
                                      ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  String _getLabelForType(NotebookType type) {
    return switch (type) {
      NotebookType.quick => 'Nota Rápida',
      NotebookType.organized => 'Organizado',
      NotebookType.reminder => 'Lembrete',
    };
  }
}
