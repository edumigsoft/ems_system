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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
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
            Text(_getStorageTypeLabel(document.storageType)),
            if (document.sizeBytes != null)
              Text(_formatSize(document.sizeBytes!)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (document.storageType == DocumentStorageType.url)
              IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => _openUrl(context, document.path),
                tooltip: 'Abrir link',
              ),
            if (onDelete != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                onPressed: onDelete,
                tooltip: 'Excluir',
              ),
          ],
        ),
      ),
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

  String _getStorageTypeLabel(DocumentStorageType type) {
    return switch (type) {
      DocumentStorageType.server => 'Servidor',
      DocumentStorageType.local => 'Arquivo local',
      DocumentStorageType.url => 'Link externo',
    };
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _openUrl(BuildContext context, String url) {
    // Implementar abertura de URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrindo: $url')),
    );
  }
}
