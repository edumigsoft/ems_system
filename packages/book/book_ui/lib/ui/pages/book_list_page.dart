import 'package:flutter/material.dart';
import '../view_models/book_view_model.dart';
import '../widgets/book_card.dart';

class BookListPage extends StatelessWidget {
  final BookViewModel viewModel;

  const BookListPage({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('books'),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('Erro: ${viewModel.error}'));
          }

          if (viewModel.items.isEmpty) {
            return const Center(child: Text('Nenhum item encontrado'));
          }

          return ListView.builder(
            itemCount: viewModel.items.length,
            itemBuilder: (context, index) {
              final item = viewModel.items[index];
              return BookCard(
                item: item,
                onTap: () {
                  // Navegar para detalhes
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para criação
          // viewModel.create(...);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
