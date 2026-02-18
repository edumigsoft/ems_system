import 'package:flutter/material.dart';
import '../../../view_models/tag_view_model.dart';
import '../../tag_card.dart';

/// Widget para layout mobile de gerenciamento de tags.
///
/// Read-only: apenas visualização. Sem ações de edit/delete.
class MobileWidget extends StatefulWidget {
  final TagViewModel viewModel;

  const MobileWidget({super.key, required this.viewModel});

  @override
  State<MobileWidget> createState() => _MobileWidgetState();
}

class _MobileWidgetState extends State<MobileWidget> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = widget.viewModel.filteredTags;

    return Column(
      children: [
        // Campo de busca
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

        // Filtro de ativas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FilterChip(
                label: Text(
                  widget.viewModel.activeOnly
                      ? 'Apenas ativas'
                      : 'Todas as tags',
                ),
                selected: widget.viewModel.activeOnly,
                onSelected: (_) => widget.viewModel.toggleActiveOnly(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Lista read-only
        Expanded(
          child: widget.viewModel.isLoading && tags.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : tags.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.label_outline,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
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
                    )
                  : RefreshIndicator(
                      onRefresh: widget.viewModel.loadTags,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tags.length,
                        itemBuilder: (context, index) {
                          final tag = tags[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TagCard(tag: tag),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
