import 'package:flutter/material.dart';

/// Campo de busca reutilizável para usuários.
///
/// Busca por nome, username ou email.
class UserSearchField extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const UserSearchField({
    super.key,
    this.value,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: value != null ? TextEditingController(text: value) : null,
      decoration: InputDecoration(
        hintText: 'Buscar por nome, username ou email...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: value != null && value!.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      onChanged: onChanged,
    );
  }
}
