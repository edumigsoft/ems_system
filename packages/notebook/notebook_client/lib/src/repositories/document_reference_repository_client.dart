import 'package:core_shared/core_shared.dart';
import 'package:dio/dio.dart';
import 'package:notebook_shared/notebook_shared.dart';
import '../services/document_reference_api_service.dart';
import '../services/notebook_api_service.dart';

/// HTTP implementation of DocumentReferenceRepository using Retrofit/Dio.
///
/// All methods return [Result] to enable explicit error handling
/// without throwing exceptions (ADR-0001: Result Pattern).
class DocumentReferenceRepositoryClient implements DocumentReferenceRepository {
  final DocumentReferenceApiService _api;
  final NotebookApiService _notebookApi;

  /// Creates a DocumentReferenceRepositoryClient instance.
  DocumentReferenceRepositoryClient(this._api, this._notebookApi);

  @override
  Future<Result<DocumentReferenceDetails>> create(
    DocumentReferenceCreate data,
  ) async {
    try {
      final model = DocumentReferenceCreateModel.fromDomain(data);
      final response = await _api.create(model.toJson());
      return Success(response.toDomain());
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure(Exception('Erro ao criar referência de documento: $e'));
    }
  }

  @override
  Future<Result<DocumentReferenceDetails>> getById(String id) async {
    try {
      final response = await _api.getById(id);
      return Success(response.toDomain());
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure(Exception('Erro ao buscar referência de documento: $e'));
    }
  }

  @override
  Future<Result<List<DocumentReferenceDetails>>> getByNotebookId(
    String notebookId, {
    DocumentStorageType? storageType,
  }) async {
    try {
      // Uses NotebookApiService.getDocuments endpoint
      final response = await _notebookApi.getDocuments(
        notebookId,
        storageType: storageType?.name,
      );
      final entities = response.map((model) => model.toDomain()).toList();
      return Success(entities);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure(
        Exception('Erro ao listar documentos do notebook: $e'),
      );
    }
  }

  @override
  Future<Result<DocumentReferenceDetails>> update(
    DocumentReferenceUpdate data,
  ) async {
    try {
      final model = DocumentReferenceUpdateModel.fromDomain(data);
      final response = await _api.update(data.id, model.toJson());
      return Success(response.toDomain());
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure(
        Exception('Erro ao atualizar referência de documento: $e'),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _api.delete(id);
      return const Success(null);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure(Exception('Erro ao deletar referência de documento: $e'));
    }
  }

  /// Handles DioException and converts to meaningful error messages.
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Tempo de conexão esgotado. Verifique sua internet.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final message =
            (data is Map ? data['message'] as String? : null) ??
            'Erro desconhecido';

        switch (statusCode) {
          case 400:
            return Exception('Dados inválidos: $message');
          case 404:
            return Exception('Documento não encontrado');
          case 409:
            return Exception('Conflito: $message');
          case 500:
            return Exception('Erro no servidor. Tente novamente mais tarde.');
          default:
            return Exception('Erro HTTP $statusCode: $message');
        }

      case DioExceptionType.cancel:
        return Exception('Requisição cancelada');

      case DioExceptionType.connectionError:
        return Exception('Erro de conexão. Verifique sua internet.');

      case DioExceptionType.badCertificate:
        return Exception('Erro de certificado SSL');

      case DioExceptionType.unknown:
        return Exception('Erro inesperado: ${e.message}');
    }
  }
}
