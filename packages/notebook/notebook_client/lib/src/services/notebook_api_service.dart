import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:notebook_shared/notebook_shared.dart';

part 'notebook_api_service.g.dart';

/// Retrofit API service for notebook operations.
///
/// Provides type-safe HTTP methods for notebook CRUD operations.
@RestApi()
abstract class NotebookApiService {
  /// Creates a NotebookApiService instance.
  factory NotebookApiService(Dio dio, {String baseUrl}) = _NotebookApiService;

  /// Creates a new notebook.
  ///
  /// POST /notebooks
  @POST('/notebooks')
  Future<NotebookDetailsModel> create(@Body() Map<String, dynamic> body);

  /// Retrieves all notebooks.
  ///
  /// GET /notebooks
  /// Query parameters:
  /// - active_only: filter by active status (default: true)
  /// - search: search term for title/content filtering
  /// - project_id: filter by project
  /// - parent_id: filter by parent notebook
  /// - type: filter by notebook type (quick, organized, reminder)
  /// - tags: filter by tags (comma-separated)
  /// - overdue_only: filter overdue reminders only
  @GET('/notebooks')
  Future<List<NotebookDetailsModel>> getAll({
    @Query('active_only') bool? activeOnly,
    @Query('search') String? search,
    @Query('project_id') String? projectId,
    @Query('parent_id') String? parentId,
    @Query('type') String? type,
    @Query('tags') String? tags,
    @Query('overdue_only') bool? overdueOnly,
  });

  /// Retrieves a notebook by ID.
  ///
  /// GET /notebooks/{id}
  @GET('/notebooks/{id}')
  Future<NotebookDetailsModel> getById(@Path('id') String id);

  /// Updates an existing notebook.
  ///
  /// PUT /notebooks/{id}
  @PUT('/notebooks/{id}')
  Future<NotebookDetailsModel> update(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Soft deletes a notebook.
  ///
  /// DELETE /notebooks/{id}
  @DELETE('/notebooks/{id}')
  Future<void> delete(@Path('id') String id);

  /// Restores a soft-deleted notebook.
  ///
  /// POST /notebooks/{id}/restore
  @POST('/notebooks/{id}/restore')
  Future<void> restore(@Path('id') String id);

  /// Retrieves all documents for a specific notebook.
  ///
  /// GET /notebooks/{id}/documents
  @GET('/notebooks/{id}/documents')
  Future<List<DocumentReferenceDetailsModel>> getDocuments(
    @Path('id') String id, {
    @Query('storage_type') String? storageType,
  });
}
