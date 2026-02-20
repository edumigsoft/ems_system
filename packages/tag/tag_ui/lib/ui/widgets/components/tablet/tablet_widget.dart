import 'package:flutter/material.dart';
import 'package:tag_shared/tag_shared.dart';
import '../../../view_models/tag_view_model.dart';
import '../../tag_card.dart';
import '../../../pages/tag_form_page.dart';
import '../../dialogs/dialogs.dart';

/// Widget para layout tablet de gerenciamento de tags.
///
/// Scaffold + FAB + GridView. Criar via dialog (3 campos); editar via TagFormPage.
class TabletWidget extends StatefulWidget {
  final TagViewModel viewModel;

  const TabletWidget({super.key, required this.viewModel});

  @override
  State<TabletWidget> createState() => _TabletWidgetState();
}

class _TabletWidgetState extends State<TabletWidget> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showCreateDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => TagCreateDialog(viewModel: widget.viewModel),
    );
    if (created == true && mounted) {
      widget.viewModel.loadTags();
    }
  }

  Future<void> _navigateToEdit(TagDetails tag) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TagFormPage(
          viewModel: widget.viewModel,
          existingTag: tag,
        ),
      ),
    );
    if (result == true && mounted) {
      widget.viewModel.loadTags();
    }
  }

  Future<void> _confirmDelete(TagDetails tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => TagDeleteConfirmDialog(tagName: tag.name),
    );
    if (confirmed == true && mounted) {
      final success = await widget.viewModel.deleteTag(tag.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Tag deletada com sucesso'
                  : widget.viewModel.errorMessage ?? 'Erro ao deletar tag',
            ),
            backgroundColor: success ? null : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Tags'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              widget.viewModel.activeOnly
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: widget.viewModel.toggleActiveOnly,
            tooltip: widget.viewModel.activeOnly
                ? 'Mostrar todas'
                : 'Mostrar apenas ativas',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        tooltip: 'Nova Tag',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar tags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          widget.viewModel.setSearchQuery('');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: widget.viewModel.setSearchQuery,
            ),
          ),
          Expanded(child: _buildGrid(context)),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final tags = widget.viewModel.filteredTags;

    if (widget.viewModel.isLoading && tags.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.label_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              widget.viewModel.searchQuery.isNotEmpty
                  ? 'Nenhuma tag encontrada'
                  : 'Nenhuma tag cadastrada',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.viewModel.loadTags,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          return TagCard(
            tag: tag,
            onEdit: () => _navigateToEdit(tag),
            onDelete: () => _confirmDelete(tag),
          );
        },
      ),
    );
  }
}
