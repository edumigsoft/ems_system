import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';

/// Widget para exibir hierarquia de cadernos em estrutura de árvore.
///
/// Mostra cadernos pai e filhos com expansão/colapso de níveis.
class NotebookHierarchyWidget extends StatefulWidget {
  final List<NotebookDetails> notebooks;
  final String? currentNotebookId;
  final ValueChanged<String> onNotebookTap;
  final int maxDepth;

  const NotebookHierarchyWidget({
    super.key,
    required this.notebooks,
    this.currentNotebookId,
    required this.onNotebookTap,
    this.maxDepth = 3,
  });

  @override
  State<NotebookHierarchyWidget> createState() =>
      _NotebookHierarchyWidgetState();
}

class _NotebookHierarchyWidgetState extends State<NotebookHierarchyWidget> {
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    // Expande o caminho até o caderno atual
    if (widget.currentNotebookId != null) {
      _expandPathTo(widget.currentNotebookId!);
    }
  }

  void _expandPathTo(String notebookId) {
    final notebook = widget.notebooks.firstWhere(
      (n) => n.id == notebookId,
      orElse: () => widget.notebooks.first,
    );

    if (notebook.parentId != null) {
      _expandedIds.add(notebook.parentId!);
      _expandPathTo(notebook.parentId!);
    }
  }

  List<NotebookDetails> _getRootNotebooks() {
    return widget.notebooks.where((n) => n.parentId == null).toList();
  }

  List<NotebookDetails> _getChildren(String parentId) {
    return widget.notebooks.where((n) => n.parentId == parentId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rootNotebooks = _getRootNotebooks();

    if (rootNotebooks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rootNotebooks
          .map((notebook) => _buildNotebookTile(notebook, 0))
          .toList(),
    );
  }

  Widget _buildNotebookTile(NotebookDetails notebook, int depth) {
    final children = _getChildren(notebook.id);
    final hasChildren = children.isNotEmpty;
    final isExpanded = _expandedIds.contains(notebook.id);
    final isCurrent = notebook.id == widget.currentNotebookId;
    final canExpand = depth < widget.maxDepth;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => widget.onNotebookTap(notebook.id),
          child: Container(
            padding: EdgeInsets.only(
              left: 16.0 + (depth * 24.0),
              right: 16,
              top: 12,
              bottom: 12,
            ),
            color: isCurrent
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : null,
            child: Row(
              children: [
                // Botão de expansão
                if (hasChildren && canExpand)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedIds.remove(notebook.id);
                        } else {
                          _expandedIds.add(notebook.id);
                        }
                      });
                    },
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                else if (hasChildren && !canExpand)
                  Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  )
                else
                  const SizedBox(width: 20),

                const SizedBox(width: 8),

                // Ícone do tipo
                _getTypeIcon(notebook.type, colorScheme),
                const SizedBox(width: 12),

                // Título
                Expanded(
                  child: Text(
                    notebook.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isCurrent ? FontWeight.w600 : null,
                      color: isCurrent ? colorScheme.primary : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Indicador de seleção
                if (isCurrent)
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),

        // Filhos (se expandido)
        if (hasChildren && isExpanded && canExpand)
          ...children.map((child) => _buildNotebookTile(child, depth + 1)),
      ],
    );
  }

  Widget _getTypeIcon(NotebookType? type, ColorScheme colorScheme) {
    IconData iconData;
    Color color;

    switch (type) {
      case NotebookType.quick:
        iconData = Icons.notes;
        color = colorScheme.tertiary;
        break;
      case NotebookType.organized:
        iconData = Icons.menu_book;
        color = colorScheme.primary;
        break;
      case NotebookType.reminder:
        iconData = Icons.bookmark;
        color = colorScheme.secondary;
        break;
      default:
        iconData = Icons.description;
        color = colorScheme.onSurfaceVariant;
    }

    return Icon(iconData, size: 18, color: color);
  }
}
