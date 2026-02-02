import 'package:core_shared/core_shared.dart';
import 'package:dio/dio.dart';
import 'package:notebook_shared/notebook_shared.dart';
import '../services/notebook_api_service.dart';

/// HTTP implementation of NotebookRepository using Retrofit/Dio.
///
/// All methods return [Result] to enable explicit error handling
/// without throwing exceptions (ADR-0001: Result Pattern).
class NotebookRepositoryClient implements NotebookRepository {
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
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure(Exception('Erro ao criar notebook: $e'));
    }
  }

  @override
  Future<Result<NotebookDetails>> getById(String id) async {
    try {
      final response = await _api.getById(id);
      return Success(response.toDomain());
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure(Exception('Erro ao buscar notebook: $e'));
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
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure(Exception('Erro ao listar notebooks: $e'));
    }
  }

  @override
  Future<Result<NotebookDetails>> update(NotebookUpdate data) async {
    try {
      final model = NotebookUpdateModel.fromDomain(data);
      final response = await _api.update(data.id, model.toJson());
      return Success(response.toDomain());
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure(Exception('Erro ao atualizar notebook: $e'));
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
      return Failure(Exception('Erro ao deletar notebook: $e'));
    }
  }

  @override
  Future<Result<void>> restore(String id) async {
    try {
      await _api.restore(id);
      return const Success(null);
    } on DioException catch (e) {
      return Failure(_handleDioError(e));
    } catch (e) {
      return Failure(Exception('Erro ao restaurar notebook: $e'));
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
            return Exception('Notebook não encontrado');
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
