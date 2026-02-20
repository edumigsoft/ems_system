import 'dart:convert';
import 'package:auth_server/auth_server.dart' show AuthMiddleware, AuthContext;
import 'package:core_server/core_server.dart' show Routes, StorageService;
import 'package:core_shared/core_shared.dart'
    show DependencyInjector, DataException, StorageValidation;
import 'package:notebook_shared/notebook_shared.dart'
    show
        NotebookDetailsModel,
        NotebookCreateModel,
        NotebookUpdateModel,
        NotebookRepository,
        DocumentReferenceRepository,
        DocumentReferenceDetailsModel,
        DocumentReferenceCreate,
        DocumentStorageType,
        NotebookType;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/form_data.dart';
import 'package:mime/mime.dart';

/// Rotas de gerenciamento de notebooks.
///
/// **Endpoints Públicos (autenticado):**
/// - POST /notebooks - Criar notebook
/// - GET /notebooks - Listar notebooks do usuário (com filtros)
/// - GET /notebooks/:id - Buscar notebook por ID
/// - PUT /notebooks/:id - Atualizar notebook
/// - DELETE /notebooks/:id - Soft delete de notebook
/// - POST /notebooks/:id/restore - Restaurar notebook deletado
///
/// **Autorização:**
/// - Usuários podem gerenciar apenas seus próprios notebooks
/// - Admins e owners podem gerenciar qualquer notebook
class NotebookRoutes extends Routes {
  final NotebookRepository notebookRepository;
  final DocumentReferenceRepository documentRepository;
  final StorageService storageService;
  final AuthMiddleware authMiddleware;
  final DependencyInjector di;
  final String _backendBaseApi;

  NotebookRoutes(
    this.notebookRepository,
    this.documentRepository,
    this.storageService,
    this.authMiddleware,
    this.di, {
    required String backendBaseApi,
  }) : _backendBaseApi = backendBaseApi,
       super(security: true);

  @override
  String get path => '$_backendBaseApi/notebooks';

  @override
  Router get router {
    final router = Router();

    // Middleware de autenticação (todos os endpoints requerem autenticação)
    final authedMiddleware = authMiddleware.verifyJwt;

    router.post(
      '/',
      Pipeline().addMiddleware(authedMiddleware).addHandler(_createNotebook),
    );

    router.get(
      '/',
      Pipeline().addMiddleware(authedMiddleware).addHandler(_listNotebooks),
    );

    router.get(
      '/<id>',
      Pipeline()
          .addMiddleware(authedMiddleware)
          .addHandler(
            (req) => _getNotebookById(req, req.params['id']!),
          ),
    );

    router.put(
      '/<id>',
      Pipeline()
          .addMiddleware(authedMiddleware)
          .addHandler(
            (req) => _updateNotebook(req, req.params['id']!),
          ),
    );

    router.delete(
      '/<id>',
      Pipeline()
          .addMiddleware(authedMiddleware)
          .addHandler(
            (req) => _deleteNotebook(req, req.params['id']!),
          ),
    );

    router.post(
      '/<id>/restore',
      Pipeline()
          .addMiddleware(authedMiddleware)
          .addHandler(
            (req) => _restoreNotebook(req, req.params['id']!),
          ),
    );

    // GET /notebooks/:id/documents - Listar documentos de um notebook
    router.get(
      '/<id>/documents',
      Pipeline()
          .addMiddleware(authedMiddleware)
          .addHandler(
            (req) => _getNotebookDocuments(req, req.params['id']!),
          ),
    );

    // POST /notebooks/:id/documents/upload - Upload de arquivo
    router.post(
      '/<id>/documents/upload',
      Pipeline()
          .addMiddleware(authedMiddleware)
          .addHandler(
            (req) => _uploadDocument(req, req.params['id']!),
          ),
    );

    return router;
  }

  /// POST /notebooks - Cria um novo notebook.
  Future<Response> _createNotebook(Request request) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final createModel = NotebookCreateModel.fromJson(json);
      final createDto = createModel.toDomain();

