import 'dart:convert';
import 'package:auth_server/auth_server.dart' show AuthMiddleware, AuthContext;
import 'package:core_server/core_server.dart' show Routes, StorageService;
import 'package:notebook_shared/notebook_shared.dart'
    show DocumentReferenceRepository, DocumentStorageType;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Rotas de gerenciamento de documentos.
///
/// **Endpoints (autenticado):**
/// - DELETE /documents/:id - Exclui documento (arquivo físico + registro no banco)
class DocumentRoutes extends Routes {
  final DocumentReferenceRepository documentRepository;
  final StorageService storageService;
  final AuthMiddleware authMiddleware;
  final String _backendBaseApi;

  DocumentRoutes(
    this.documentRepository,
    this.storageService,
    this.authMiddleware, {
    required String backendBaseApi,
  }) : _backendBaseApi = backendBaseApi,
       super(security: true);

  @override
  String get path => '$_backendBaseApi/documents';

  @override
  Router get router {
    final router = Router();

    final authedMiddleware = authMiddleware.verifyJwt;

    router.delete(
      '/<id>',
      Pipeline()
          .addMiddleware(authedMiddleware)
          .addHandler(
            (req) => _deleteDocument(req, req.params['id']!),
          ),
    );

    return router;
  }

  /// DELETE /documents/:id - Exclui documento e arquivo físico.
  Future<Response> _deleteDocument(Request request, String id) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    // Buscar documento para obter path e storageType
    final getResult = await documentRepository.getById(id);

    if (getResult.isFailure) {
      return Response.notFound(
        jsonEncode({'error': 'Document not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final document = getResult.valueOrNull!;

    // Remover arquivo físico se armazenado no servidor
    if (document.storageType == DocumentStorageType.server) {
      try {
        await storageService.deleteFile(document.path);
      } catch (_) {
        // Arquivo pode não existir no disco — ignorar e prosseguir
      }
    }

    // Remover registro do banco independentemente do resultado acima
    final deleteResult = await documentRepository.delete(id);

    if (deleteResult.isFailure) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete document'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response(204);
  }
}
