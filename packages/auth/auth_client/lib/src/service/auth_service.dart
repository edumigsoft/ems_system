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
  Future<Result<UserDetails>> login(LoginRequest request) async {
    try {
      final authResponse = await _api.login(request);

      await _tokenStorage.saveTokens(
        authResponse.tokens,
        expiresIn: authResponse.expiresIn,
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
  Future<Result<void>> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        return Failure(Exception('No refresh token available'));
      }

      final refreshResponse = await _api.refresh({
        'refresh_token': refreshToken,
      });

      await _tokenStorage.saveTokens(
        refreshResponse.tokens,
        expiresIn: refreshResponse.expiresIn,
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
}
