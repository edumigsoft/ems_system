import 'package:flutter/material.dart';

/// Form para criar/editar Book.
class BookForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final void Function(Map<String, dynamic> data) onSubmit;

  const BookForm({
    super.key,
    this.initialData,
    required this.onSubmit,
  });

  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Adicionar TextEditingControllers para os campos

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Adicionar TextFormFields
          
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Coletar dados do formulário
                final data = <String, dynamic>{};
                widget.onSubmit(data);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
