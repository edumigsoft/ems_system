import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:user_shared/user_shared.dart';

part 'user_service.g.dart';

/// Service Retrofit para User.
@RestApi()
abstract class UserService {
  factory UserService(Dio dio, {String baseUrl}) = _UserService;

  /// Obtém o perfil do usuário atual.
  @GET('/users/me')
  Future<UserDetailsModel> getProfile();

  /// Atualiza o perfil do usuário atual.
  @PUT('/users/me')
  Future<UserDetailsModel> updateProfile(@Body() UserUpdateModel data);

  /// Lista todos os usuários (admin only).
  /// Retorna resposta paginada com lista de usuários e metadados.
  @GET('/users')
  Future<UsersListResponse> listUsers({
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  /// Obtém um usuário por ID (admin only).
  @GET('/users/{id}')
  Future<UserDetailsModel> getUserById(@Path('id') String id);

  /// Atualiza role de um usuário (admin only).
  /// Nota: O backend atualmente usa PUT /users/{id} para atualizações administrativas.
  @PUT('/users/{id}')
  Future<UserDetailsModel> updateUserRole(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  /// Desativa um usuário (admin only).
  @DELETE('/users/{id}')
  Future<void> deactivateUser(@Path('id') String id);
}
