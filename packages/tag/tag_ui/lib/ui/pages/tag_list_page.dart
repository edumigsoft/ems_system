import 'package:flutter/material.dart';
import '../view_models/tag_view_model.dart';
import '../widgets/tag_card.dart';
import 'tag_form_page.dart';

/// Page displaying list of tags with search and filters.
class TagListPage extends StatefulWidget {
  final TagViewModel viewModel;

  const TagListPage({
    required this.viewModel,
    super.key,
  });

  @override
  State<TagListPage> createState() => _TagListPageState();
}

class _TagListPageState extends State<TagListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
    widget.viewModel.loadTags();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});

      // Show error snackbar if there's an error
      if (widget.viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'OK',
              onPressed: widget.viewModel.clearError,
            ),
          ),
        );
      }
    }
  }

  Future<void> _onCreateTag() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TagFormPage(viewModel: widget.viewModel),
      ),
    );

    if (result == true) {
      widget.viewModel.loadTags();
    }
  }

  Future<void> _onEditTag(String tagId) async {
    final tag = widget.viewModel.tags.firstWhere((t) => t.id == tagId);

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TagFormPage(
          viewModel: widget.viewModel,
          existingTag: tag,
        ),
      ),
    );

    if (result == true) {
      widget.viewModel.loadTags();
    }
  }

  Future<void> _onDeleteTag(String tagId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja deletar esta tag?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await widget.viewModel.deleteTag(tagId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tag deletada com sucesso')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Tags'),
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
      body: Column(
        children: [
          // Search bar
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

          // List
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreateTag,
        tooltip: 'Nova Tag',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.viewModel.isLoading && widget.viewModel.tags.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final tags = widget.viewModel.filteredTags;

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
            const SizedBox(height: 8),
            Text(
              widget.viewModel.searchQuery.isNotEmpty
                  ? 'Tente outro termo de busca'
                  : 'Crie sua primeira tag',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.viewModel.loadTags,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TagCard(
              tag: tag,
              onEdit: () => _onEditTag(tag.id),
              onDelete: () => _onDeleteTag(tag.id),
            ),
          );
        },
      ),
    );
  }
}
