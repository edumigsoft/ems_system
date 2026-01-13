import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:auth_shared/auth_shared.dart';

part 'auth_api_service.g.dart';

/// Service Retrofit para endpoints de autenticação.
@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  /// POST /auth/login - Autenticação com email e senha.
  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  /// POST /auth/register - Registro de novo usuário.
  @POST('/auth/register')
  Future<void> register(@Body() RegisterRequest request);

  /// POST /auth/refresh - Renovação de access token.
  @POST('/auth/refresh')
  Future<RefreshResponse> refresh(@Body() Map<String, dynamic> data);

  /// POST /auth/logout - Invalidação de refresh token.
  @POST('/auth/logout')
  Future<void> logout(@Body() Map<String, dynamic> data);

  /// POST /auth/forgot-password - Solicitação de reset de senha.
  @POST('/auth/forgot-password')
  Future<void> forgotPassword(@Body() PasswordResetRequest request);

  /// POST /auth/reset-password - Reset de senha com token.
  @POST('/auth/reset-password')
  Future<void> resetPassword(@Body() PasswordResetConfirm request);
}
