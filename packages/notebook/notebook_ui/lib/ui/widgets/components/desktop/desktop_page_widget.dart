import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:core_shared/core_shared.dart' show GetItInjector;

import '../../../../view_models/notebook_list_view_model.dart';
import '../../../../view_models/notebook_detail_view_model.dart';
import '../../../../widgets/notebook_create_dialog.dart';
import '../../../../widgets/notebook_edit_dialog.dart';
import '../../dialogs/dialogs.dart';
import '../shared/notebook_inline_detail.dart';
import 'desktop_table_widget.dart';

/// Widget desktop com navegação in-page: lista ↔ detalhe.
///
/// Toda a área do DSCard troca de conteúdo — sem Navigator.push,
/// sem Scaffold, sem split panel. O breadcrumb no topo do detalhe
/// permite voltar à lista.
class DesktopPageWidget extends StatefulWidget {
  final NotebookListViewModel viewModel;

  const DesktopPageWidget({super.key, required this.viewModel});

  @override
  State<DesktopPageWidget> createState() => _DesktopPageWidgetState();
}

class _DesktopPageWidgetState extends State<DesktopPageWidget> {
  NotebookDetails? _selected;
  NotebookDetailViewModel? _detailVm;

  // ── Navegação ──────────────────────────────────────────────────

  void _openDetail(NotebookDetails notebook) {
    final vm = GetItInjector().get<NotebookDetailViewModel>();
    setState(() {
      _selected = notebook;
      _detailVm = vm;
    });
    vm.loadNotebook(notebook.id).then((_) {
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

    return DesktopTableWidget(
      viewModel: widget.viewModel,
      onCreateTap: _onCreate,
      onEditTap: _onEdit,
      onViewTap: _openDetail,
    );
  }
}
