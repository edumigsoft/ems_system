import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// Tipo de adição de documento.
enum DocumentAddType {
  upload, // Upload de arquivo do dispositivo
  url, // Link externo (URL)
  localPath, // Caminho local no computador
}

/// Widget para upload e adição de documentos a um caderno.
class DocumentUploadWidget extends StatefulWidget {
  final ValueChanged<DocumentAddResult> onDocumentAdded;
  final bool enabled;
  final int? maxSizeMB;
  final List<String>? allowedExtensions;

  const DocumentUploadWidget({
    super.key,
    required this.onDocumentAdded,
    this.enabled = true,
    this.maxSizeMB = 50,
    this.allowedExtensions,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  DocumentAddType? _selectedType;
  final _urlController = TextEditingController();
  final _pathController = TextEditingController();
  final _nameController = TextEditingController();
  FilePickerResult? _pickedFile;
  bool _isProcessing = false;

  @override
  void dispose() {
    _urlController.dispose();
    _pathController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: widget.allowedExtensions,
        withData: kIsWeb, // Carregar bytes apenas na web
      );

      if (result != null) {
        setState(() {
          _pickedFile = result;
          _nameController.text = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar arquivo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedType = null;
      _pickedFile = null;
      _urlController.clear();
      _pathController.clear();
      _nameController.clear();
    });
  }

  bool _validate() {
    if (_selectedType == DocumentAddType.upload) {
      if (_pickedFile == null) {
        _showError('Selecione um arquivo');
        return false;
      }
      final sizeMB = (_pickedFile!.files.single.size) / (1024 * 1024);
      if (widget.maxSizeMB != null && sizeMB > widget.maxSizeMB!) {
        _showError('Arquivo muito grande. Máximo: ${widget.maxSizeMB}MB');
        return false;
      }
    } else if (_selectedType == DocumentAddType.url) {
      final url = _urlController.text.trim();
      if (url.isEmpty) {
        _showError('Digite uma URL');
        return false;
      }
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        _showError('URL inválida');
        return false;
      }
    } else if (_selectedType == DocumentAddType.localPath) {
      if (_pathController.text.trim().isEmpty) {
        _showError('Digite o caminho do arquivo');
        return false;
      }
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _confirm() async {
    if (!_validate()) return;

    setState(() => _isProcessing = true);

    try {
      DocumentAddResult result;

      if (_selectedType == DocumentAddType.upload) {
        result = DocumentAddResult.upload(
          file: _pickedFile!,
          name: _nameController.text.trim(),
        );
      } else if (_selectedType == DocumentAddType.url) {
        result = DocumentAddResult.url(
          url: _urlController.text.trim(),
          name: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : _urlController.text.trim(),
        );
      } else {
        result = DocumentAddResult.localPath(
          path: _pathController.text.trim(),
          name: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : _pathController.text.trim().split('/').last,
        );
      }

      widget.onDocumentAdded(result);
      _clearSelection();
    } catch (e) {
      _showError('Erro ao processar documento: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Row(
              children: [
                Icon(Icons.attach_file, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Adicionar Documento',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botões de seleção de tipo
            if (_selectedType == null) ...[
              _TypeButton(
                icon: Icons.upload_file,
                label: 'Enviar Arquivo',
                description: 'Do seu dispositivo',
                onPressed: widget.enabled
                    ? () =>
                          setState(() => _selectedType = DocumentAddType.upload)
                    : null,
              ),
              const SizedBox(height: 8),
              _TypeButton(
                icon: Icons.link,
                label: 'Adicionar Link',
                description: 'URL externa',
                onPressed: widget.enabled
                    ? () => setState(() => _selectedType = DocumentAddType.url)
                    : null,
              ),
              const SizedBox(height: 8),
              _TypeButton(
                icon: Icons.folder,
                label: 'Arquivo Local',
                description: 'Caminho no seu PC',
                onPressed: widget.enabled
                    ? () => setState(
                        () => _selectedType = DocumentAddType.localPath,
                      )
                    : null,
              ),
            ],

            // Formulário baseado no tipo selecionado
            if (_selectedType != null) ...[
              _buildForm(theme, colorScheme),
              const SizedBox(height: 16),

              // Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isProcessing ? null : _clearSelection,
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isProcessing || !widget.enabled
                        ? null
                        : _confirm,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Confirmar'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme, ColorScheme colorScheme) {
    if (_selectedType == DocumentAddType.upload) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.file_open),
            label: Text(
              _pickedFile == null ? 'Selecionar Arquivo' : 'Trocar Arquivo',
            ),
          ),
          if (_pickedFile != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.description, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pickedFile!.files.single.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(_pickedFile!.files.single.size / 1024).toStringAsFixed(1)} KB',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do documento (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      );
    } else if (_selectedType == DocumentAddType.url) {
      return Column(
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL do documento',
              hintText: 'https://exemplo.com/documento.pdf',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do documento (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          TextField(
            controller: _pathController,
            decoration: const InputDecoration(
              labelText: 'Caminho do arquivo',
              hintText: 'C:/Documentos/arquivo.pdf',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.folder),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do documento (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    }
  }
}

class _TypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback? onPressed;

  const _TypeButton({
    required this.icon,
    required this.label,
    required this.description,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleSmall),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

/// Resultado da adição de documento.
class DocumentAddResult {
  final DocumentAddType type;
  final String name;
  final FilePickerResult? file;
  final String? url;
  final String? path;

  DocumentAddResult._({
    required this.type,
    required this.name,
    this.file,
    this.url,
    this.path,
  });

  factory DocumentAddResult.upload({
    required FilePickerResult file,
    required String name,
  }) {
    return DocumentAddResult._(
      type: DocumentAddType.upload,
      name: name,
      file: file,
    );
  }

  factory DocumentAddResult.url({
    required String url,
    required String name,
  }) {
    return DocumentAddResult._(
      type: DocumentAddType.url,
      name: name,
      url: url,
    );
  }

  factory DocumentAddResult.localPath({
    required String path,
    required String name,
  }) {
    return DocumentAddResult._(
      type: DocumentAddType.localPath,
      name: name,
      path: path,
    );
  }
}
