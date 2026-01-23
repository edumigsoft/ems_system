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
  ///
  /// Parâmetros:
  /// - [page]: Número da página (padrão: 1)
  /// - [limit]: Itens por página (padrão: 50, máximo: 100)
  /// - [role]: Filtro por role (user, admin, owner)
  /// - [search]: Busca por nome, email ou username
  @GET('/users')
  Future<UsersListResponse> listUsers({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('role') String? role,
    @Query('search') String? search,
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

  /// Cria um usuário administrativamente (owner only).
  /// O usuário receberá email para definir senha no primeiro acesso.
  @POST('/users')
  Future<UserDetailsModel> createUser(@Body() UserCreateAdminModel data);

  /// Força mudança de senha no próximo login (admin+).
  /// Admin não pode forçar em owners ou outros admins.
  @POST('/users/{id}/force-password-change')
  Future<void> forcePasswordChange(@Path('id') String id);

  /// Inicia reset de senha (envia email com token) (admin+).
  /// Admin não pode resetar senha de owners.
  @POST('/users/{id}/reset-password')
  Future<void> resetPassword(@Path('id') String id);
}
