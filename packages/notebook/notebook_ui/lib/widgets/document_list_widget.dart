import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';

/// Widget para exibir lista de documentos anexados.
class DocumentListWidget extends StatelessWidget {
  final List<DocumentReferenceDetails> documents;
  final void Function(String documentId)? onDelete;

  const DocumentListWidget({
    super.key,
    required this.documents,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (documents.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.onSurface.withAlpha(64),
              ),
              const SizedBox(width: 12),
              Text(
                'Nenhum documento anexado',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(64),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: documents.map((doc) {
        return _DocumentItem(
          document: doc,
          onDelete: onDelete != null ? () => onDelete!(doc.id) : null,
        );
      }).toList(),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final DocumentReferenceDetails document;
  final VoidCallback? onDelete;

  const _DocumentItem({
    required this.document,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isImage = document.mimeType?.startsWith('image/') ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                _getIconForDocument(document),
                color: theme.colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            title: Text(
              document.name,
              style: theme.textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StorageTypeChip(type: document.storageType),
                    if (document.sizeBytes != null) ...[
                      const SizedBox(width: 8),
                      Text(_formatSize(document.sizeBytes!)),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleAction(context, value),
              itemBuilder: (context) => [
                if (document.storageType == DocumentStorageType.server) ...[
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility),
                        SizedBox(width: 8),
                        Text('Visualizar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Baixar'),
                      ],
                    ),
                  ),
                ],
                if (document.storageType == DocumentStorageType.url)
                  const PopupMenuItem(
                    value: 'open_url',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_new),
                        SizedBox(width: 8),
                        Text('Abrir link'),
                      ],
                    ),
                  ),
                if (document.storageType == DocumentStorageType.local)
                  const PopupMenuItem(
                    value: 'open_local',
                    child: Row(
                      children: [
                        Icon(Icons.folder_open),
                        SizedBox(width: 8),
                        Text('Abrir local'),
                      ],
                    ),
                  ),
                if (onDelete != null) ...[
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Excluir', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Preview inline para imagens (apenas servidor)
          if (isImage && document.storageType == DocumentStorageType.server)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  document.path,
                  fit: BoxFit.cover,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.broken_image),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'view':
        _viewDocument(context);
        break;
      case 'download':
        _downloadDocument(context);
        break;
      case 'open_url':
        _openUrl(context, document.path);
        break;
      case 'open_local':
        _openLocal(context);
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  void _viewDocument(BuildContext context) {
    // TODO: Implementar visualização inline de PDF
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Visualizando: ${document.name}')),
    );
  }

  void _downloadDocument(BuildContext context) {
    // TODO: Implementar download para pasta Downloads
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Baixando: ${document.name}')),
    );
  }

  void _openLocal(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrindo local: ${document.path}')),
    );
  }

  IconData _getIconForDocument(DocumentReferenceDetails doc) {
    if (doc.mimeType == null) {
      return switch (doc.storageType) {
        DocumentStorageType.url => Icons.link,
        DocumentStorageType.local => Icons.folder,
        DocumentStorageType.server => Icons.cloud,
      };
    }

    if (doc.mimeType!.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (doc.mimeType!.startsWith('image/')) {
      return Icons.image;
    } else if (doc.mimeType!.contains('word') ||
        doc.mimeType!.contains('document')) {
      return Icons.description;
    } else if (doc.mimeType!.contains('excel') ||
        doc.mimeType!.contains('spreadsheet')) {
      return Icons.table_chart;
    } else {
      return Icons.insert_drive_file;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _openUrl(BuildContext context, String url) {
    // TODO: Implementar abertura de URL com url_launcher
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrindo: $url')),
    );
  }
}

class _StorageTypeChip extends StatelessWidget {
  final DocumentStorageType type;

  const _StorageTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, label, color) = switch (type) {
      DocumentStorageType.server => (
        Icons.cloud_done,
        'Servidor',
        theme.colorScheme.primary,
      ),
      DocumentStorageType.local => (
        Icons.computer,
        'Local',
        theme.colorScheme.tertiary,
      ),
      DocumentStorageType.url => (
        Icons.link,
        'Link',
        theme.colorScheme.secondary,
      ),
    };

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      labelStyle: theme.textTheme.labelSmall,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: color.withAlpha(77)),
      backgroundColor: color.withAlpha(26),
    );
  }
}
