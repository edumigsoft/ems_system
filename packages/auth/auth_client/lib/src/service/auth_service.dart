import 'package:dio/dio.dart';
import 'package:core_shared/core_shared.dart';
import 'package:auth_shared/auth_shared.dart';
import 'package:user_shared/user_shared.dart';

import '../storage/token_storage.dart';
import 'auth_api_service.dart';

/// Serviço de autenticação no cliente.
///
/// Orquestra chamadas via [AuthApiService] com gerenciamento de
/// tokens via [TokenStorage].
class AuthService {
  final AuthApiService _api;
  final TokenStorage _tokenStorage;

  UserDetails? _currentUser;

  AuthService({required AuthApiService api, required TokenStorage tokenStorage})
    : _api = api,
      _tokenStorage = tokenStorage;

  /// Usuário atualmente autenticado.
  UserDetails? get currentUser => _currentUser;

  /// Verifica se está autenticado.
  Future<bool> isAuthenticated() async {
    return _tokenStorage.hasValidToken();
  }

  /// Realiza login com email e senha.
  ///
  /// Se [rememberMe] for true (padrão), o refresh token será armazenado,
  /// permitindo sessões de longa duração. Se false, apenas o access token
  /// será armazenado, expirando a sessão em 15 minutos.
  Future<Result<UserDetails>> login(
    LoginRequest request, {
    bool rememberMe = true,
  }) async {
    try {
      final authResponse = await _api.login(request);

      await _tokenStorage.saveTokens(
        authResponse.tokens,
        expiresIn: authResponse.expiresIn,
        rememberMe: rememberMe,
      );

      _currentUser = authResponse.user;
      return Success(authResponse.user);
    } on DioException catch (e) {
      return Failure(Exception(e.message ?? 'Login failed'));
    } catch (e) {
      return Failure(Exception('Login failed: $e'));
    }
  }

  /// Registra novo usuário.
  Future<Result<void>> register(RegisterRequest request) async {
    try {
      await _api.register(request);
      return successOfUnit();
    } on DioException catch (e) {
      return Failure(Exception(e.message ?? 'Registration failed'));
    } catch (e) {
      return Failure(Exception('Registration failed: $e'));
    }
  }

  /// Renova o access token usando o refresh token.
  ///
  /// Preserva a preferência "lembrar-me" durante a renovação.
  Future<Result<void>> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        return Failure(Exception('No refresh token available'));
      }

      // Preservar preferência rememberMe
      final rememberMe = await _tokenStorage.getRememberMe();

      final refreshResponse = await _api.refresh({
        'refresh_token': refreshToken,
      });

      await _tokenStorage.saveTokens(
        refreshResponse.tokens,
        expiresIn: refreshResponse.expiresIn,
        rememberMe: rememberMe,
      );

      return successOfUnit();
    } on DioException catch (e) {
      await _tokenStorage.clearTokens();
      _currentUser = null;
      return Failure(Exception(e.message ?? 'Token refresh failed'));
    } catch (e) {
      return Failure(Exception('Token refresh failed: $e'));
    }
  }

  /// Realiza logout.
  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _api.logout({'refresh_token': refreshToken});
      }
    } catch (_) {
      // Ignora erros - continua com logout local
    } finally {
      await _tokenStorage.clearTokens();
      _currentUser = null;
    }
  }

  /// Solicita reset de senha.
  Future<Result<void>> requestPasswordReset(String email) async {
    try {
      await _api.forgotPassword(PasswordResetRequest(email: email));
      return successOfUnit();
    } on DioException catch (e) {
      return Failure(Exception(e.message ?? 'Password reset request failed'));
    } catch (e) {
      return Failure(Exception('Password reset request failed: $e'));
    }
  }

  /// Confirma reset de senha com token.
  Future<Result<void>> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _api.resetPassword(
        PasswordResetConfirm(token: token, newPassword: newPassword),
      );
      return successOfUnit();
    } on DioException catch (e) {
      return Failure(Exception(e.message ?? 'Password reset failed'));
    } catch (e) {
      return Failure(Exception('Password reset failed: $e'));
    }
  }

  /// Muda a senha do usuário autenticado.
  ///
  /// Verifica a senha atual e atualiza para a nova senha.
  /// Mantém a sessão atual ativa mas revoga outros tokens.
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Obter refresh token atual para manter a sessão
      final refreshToken = await _tokenStorage.getRefreshToken();

      final requestData = {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
        if (refreshToken != null) 'refresh_token': refreshToken,
      };

      await _api.changePassword(requestData);
      return successOfUnit();
    } on DioException catch (e) {
      // Parse error message
      final errorMessage = e.response?.data?['error'] ?? e.message;
      return Failure(Exception(errorMessage ?? 'Password change failed'));
    } catch (e) {
      return Failure(Exception('Password change failed: $e'));
    }
  }

  /// Verifica se o token expira dentro de uma duração específica.
  ///
  /// Útil para monitorar expiração e avisar o usuário proativamente.
  Future<bool> tokenExpiresWithin(Duration duration) async {
    return _tokenStorage.tokenExpiresWithin(duration);
  }
}
