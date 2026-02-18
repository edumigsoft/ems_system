import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class _HttpOverrides extends HttpOverrides {
  final bool isDevelopment;

  _HttpOverrides(this.isDevelopment);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    // Ignorar certificado autoassinado apenas em desenvolvimento
    if (isDevelopment) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    }
    return client;
  }
}

/// Page for viewing PDF documents inline.
class PdfViewerPage extends StatefulWidget {
  final String url;
  final String documentName;

  const PdfViewerPage({
    super.key,
    required this.url,
    required this.documentName,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  // ignore: prefer_final_fields
  int _totalPages = 0;
  File? _downloadedFile;

  @override
  void initState() {
    super.initState();
    _initializePdfController();
  }

  Future<void> _initializePdfController() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Verificar se está em ambiente de desenvolvimento
      final uri = Uri.parse(widget.url);
      final host = uri.host;
      final isDevelopment =
          host.contains('localhost') ||
          host.contains('127.0.0.1') ||
          host.contains('192.168.') ||
          host.endsWith('.local');

      // Configurar HttpOverrides global para aceitar certificados autoassinados
      HttpOverrides.global = _HttpOverrides(isDevelopment);

      // Baixar PDF manualmente para evitar problemas de rede/WASM
      final dio = Dio();

      final tempDir = await getTemporaryDirectory();
      final fileName =
          '${widget.documentName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${tempDir.path}/$fileName';

      await dio.download(
        widget.url,
        filePath,
        options: Options(
          headers: {
            'User-Agent': 'EMS-System-PDF-Viewer/1.0',
          },
        ),
      );

      _downloadedFile = File(filePath);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao baixar PDF: $e';
          _isLoading = false;
        });
      }
    } finally {
      // Restaurar HttpOverrides global
      HttpOverrides.global = null;
    }
  }

  @override
  void dispose() {
    // Limpar arquivo temporário baixado
    if (_downloadedFile != null) {
      Future.microtask(() async {
        try {
          if (await _downloadedFile!.exists()) {
            await _downloadedFile!.delete();
          }
        } catch (e) {
          // Ignorar erro ao deletar arquivo temporário
        }
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.documentName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!_isLoading && _error == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'Página $_currentPage de $_totalPages',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Baixando PDF...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializePdfController,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_downloadedFile == null) {
      return const Center(
        child: Text('Arquivo PDF não disponível'),
      );
    }

    return PdfViewer.file(
      _downloadedFile!.path,
      params: PdfViewerParams(
        onPageChanged: (page) {
          setState(() {
            _currentPage = (page ?? 0) + 1; // pdfrx uses 0-based indexing
          });
        },
      ),
    );
  }
}
