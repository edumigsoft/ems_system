import 'package:flutter/material.dart';

/// Diálogo de confirmação para exclusão de caderno.
class NotebookDeleteConfirmDialog extends StatelessWidget {
  final String notebookTitle;

  const NotebookDeleteConfirmDialog({
    super.key,
    required this.notebookTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir Caderno'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tem certeza que deseja excluir o caderno "$notebookTitle"?'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta ação não pode ser desfeita.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Excluir'),
        ),
      ],
    );
  }
}
