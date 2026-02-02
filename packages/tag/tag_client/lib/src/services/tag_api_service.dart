import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:tag_shared/tag_shared.dart';

part 'tag_api_service.g.dart';

/// Retrofit API service for tag operations.
///
/// Provides type-safe HTTP methods for tag CRUD operations.
@RestApi()
abstract class TagApiService {
  /// Creates a TagApiService instance.
  factory TagApiService(Dio dio, {String baseUrl}) = _TagApiService;

  /// Creates a new tag.
  ///
  /// POST /tags
  @POST('/tags')
  Future<TagDetailsModel> create(@Body() Map<String, dynamic> body);

  /// Retrieves all tags.
  ///
  /// GET /tags
  /// Query parameters:
  /// - active_only: filter by active status (default: true)
  /// - search: search term for name filtering
  @GET('/tags')
  Future<List<TagDetailsModel>> getAll({
    @Query('active_only') bool? activeOnly,
    @Query('search') String? search,
  });

  /// Retrieves a tag by ID.
  ///
  /// GET /tags/{id}
  @GET('/tags/{id}')
  Future<TagDetailsModel> getById(@Path('id') String id);

  /// Updates an existing tag.
  ///
  /// PUT /tags/{id}
  @PUT('/tags/{id}')
  Future<TagDetailsModel> update(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Soft deletes a tag.
  ///
  /// DELETE /tags/{id}
  @DELETE('/tags/{id}')
  Future<void> delete(@Path('id') String id);

  /// Restores a soft-deleted tag.
  ///
  /// POST /tags/{id}/restore
  @POST('/tags/{id}/restore')
  Future<void> restore(@Path('id') String id);
}