      // Validar DTO
      if (!createDto.isValid) {
        return Response(
          422,
          body: jsonEncode({'error': 'Invalid notebook data'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Criar notebook
      final result = await notebookRepository.create(createDto);

      return result.when(
        success: (notebook) {
          final model = NotebookDetailsModel.fromDomain(notebook);
          return Response(
            201,
            body: jsonEncode(model.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        },
        failure: (exception) {
          return Response.internalServerError(
            body: jsonEncode({'error': 'Failed to create notebook'}),
            headers: {'Content-Type': 'application/json'},
          );
        },
      );
    } catch (e) {
      return Response(
        400,
        body: jsonEncode({'error': 'Invalid request body'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /notebooks - Lista notebooks com filtros.
  Future<Response> _listNotebooks(Request request) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final queryParams = request.url.queryParameters;

      // Extrair filtros
      final activeOnly = queryParams['active_only'] != 'false';
      final search = queryParams['search'];
      final projectId = queryParams['project_id'];
      final parentId = queryParams['parent_id'];
      final overdueOnly = queryParams['overdue_only'] == 'true';

      // Filtro de tipo
      NotebookType? type;
      final typeParam = queryParams['type'];
      if (typeParam != null) {
        try {
          type = NotebookType.values.firstWhere((t) => t.name == typeParam);
        } catch (_) {
          return Response(
            400,
            body: jsonEncode({'error': 'Invalid type filter'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      // Filtro de tags (separadas por vírgula)
      List<String>? tags;
      final tagsParam = queryParams['tags'];
      if (tagsParam != null && tagsParam.isNotEmpty) {
        tags = tagsParam.split(',');
      }

      // Buscar notebooks
      final result = await notebookRepository.getAll(
        activeOnly: activeOnly,
        search: search,
        projectId: projectId,
        parentId: parentId,
        type: type,
        tags: tags,
        overdueOnly: overdueOnly,
      );

      return result.when(
        success: (notebooks) {
          final models = notebooks
              .map((n) => NotebookDetailsModel.fromDomain(n).toJson())
              .toList();
          return Response.ok(
            jsonEncode(models),
            headers: {'Content-Type': 'application/json'},
          );
        },
        failure: (exception) {
          return Response.internalServerError(
            body: jsonEncode({'error': 'Failed to fetch notebooks'}),
            headers: {'Content-Type': 'application/json'},
          );
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Internal server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET /notebooks/:id - Busca notebook por ID.
  Future<Response> _getNotebookById(Request request, String id) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (id.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'Notebook ID is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final result = await notebookRepository.getById(id);

    return result.when(
      success: (notebook) {
        final model = NotebookDetailsModel.fromDomain(notebook);
        return Response.ok(
          jsonEncode(model.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      },
      failure: (exception) {
        if (exception is DataException) {
          return Response.notFound(
            jsonEncode({'error': 'Notebook not found'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to fetch notebook'}),
          headers: {'Content-Type': 'application/json'},
        );
      },
    );
  }

  /// PUT /notebooks/:id - Atualiza notebook.
  Future<Response> _updateNotebook(Request request, String id) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (id.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'Notebook ID is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      // Adicionar ID ao JSON antes de criar o model
      json['id'] = id;

      final updateModel = NotebookUpdateModel.fromJson(json);
      final updateDto = updateModel.toDomain();

      // Atualizar notebook
      final result = await notebookRepository.update(updateDto);

      return result.when(
        success: (notebook) {
          final model = NotebookDetailsModel.fromDomain(notebook);
          return Response.ok(
            jsonEncode(model.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        },
        failure: (exception) {
          if (exception is DataException) {
            return Response.notFound(
              jsonEncode({'error': exception.message}),
              headers: {'Content-Type': 'application/json'},
            );
          }
          return Response.internalServerError(
            body: jsonEncode({'error': 'Failed to update notebook'}),
            headers: {'Content-Type': 'application/json'},
          );
        },
      );
    } catch (e) {
      return Response(
        400,
        body: jsonEncode({'error': 'Invalid request body'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// DELETE /notebooks/:id - Soft delete de notebook.
  Future<Response> _deleteNotebook(Request request, String id) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (id.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'Notebook ID is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final result = await notebookRepository.delete(id);

    return result.when(
      success: (_) {
        return Response(204, headers: {'Content-Type': 'application/json'});
      },
      failure: (exception) {
        if (exception is DataException) {
          return Response.notFound(
            jsonEncode({'error': exception.message}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to delete notebook'}),
          headers: {'Content-Type': 'application/json'},
        );
      },
    );
  }

  /// POST /notebooks/:id/restore - Restaura notebook deletado.
  Future<Response> _restoreNotebook(Request request, String id) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (id.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'Notebook ID is required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final result = await notebookRepository.restore(id);

    return result.when(
      success: (_) {
        return Response.ok(
          jsonEncode({'message': 'Notebook restored successfully'}),
          headers: {'Content-Type': 'application/json'},
        );
      },
      failure: (exception) {
        if (exception is DataException) {
          return Response.notFound(
            jsonEncode({'error': exception.message}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to restore notebook'}),
          headers: {'Content-Type': 'application/json'},
        );
      },
    );
  }

  /// GET /notebooks/:id/documents - Lista documentos de um notebook.
  Future<Response> _getNotebookDocuments(Request request, String id) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final queryParams = request.url.queryParameters;

      // Filtro por tipo de armazenamento
      DocumentStorageType? storageType;
      final storageTypeParam = queryParams['storage_type'];
      if (storageTypeParam != null) {
        try {
          storageType = DocumentStorageType.values.firstWhere(
            (t) => t.name == storageTypeParam,
          );
        } catch (_) {
          return Response(
            400,
            body: jsonEncode({'error': 'Invalid storage_type filter'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      final result = await documentRepository.getByNotebookId(
        id,
        storageType: storageType,
      );

      return result.when(
        success: (documents) {
          final models = documents
              .map((d) => DocumentReferenceDetailsModel.fromDomain(d).toJson())
              .toList();
          return Response.ok(
            jsonEncode(models),
            headers: {'Content-Type': 'application/json'},
          );
        },
        failure: (exception) {
          return Response.internalServerError(
            body: jsonEncode({'error': 'Failed to fetch documents'}),
            headers: {'Content-Type': 'application/json'},
          );
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Internal server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /notebooks/:id/documents/upload - Upload de arquivo.
  ///
  /// Recebe um arquivo via multipart/form-data, valida e salva usando StorageService,
  /// e cria uma referência no banco de dados.
  Future<Response> _uploadDocument(Request request, String id) async {
    final authContext = request.context['authContext'] as AuthContext?;

    if (authContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Authentication required'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      // Verificar se é multipart/form-data
      if (!request.isMultipartForm) {
        return Response(
          400,
          body: jsonEncode({
            'error': 'Content-Type must be multipart/form-data',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      String? fileName;
      String? storageKey;
      int? fileSize;
      String? mimeType;

      // Processar partes do multipart
      await for (final formData in request.multipartFormData) {
        // Procurar pela parte 'file'
        if (formData.name == 'file') {
          // Extrair nome do arquivo
          fileName = formData.filename ?? 'unnamed_file';

          // Ler bytes do arquivo
          final bytes = await formData.part.readBytes();

          // Validar arquivo usando StorageValidation
          final validation = StorageValidation.validateFile(
            bytes,
            fileName,
            lookupMimeType(fileName) ?? 'application/octet-stream',
          );

          if (!validation.isValid) {
            return Response(
              400,
              body: jsonEncode({
                'error': validation.errorMessage,
              }),
              headers: {'Content-Type': 'application/json'},
            );
          }

          // Armazenar arquivo usando StorageService
          storageKey = await storageService.storeFile(
            bytes,
            fileName,
            lookupMimeType(fileName) ?? 'application/octet-stream',
          );

          fileSize = bytes.length;
          mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
          break; // Processar apenas o primeiro arquivo
        }
      }

      // Verificar se arquivo foi recebido
      if (fileName == null || storageKey == null) {
        return Response(
          400,
          body: jsonEncode({'error': 'No file provided in upload'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Criar referência no banco de dados
      final createDto = DocumentReferenceCreate(
        name: fileName,
        path: storageKey, // Armazenar apenas a chave do StorageService
        storageType: DocumentStorageType.server,
        mimeType: mimeType,
        sizeBytes: fileSize,
        notebookId: id,
      );

      final result = await documentRepository.create(createDto);

      return result.when(
        success: (document) {
          final model = DocumentReferenceDetailsModel.fromDomain(document);
          return Response(
            201,
            body: jsonEncode(model.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        },
        failure: (exception) async {
          // Limpar arquivo em caso de erro ao criar referência
          if (storageKey != null) {
            try {
              await storageService.deleteFile(storageKey);
            } catch (_) {
              // Ignorar erro ao deletar arquivo
            }
          }

          return Response.internalServerError(
            body: jsonEncode({
              'error':
                  'Failed to create document reference: ${exception.toString()}',
            }),
            headers: {'Content-Type': 'application/json'},
          );
        },
      );
    } catch (e, stackTrace) {
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Upload failed: ${e.toString()}',
          'details': stackTrace.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
