import 'package:core_shared/core_shared.dart';
import 'package:core_client/core_client.dart' show DioErrorHandler;
import 'package:dio/dio.dart';
import 'package:notebook_shared/notebook_shared.dart';
import '../services/document_reference_api_service.dart';
import '../services/notebook_api_service.dart';

/// HTTP implementation of DocumentReferenceRepository using Retrofit/Dio.
///
/// All methods return [Result] to enable explicit error handling
/// without throwing exceptions (ADR-0001: Result Pattern).
class DocumentReferenceRepositoryClient with Loggable, DioErrorHandler
    implements DocumentReferenceRepository {
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
      return handleDioError(e, context: 'DocumentReferenceRepository.create');
    } catch (e) {
      return handleError(e, 'DocumentReferenceRepository.create');
    }
  }

  @override
  Future<Result<DocumentReferenceDetails>> getById(String id) async {
    try {
      final response = await _api.getById(id);
      return Success(response.toDomain());
    } on DioException catch (e) {
      return handleDioError(e, context: 'DocumentReferenceRepository.getById');
    } catch (e) {
      return handleError(e, 'DocumentReferenceRepository.getById');
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
      return handleDioError(
        e,
        context: 'DocumentReferenceRepository.getByNotebookId',
      );
    } catch (e) {
      return handleError(e, 'DocumentReferenceRepository.getByNotebookId');
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
      return handleDioError(e, context: 'DocumentReferenceRepository.update');
    } catch (e) {
      return handleError(e, 'DocumentReferenceRepository.update');
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _api.delete(id);
      return const Success(null);
    } on DioException catch (e) {
      return handleDioError(e, context: 'DocumentReferenceRepository.delete');
    } catch (e) {
      return handleError(e, 'DocumentReferenceRepository.delete');
    }
  }
}
