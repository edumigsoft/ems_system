import 'package:flutter/material.dart';

class TagDeleteConfirmDialog extends StatelessWidget {
  final String tagName;

  const TagDeleteConfirmDialog({super.key, required this.tagName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar exclusão'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tem certeza que deseja deletar a tag "$tagName"?'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta ação não pode ser desfeita.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red[700]),
          child: const Text('Deletar'),
        ),
      ],
    );
  }
}
