import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart' show GetItInjector;
import 'package:notebook_shared/notebook_shared.dart';
import '../../../../view_models/notebook_list_view_model.dart';
import '../../../../view_models/notebook_detail_view_model.dart';
import '../../../../widgets/notebook_card.dart';
import '../../../../widgets/notebook_create_dialog.dart';
import '../../../../widgets/notebook_edit_dialog.dart';
import '../../dialogs/dialogs.dart';
import '../shared/notebook_inline_detail.dart';

/// Widget tablet com navegação in-page: grid ↔ detalhe.
///
/// Toda a área do DSCard troca de conteúdo — sem Navigator.push,
/// sem Scaffold. Toolbar inline (busca + sort + "Novo Caderno").
/// CRUD via dialogs. Grid 2 colunas com NotebookCard.
class TabletWidget extends StatefulWidget {
  final NotebookListViewModel viewModel;

  const TabletWidget({super.key, required this.viewModel});

  @override
  State<TabletWidget> createState() => _TabletWidgetState();
}

class _TabletWidgetState extends State<TabletWidget> {
  NotebookDetails? _selected;
  NotebookDetailViewModel? _detailVm;

  // ── Navegação ──────────────────────────────────────────────────

  void _openDetail(String notebookId) {
    final notebooks = widget.viewModel.notebooks ?? [];
    final notebook = notebooks.where((n) => n.id == notebookId).firstOrNull;
    if (notebook == null) return;

    final vm = GetItInjector().get<NotebookDetailViewModel>();
    setState(() {
      _selected = notebook;
      _detailVm = vm;
    });
    vm.loadNotebook(notebookId).then((_) {
      if (mounted) vm.loadAvailableTags();
    });
  }

  void _backToList() {
    setState(() {
      _selected = null;
      _detailVm = null;
    });
    widget.viewModel.loadNotebooks();
  }

  // ── CRUD via dialogs ────────────────────────────────────────────

  Future<void> _onCreate() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const NotebookCreateDialog(),
    );
    if (created == true && mounted) widget.viewModel.loadNotebooks();
  }

  Future<void> _onEdit(NotebookDetails notebook) async {
    final vm =
        (_selected?.id == notebook.id ? _detailVm : null) ??
        GetItInjector().get<NotebookDetailViewModel>();

    if (vm.notebook == null) await vm.loadNotebook(notebook.id);
    if (!mounted) return;

    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => NotebookEditDialog(notebook: notebook, viewModel: vm),
    );
    if (updated == true && mounted) {
      widget.viewModel.loadNotebooks();
      if (_selected?.id == notebook.id) vm.loadNotebook(notebook.id);
    }
  }

  Future<void> _onDelete(NotebookDetails notebook) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) =>
          NotebookDeleteConfirmDialog(notebookTitle: notebook.title),
    );
    if (confirmed != true || !mounted) return;

    final success = await widget.viewModel.deleteNotebook(notebook.id);
    if (!mounted) return;

    if (success && _selected?.id == notebook.id) _backToList();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Caderno excluído com sucesso'
              : (widget.viewModel.error ?? 'Erro ao excluir caderno'),
        ),
        backgroundColor: success ? null : Theme.of(context).colorScheme.error,
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_selected != null && _detailVm != null) {
      return NotebookInlineDetail(
        notebook: _selected!,
        viewModel: _detailVm!,
        onBack: _backToList,
        onEdit: () => _onEdit(_selected!),
        onDelete: () => _onDelete(_selected!),
      );
    }

    return Column(
      children: [
        _buildToolbar(context),
        const Divider(height: 1),
        Expanded(
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) => _buildGrid(context),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar cadernos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onChanged: widget.viewModel.setSearchQuery,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<NotebookSortOrder>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            onSelected: widget.viewModel.setSortOrder,
            itemBuilder: (_) => [
              _sortItem(
                NotebookSortOrder.recentFirst,
                'Mais Recentes',
                Icons.calendar_today,
              ),
              _sortItem(
                NotebookSortOrder.oldestFirst,
                'Mais Antigas',
                Icons.history,
              ),
              const PopupMenuDivider(),
              _sortItem(
                NotebookSortOrder.alphabetical,
                'A → Z',
                Icons.sort_by_alpha,
              ),
              _sortItem(
                NotebookSortOrder.reverseAlphabetical,
                'Z → A',
                Icons.sort_by_alpha,
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.viewModel.loadNotebooks,
            tooltip: 'Atualizar',
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Novo Caderno'),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<NotebookSortOrder> _sortItem(
    NotebookSortOrder order,
    String label,
    IconData icon,
  ) {
    final isSelected = widget.viewModel.sortOrder == order;
    return PopupMenuItem(
      value: order,
      child: Row(
        children: [
          Icon(isSelected ? Icons.check : icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.viewModel.isLoading && widget.viewModel.notebooks == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.viewModel.error != null && widget.viewModel.notebooks == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar cadernos',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(widget.viewModel.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: widget.viewModel.loadNotebooks,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final notebooks = widget.viewModel.filteredNotebooks;
    final tagsMap = {
      for (final tag in widget.viewModel.availableTags) tag.id: tag,
    };

    if (notebooks.isEmpty) {
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
            const Text('Clique em "Novo Caderno" para criar o primeiro'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: notebooks.length,
      itemBuilder: (context, index) {
        final notebook = notebooks[index];
        return NotebookCard(
          notebook: notebook,
          tagsMap: tagsMap,
          onTap: () => _openDetail(notebook.id),
          onDelete: () => _onDelete(notebook),
        );
      },
    );
  }
}
