import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:tag_shared/tag_shared.dart' show TagDetails;

import '../view_models/notebook_list_view_model.dart';
import '../view_models/notebook_detail_view_model.dart';
import '../widgets/notebook_card.dart';
import '../widgets/notebook_create_dialog.dart';
import 'package:core_shared/core_shared.dart' show GetItInjector;
import 'notebook_detail_page.dart';

/// Página de listagem de cadernos.
///
/// Recebe ViewModel via construtor (DI).
class NotebookListPage extends StatefulWidget {
  final NotebookListViewModel viewModel;

  const NotebookListPage({super.key, required this.viewModel});

  @override
  State<NotebookListPage> createState() => _NotebookListPageState();
}

class _NotebookListPageState extends State<NotebookListPage> {
  @override
  void initState() {
    super.initState();
    // Carrega lista ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadNotebooks();
      widget.viewModel.loadAvailableTags();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadernos'),
        actions: [
          // Menu de ordenação
          PopupMenuButton<NotebookSortOrder>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            onSelected: (order) => widget.viewModel.setSortOrder(order),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: NotebookSortOrder.recentFirst,
                child: Row(
                  children: [
                    Icon(
                      widget.viewModel.sortOrder ==
                              NotebookSortOrder.recentFirst
                          ? Icons.check
                          : Icons.calendar_today,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Mais Recentes'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: NotebookSortOrder.oldestFirst,
                child: Row(
                  children: [
                    Icon(
                      widget.viewModel.sortOrder ==
                              NotebookSortOrder.oldestFirst
                          ? Icons.check
                          : Icons.history,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Mais Antigas'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: NotebookSortOrder.alphabetical,
                child: Row(
                  children: [
                    Icon(
                      widget.viewModel.sortOrder ==
                              NotebookSortOrder.alphabetical
                          ? Icons.check
                          : Icons.sort_by_alpha,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('A → Z'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: NotebookSortOrder.reverseAlphabetical,
                child: Row(
                  children: [
                    Icon(
                      widget.viewModel.sortOrder ==
                              NotebookSortOrder.reverseAlphabetical
                          ? Icons.check
                          : Icons.sort_by_alpha,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Z → A'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.viewModel.loadNotebooks(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return _buildBody(context, theme);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo Caderno'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    // Estado de loading
    if (widget.viewModel.isLoading && widget.viewModel.notebooks == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Estado de erro
    if (widget.viewModel.error != null && widget.viewModel.notebooks == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar cadernos',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.viewModel.error!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => widget.viewModel.loadNotebooks(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final hasData =
        widget.viewModel.notebooks != null &&
        widget.viewModel.notebooks!.isNotEmpty;
    final filteredNotebooks = widget.viewModel.filteredNotebooks;
    final hasActiveFilters =
        widget.viewModel.searchQuery.isNotEmpty ||
        widget.viewModel.selectedTypes.isNotEmpty ||
        widget.viewModel.selectedTags.isNotEmpty;

    // Estado vazio (sem dados originais)
    if (!hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withAlpha(64),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum caderno encontrado',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Clique no botão abaixo para criar seu primeiro caderno',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Lista de cadernos com busca e filtros
    return RefreshIndicator(
      onRefresh: () => widget.viewModel.loadNotebooks(),
      child: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar cadernos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: widget.viewModel.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => widget.viewModel.setSearchQuery(''),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: widget.viewModel.setSearchQuery,
            ),
          ),

          // Filtros por tipo
          if (NotebookType.values.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: NotebookType.values.map((type) {
                  final isSelected = widget.viewModel.selectedTypes.contains(
                    type,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_getTypeLabel(type)),
                      selected: isSelected,
                      onSelected: (_) =>
                          widget.viewModel.toggleTypeFilter(type),
                      avatar: Icon(
                        _getTypeIcon(type),
                        size: 18,
                        color: isSelected
                            ? theme.colorScheme.onSecondaryContainer
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 8),

          // Filtros por tags
          if (widget.viewModel.availableTags.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.label_outline, size: 18),
                  const SizedBox(width: 8),
                  ...widget.viewModel.availableTags.map((TagDetails tag) {
                    final isSelected = widget.viewModel.selectedTags.any(
                      (t) => t.id == tag.id,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(tag.name),
                        selected: isSelected,
                        onSelected: (_) =>
                            widget.viewModel.toggleTagFilter(tag),
                      ),
                    );
                  }),
                ],
              ),
            ),

          // Botão limpar filtros (se houver filtros ativos)
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextButton.icon(
                onPressed: widget.viewModel.clearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar filtros'),
              ),
            ),

          const Divider(),

          // Lista filtrada
          Expanded(
            child: filteredNotebooks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list_off,
                          size: 64,
                          color: theme.colorScheme.onSurface.withAlpha(64),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum resultado encontrado',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tente ajustar os filtros',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: widget.viewModel.clearFilters,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Limpar filtros'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNotebooks.length,
                    itemBuilder: (context, index) {
                      final notebook = filteredNotebooks[index];
                      // Cria mapa de tags para resolução rápida (ID -> TagDetails)
                      final tagsMap = {
                        for (final tag in widget.viewModel.availableTags)
                          tag.id: tag,
                      };

                      return NotebookCard(
                        notebook: notebook,
                        tagsMap: tagsMap,
                        onTap: () => _navigateToDetail(context, notebook.id),
                        onDelete: () => _handleDelete(context, notebook),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToDetail(
    BuildContext context,
    String notebookId,
  ) async {
    final detailViewModel = GetItInjector().get<NotebookDetailViewModel>();

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => NotebookDetailPage(
          viewModel: detailViewModel,
          notebookId: notebookId,
        ),
      ),
    );

    // Recarrega lista ao voltar da tela de detalhes
    if (context.mounted) {
      widget.viewModel.loadNotebooks();
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    NotebookDetails notebook,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o caderno "${notebook.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await widget.viewModel.deleteNotebook(notebook.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Caderno excluído com sucesso')),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.error ?? 'Erro ao excluir caderno'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _getTypeLabel(NotebookType type) {
    return switch (type) {
      NotebookType.quick => 'Rápida',
      NotebookType.organized => 'Organizada',
      NotebookType.reminder => 'Lembrete',
    };
  }

  IconData _getTypeIcon(NotebookType type) {
    return switch (type) {
      NotebookType.quick => Icons.notes,
      NotebookType.organized => Icons.menu_book,
      NotebookType.reminder => Icons.bookmark,
    };
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => const NotebookCreateDialog(),
    );

    if (created == true && context.mounted) {
      widget.viewModel.loadNotebooks();
    }
  }
}
