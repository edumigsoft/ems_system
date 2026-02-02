import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:notebook_shared/notebook_shared.dart';

part 'document_reference_api_service.g.dart';

/// Retrofit API service for document reference operations.
///
/// Provides type-safe HTTP methods for document reference CRUD operations.
@RestApi()
abstract class DocumentReferenceApiService {
  /// Creates a DocumentReferenceApiService instance.
  factory DocumentReferenceApiService(Dio dio, {String baseUrl}) =
      _DocumentReferenceApiService;

  /// Creates a new document reference.
  ///
  /// POST /documents
  @POST('/documents')
  Future<DocumentReferenceDetailsModel> create(
    @Body() Map<String, dynamic> body,
  );

  /// Retrieves a document reference by ID.
  ///
  /// GET /documents/{id}
  @GET('/documents/{id}')
  Future<DocumentReferenceDetailsModel> getById(@Path('id') String id);

  /// Updates an existing document reference.
  ///
  /// PUT /documents/{id}
  @PUT('/documents/{id}')
  Future<DocumentReferenceDetailsModel> update(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// Deletes a document reference permanently.
  ///
  /// DELETE /documents/{id}
  @DELETE('/documents/{id}')
  Future<void> delete(@Path('id') String id);
}
