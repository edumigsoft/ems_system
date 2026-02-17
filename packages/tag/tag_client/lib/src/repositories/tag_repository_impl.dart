import 'package:core_shared/core_shared.dart';
import 'package:core_client/core_client.dart' show DioErrorHandler;
import 'package:dio/dio.dart';
import 'package:tag_shared/tag_shared.dart';
import '../services/tag_api_service.dart';

/// HTTP implementation of TagRepository using Retrofit/Dio.
///
/// All methods return [Result] to enable explicit error handling
/// without throwing exceptions (ADR-0001: Result Pattern).
class TagRepositoryImpl with Loggable, DioErrorHandler
    implements TagRepository {
  final TagApiService _api;

  /// Creates a TagRepositoryImpl instance.
  TagRepositoryImpl(this._api);

  @override
  Future<Result<TagDetails>> create(TagCreate data) async {
    try {
      final model = TagCreateModel.fromDomain(data);
      final response = await _api.create(model.toJson());
      return Success(response.toDomain());
    } on DioException catch (e) {
      return handleDioError(e, context: 'TagRepository.create');
    } catch (e) {
      return handleError(e, 'TagRepository.create');
    }
  }

  @override
  Future<Result<TagDetails>> getById(String id) async {
    try {
      final response = await _api.getById(id);
      return Success(response.toDomain());
    } on DioException catch (e) {
      return handleDioError(e, context: 'TagRepository.getById');
    } catch (e) {
      return handleError(e, 'TagRepository.getById');
    }
  }

  @override
  Future<Result<List<TagDetails>>> getAll({
    bool activeOnly = true,
    String? search,
  }) async {
    try {
      final response = await _api.getAll(
        activeOnly: activeOnly,
        search: search,
      );
      final entities = response.map((model) => model.toDomain()).toList();
      return Success(entities);
    } on DioException catch (e) {
      return handleDioError(e, context: 'TagRepository.getAll');
    } catch (e) {
      return handleError(e, 'TagRepository.getAll');
    }
  }

  @override
  Future<Result<TagDetails>> update(TagUpdate data) async {
    try {
      final model = TagUpdateModel.fromDomain(data);
      final response = await _api.update(data.id, model.toJson());
      return Success(response.toDomain());
    } on DioException catch (e) {
      return handleDioError(e, context: 'TagRepository.update');
    } catch (e) {
      return handleError(e, 'TagRepository.update');
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _api.delete(id);
      return const Success(null);
    } on DioException catch (e) {
      return handleDioError(e, context: 'TagRepository.delete');
    } catch (e) {
      return handleError(e, 'TagRepository.delete');
    }
  }

  @override
  Future<Result<void>> restore(String id) async {
    try {
      await _api.restore(id);
      return const Success(null);
    } on DioException catch (e) {
      return handleDioError(e, context: 'TagRepository.restore');
    } catch (e) {
      return handleError(e, 'TagRepository.restore');
    }
  }
}
