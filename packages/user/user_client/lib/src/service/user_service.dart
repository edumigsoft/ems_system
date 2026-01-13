import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:user_shared/user_shared.dart';

part 'user_service.g.dart';

/// Service Retrofit para User.
@RestApi()
abstract class UserService {
  factory UserService(Dio dio, {String baseUrl}) = _UserService;

  /// Obtém o perfil do usuário atual.
  @GET('/user/profile')
  Future<UserDetailsModel> getProfile();

  /// Atualiza o perfil do usuário atual.
  @PATCH('/user/profile')
  Future<UserDetailsModel> updateProfile(@Body() UserUpdate data);

  /// Lista todos os usuários (admin only).
  @GET('/user/admin/users')
  Future<List<UserDetailsModel>> listUsers({
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  /// Obtém um usuário por ID (admin only).
  @GET('/user/admin/users/{id}')
  Future<UserDetailsModel> getUserById(@Path('id') String id);

  /// Atualiza role de um usuário (admin only).
  @PATCH('/user/admin/users/{id}/role')
  Future<UserDetailsModel> updateUserRole(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  /// Desativa um usuário (admin only).
  @DELETE('/user/admin/users/{id}')
  Future<void> deactivateUser(@Path('id') String id);
}
