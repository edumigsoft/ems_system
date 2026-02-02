import 'package:flutter/material.dart';

/// Campo de busca para tabela.
///
/// Campo de texto estilizado para buscar/filtrar dados da tabela.
///
/// **Exemplo de uso:**
/// ```dart
/// DSTableSearchField(
///   hintText: 'Buscar escolas...',
///   onChanged: (value) {
///     setState(() {
///       searchQuery = value;
///       _applyFilters();
///     });
///   },
///   onClear: () {
///     setState(() {
///       searchQuery = '';
///       _applyFilters();
///     });
///   },
/// )
/// ```
class DSTableSearchField extends StatefulWidget {
  /// Hint text do campo
  final String? hintText;

  /// Callback quando o texto muda
  final ValueChanged<String>? onChanged;

  /// Callback quando o botão limpar é pressionado
  final VoidCallback? onClear;

  /// Controller customizado (opcional)
  final TextEditingController? controller;

  /// Se deve autofocus
  final bool autofocus;

  const DSTableSearchField({
    super.key,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.controller,
    this.autofocus = false,
  });

  @override
  State<DSTableSearchField> createState() => _DSTableSearchFieldState();
}

class _DSTableSearchFieldState extends State<DSTableSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _clearText() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final dsTheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dsTheme.surface,
        border: const Border(
          bottom: BorderSide(
            // color: dsTheme.border ?? Colors.white10,
            color: Colors.white10,
          ),
        ),
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: dsTheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Buscar...',
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: dsTheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: dsTheme.primary,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: _clearText,
                  color: dsTheme.onSurface.withValues(alpha: 0.6),
                )
              : null,
          filled: true,
          fillColor: dsTheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              // color: dsTheme?.border ?? Colors.white10,
              color: Colors.white10,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              // color: dsTheme?.border ?? Colors.white10,
              color: Colors.white10,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              // color: dsTheme?.primary ?? Colors.blue,
              color: Colors.blue,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
