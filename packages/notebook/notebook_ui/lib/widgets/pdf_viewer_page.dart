import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notebook_shared/notebook_shared.dart';

/// Page for viewing PDF documents inline.
class PdfViewerPage extends StatefulWidget {
  final DocumentReferenceDetails document;
  final Dio dio;
  final String notebookId;

  const PdfViewerPage({
    super.key,
    required this.document,
    required this.dio,
    required this.notebookId,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfControllerPinch _pdfController;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 0;

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
      // Download PDF (with local cache)
      final pdfData = await _downloadPdf();

      // Initialize PDF controller with downloaded data
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openData(pdfData),
      );

      // Wait for document to load and get page count
      final document = await _pdfController.document;
      final pagesCount = document.pagesCount;

      if (mounted) {
        setState(() {
          _totalPages = pagesCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar PDF: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<Uint8List> _downloadPdf() async {
    final cacheDir = await getApplicationCacheDirectory();
    final cacheFile =
        File('${cacheDir.path}/pdf_cache_${widget.document.id}.pdf');

    if (await cacheFile.exists()) {
      return await cacheFile.readAsBytes();
    }

    final url =
        '/notebooks/${widget.notebookId}/documents/${widget.document.id}/download';
    final response = await widget.dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = Uint8List.fromList(response.data!);

    await cacheFile.writeAsBytes(bytes);
    return bytes;
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.document.name,
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
            Text('Carregando PDF...'),
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

    return PdfViewPinch(
      controller: _pdfController,
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        documentLoaderBuilder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
        pageLoaderBuilder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (_, error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Erro ao renderizar página: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
