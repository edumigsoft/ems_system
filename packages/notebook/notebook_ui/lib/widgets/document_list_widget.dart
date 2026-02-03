import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'pdf_viewer_page.dart';

/// Widget para exibir lista de documentos anexados.
class DocumentListWidget extends StatelessWidget {
  final List<DocumentReferenceDetails> documents;
  final void Function(String documentId)? onDelete;
  final Dio dio;
  final String notebookId;

  const DocumentListWidget({
    super.key,
    required this.documents,
    this.onDelete,
    required this.dio,
    required this.notebookId,
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
          dio: dio,
          notebookId: notebookId,
        );
      }).toList(),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final DocumentReferenceDetails document;
  final VoidCallback? onDelete;
  final Dio dio;
  final String notebookId;

  const _DocumentItem({
    required this.document,
    this.onDelete,
    required this.dio,
    required this.notebookId,
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

          // Preview inline para imagens (apenas servidor, com cache)
          if (isImage && document.storageType == DocumentStorageType.server)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FutureBuilder<Uint8List?>(
                  future: _loadCachedImage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 150,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.data == null) {
                      return Container(
                        height: 150,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: Icon(Icons.broken_image),
                        ),
                      );
                    }
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      height: 150,
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

  Future<void> _viewDocument(BuildContext context) async {
    // Check if it's a PDF
    final isPdf = document.mimeType?.contains('pdf') ?? false;

    if (!isPdf) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visualização disponível apenas para arquivos PDF'),
        ),
      );
      return;
    }

    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => PdfViewerPage(
            document: document,
            dio: dio,
            notebookId: notebookId,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir PDF: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _downloadDocument(BuildContext context) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text('Baixando ${document.name}...'),
              ],
            ),
            duration: const Duration(minutes: 5),
          ),
        );
      }

      // Sandbox do app no mobile; Downloads no desktop
      final Directory targetDir;
      if (Platform.isAndroid || Platform.isIOS) {
        targetDir = await getApplicationDocumentsDirectory();
      } else {
        targetDir =
            await getDownloadsDirectory() ?? await getTemporaryDirectory();
      }

      final filePath = '${targetDir.path}/${document.name}';
      final url =
          '/notebooks/$notebookId/documents/${document.id}/download';
      await dio.download(url, filePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download concluído: ${document.name}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: Platform.isAndroid || Platform.isIOS
                  ? 'Abrir'
                  : 'Abrir pasta',
              onPressed: () async {
                if (Platform.isAndroid || Platform.isIOS) {
                  await launchUrl(Uri.file(filePath),
                      mode: LaunchMode.platformDefault);
                } else {
                  _openFileLocation(targetDir.path);
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar arquivo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<Uint8List?> _loadCachedImage() async {
    final cacheDir = await getApplicationCacheDirectory();
    final ext = document.mimeType?.split('/').last ?? 'jpg';
    final cacheFile =
        File('${cacheDir.path}/img_cache_${document.id}.$ext');

    if (await cacheFile.exists()) return await cacheFile.readAsBytes();

    final url =
        '/notebooks/$notebookId/documents/${document.id}/download';
    try {
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);
      await cacheFile.writeAsBytes(bytes);
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> _openFileLocation(String path) async {
    // Try to open the file manager at the specified location
    // This is platform-dependent and may not work on all systems
    try {
      if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [path]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', [path]);
      }
    } catch (e) {
      // Silently fail if can't open file manager
    }
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

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      // Validate URL
      final uri = Uri.tryParse(url);
      if (uri == null || (!uri.hasScheme)) {
        throw FormatException('URL inválida: $url');
      }

      // Check if URL can be launched
      if (!await canLaunchUrl(uri)) {
        throw Exception('Não foi possível abrir a URL: $url');
      }

      // Launch URL in external browser
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Falha ao abrir o navegador');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir URL: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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
