import 'package:core_shared/core_shared.dart';
import 'package:core_client/core_client.dart' show DioErrorHandler;
import 'package:dio/dio.dart';
import 'package:notebook_shared/notebook_shared.dart';
import '../services/notebook_api_service.dart';

/// HTTP implementation of NotebookRepository using Retrofit/Dio.
///
/// All methods return [Result] to enable explicit error handling
/// without throwing exceptions (ADR-0001: Result Pattern).
class NotebookRepositoryClient with Loggable, DioErrorHandler
    implements NotebookRepository {
  final NotebookApiService _api;

  /// Creates a NotebookRepositoryClient instance.
  NotebookRepositoryClient(this._api);

  @override
  Future<Result<NotebookDetails>> create(NotebookCreate data) async {
    try {
      final model = NotebookCreateModel.fromDomain(data);
      final response = await _api.create(model.toJson());
      return Success(response.toDomain());
    } on DioException catch (e) {
      return handleDioError(e, context: 'NotebookRepository.create');
    } catch (e) {
      return handleError(e, 'NotebookRepository.create');
    }
  }

  @override
  Future<Result<NotebookDetails>> getById(String id) async {
    try {
      final response = await _api.getById(id);
      return Success(response.toDomain());
    } on DioException catch (e) {
      return handleDioError(e, context: 'NotebookRepository.getById');
    } catch (e) {
      return handleError(e, 'NotebookRepository.getById');
    }
  }

  @override
  Future<Result<List<NotebookDetails>>> getAll({
    bool activeOnly = true,
    String? search,
    String? projectId,
    String? parentId,
    NotebookType? type,
    List<String>? tags,
    bool overdueOnly = false,
  }) async {
    try {
      final response = await _api.getAll(
        activeOnly: activeOnly,
        search: search,
        projectId: projectId,
        parentId: parentId,
        type: type?.name,
        tags: tags?.join(','),
        overdueOnly: overdueOnly,
      );
      final entities = response.map((model) => model.toDomain()).toList();
      return Success(entities);
    } on DioException catch (e) {
      return handleDioError(e, context: 'NotebookRepository.getAll');
    } catch (e) {
      return handleError(e, 'NotebookRepository.getAll');
    }
  }

  @override
  Future<Result<NotebookDetails>> update(NotebookUpdate data) async {
    try {
      final model = NotebookUpdateModel.fromDomain(data);
      final response = await _api.update(data.id, model.toJson());
      return Success(response.toDomain());
    } on DioException catch (e) {
      return handleDioError(e, context: 'NotebookRepository.update');
    } catch (e) {
      return handleError(e, 'NotebookRepository.update');
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _api.delete(id);
      return const Success(null);
    } on DioException catch (e) {
      return handleDioError(e, context: 'NotebookRepository.delete');
    } catch (e) {
      return handleError(e, 'NotebookRepository.delete');
    }
  }

  @override
  Future<Result<void>> restore(String id) async {
    try {
      await _api.restore(id);
      return const Success(null);
    } on DioException catch (e) {
      return handleDioError(e, context: 'NotebookRepository.restore');
    } catch (e) {
      return handleError(e, 'NotebookRepository.restore');
    }
  }
}
