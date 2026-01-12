import 'package:flutter/material.dart';
import 'package:book_shared/book_shared.dart';

/// Card para exibir Book.
class BookCard extends StatelessWidget {
  final BookDetails item;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(item.id), // Trocar por campo apropriado
        subtitle: Text('Criado em: ${item.createdAt}'),
        trailing: item.isActive
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.cancel, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
