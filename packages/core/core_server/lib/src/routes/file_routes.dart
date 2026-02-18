import 'dart:convert';
import 'package:auth_server/auth_server.dart' show AuthMiddleware;
import '../../core_server.dart' show Routes;
import 'package:core_shared/core_shared.dart' show StorageService;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Rotas para serving de arquivos com autenticação.
///
/// Fornece acesso seguro aos arquivos uploadados,
/// verificando autenticação antes de permitir o download.
class FileRoutes extends Routes {
  final StorageService _storageService;
  final AuthMiddleware _authMiddleware;

  FileRoutes(this._storageService, this._authMiddleware)
    : super(security: true);

  @override
  String get path => '/files';

  @override
  Router get router {
    final router = Router();

    // GET /files/:key - Download de arquivo com autenticação
    router.get(
      '/<key>',
      Pipeline()
          .addMiddleware(_authMiddleware.verifyJwt)
          .addHandler(_downloadFile),
    );

    return router;
  }

  /// Faz download de um arquivo armazenado
  ///
  /// [request] - Requisição HTTP
  Future<Response> _downloadFile(Request request) async {
    final key = request.params['key'] ?? '';
    final authContext = request.context['authContext'];
    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      // Verificar se arquivo existe
      final fileExists = await _storageService.fileExists(key);
      if (!fileExists) {
        return Response.notFound(
          jsonEncode({'error': 'File not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Recuperar arquivo
      final fileBytes = await _storageService.retrieveFile(key);

      // Determinar MIME type (poderia ser armazenado no banco)
      // Por enquanto, usa detecção baseada na extensão
      final mimeType = _getMimeTypeFromKey(key);

      return Response.ok(
        fileBytes,
        headers: {
          'Content-Type': mimeType,
          'Content-Disposition': 'inline; filename="$_getFileNameFromKey(key)"',
          'Cache-Control': 'private, max-age=3600',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to download file: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Extrai MIME type da chave do arquivo
  String _getMimeTypeFromKey(String key) {
    final extension = key.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  /// Extrai nome original do arquivo da chave
  String _getFileNameFromKey(String key) {
    // Remove estrutura de diretórios (ano/mês/)
    final fileName = key.split('/').last;

    // Se tiver UUID, extrai apenas o nome original
    if (fileName.contains('_')) {
      final parts = fileName.split('_');
      if (parts.length >= 2) {
        final uuidPart = parts.last;
        final extension = uuidPart.split('.').last;
        return 'downloaded_file.$extension';
      }
    }

    return fileName;
  }
}
