import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:book_shared/book_shared.dart';

part 'book_service.g.dart';

/// Service Retrofit para Book.
@RestApi()
abstract class BookService {
  factory BookService(Dio dio, {String baseUrl}) = _BookService;

  @GET('/books')
  Future<List<BookDetailsModel>> getAll({
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  @GET('/books/{id}')
  Future<BookDetailsModel> getById(@Path('id') String id);

  @POST('/books')
  Future<BookDetailsModel> create(
    @Body() BookCreateModel data,
  );

  @PUT('/books/{id}')
  Future<BookDetailsModel> update(
    @Path('id') String id,
    @Body() BookUpdateModel data,
  );

  @DELETE('/books/{id}')
  Future<void> delete(@Path('id') String id);
}
