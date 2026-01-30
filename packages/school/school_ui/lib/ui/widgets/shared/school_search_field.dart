import 'package:flutter/material.dart';

/// Campo de busca reutilizável para escolas.
///
/// Campo de texto com ícone de busca e botão de limpar,
/// otimizado para buscar por nome, código ou cidade.
class SchoolSearchField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const SchoolSearchField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Buscar por nome, código ou cidade...',
  });

  @override
  State<SchoolSearchField> createState() => _SchoolSearchFieldState();
}

class _SchoolSearchFieldState extends State<SchoolSearchField> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged(_controller.text);
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clear,
                tooltip: 'Limpar busca',
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
