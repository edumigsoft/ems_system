import 'package:flutter/material.dart';

/// Widget para input de tags com autocomplete e chips removíveis.
///
/// Permite adicionar, remover e visualizar tags de forma intuitiva.
class TagInputWidget extends StatefulWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onTagsChanged;
  final Future<List<String>> Function(String query)? onSearchTags;
  final String? hintText;
  final int? maxTags;
  final bool enabled;

  const TagInputWidget({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
    this.onSearchTags,
    this.hintText,
    this.maxTags,
    this.enabled = true,
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) return;
    if (widget.selectedTags.contains(trimmed)) return;
    if (widget.maxTags != null &&
        widget.selectedTags.length >= widget.maxTags!) {
      return;
    }

    final newTags = [...widget.selectedTags, trimmed];
    widget.onTagsChanged(newTags);
    _controller.clear();
    _suggestions.clear();
    setState(() => _showSuggestions = false);
  }

  void _removeTag(String tag) {
    final newTags = widget.selectedTags.where((t) => t != tag).toList();
    widget.onTagsChanged(newTags);
  }

  Future<void> _searchTags(String query) async {
    if (query.isEmpty || widget.onSearchTags == null) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      final results = await widget.onSearchTags!(query);
      setState(() {
        // Filtrar tags já selecionadas
        _suggestions = results
            .where((tag) => !widget.selectedTags.contains(tag))
            .toList();
        _showSuggestions = _suggestions.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Campo de input
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Adicionar tag...',
            border: const OutlineInputBorder(),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addTag(_controller.text),
                    tooltip: 'Adicionar tag',
                  )
                : null,
          ),
          onChanged: _searchTags,
          onSubmitted: _addTag,
          textInputAction: TextInputAction.done,
        ),

        // Lista de sugestões (autocomplete)
        if (_showSuggestions && _suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final tag = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.label_outline,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  title: Text(tag, style: theme.textTheme.bodyMedium),
                  onTap: () => _addTag(tag),
                );
              },
            ),
          ),
        ],

        // Tags selecionadas (chips)
        if (widget.selectedTags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedTags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: widget.enabled ? () => _removeTag(tag) : null,
                backgroundColor: colorScheme.secondaryContainer,
                labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
              );
            }).toList(),
          ),
        ],

        // Contador de tags (se houver limite)
        if (widget.maxTags != null && widget.selectedTags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${widget.selectedTags.length}/${widget.maxTags} tags',
            style: theme.textTheme.bodySmall?.copyWith(
              color: widget.selectedTags.length >= widget.maxTags!
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
