import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:school_shared/school_shared.dart'
    show SchoolDetailsModel, SchoolCreateModel;

part 'school_service.g.dart';

@RestApi()
abstract class SchoolService {
  factory SchoolService(Dio dio, {String baseUrl}) = _SchoolService;

  @GET('/schools')
  Future<List<SchoolDetailsModel>> getAll(
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  );

  @GET('/schools/{id}')
  Future<SchoolDetailsModel> getById(@Path('id') String id);

  @GET('/schools/by-name/{name}')
  Future<SchoolDetailsModel> getByName(@Path('name') String name);

  @GET('/schools/by-cie/{cie}')
  Future<SchoolDetailsModel> getByCie(@Path('cie') String cie);

  @POST('/schools')
  Future<SchoolDetailsModel> create(@Body() SchoolCreateModel school);

  @PUT('/schools/{id}')
  Future<SchoolDetailsModel> update(
    @Path('id') String id,
    @Body() SchoolDetailsModel school,
  );

  @DELETE('/schools/{id}')
  Future<void> delete(@Path('id') String id);
}
