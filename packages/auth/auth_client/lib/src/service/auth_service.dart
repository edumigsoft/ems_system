import 'package:auth_shared/auth_shared.dart'
    show
        LoginRequest,
        RegisterRequest,
        PasswordResetRequest,
        PasswordResetConfirm;
import 'package:dio/dio.dart';
import 'package:core_shared/core_shared.dart'
    show Result, Failure, Success, successOfUnit, Loggable;
import 'package:core_client/core_client.dart' show DioErrorHandler;
import 'package:user_shared/user_shared.dart' show UserDetails;

import '../storage/token_storage.dart';
import 'auth_api_service.dart';
import 'token_refresh_service.dart';

/// Serviço de autenticação no cliente.
///
/// Orquestra chamadas via [AuthApiService] com gerenciamento de
/// tokens via [TokenStorage] e refresh proativo via [TokenRefreshService].
class AuthService with Loggable, DioErrorHandler {
  final AuthApiService _api;
  final TokenStorage _tokenStorage;
  final TokenRefreshService _refreshService;

  UserDetails? _currentUser;

  AuthService({
    required AuthApiService api,
    required TokenStorage tokenStorage,
    required TokenRefreshService refreshService,
  }) : _api = api,
       _tokenStorage = tokenStorage,
       _refreshService = refreshService;

  /// Usuário atualmente autenticado.
  UserDetails? get currentUser => _currentUser;

  /// Verifica se está autenticado.
  ///
  /// Tenta renovar o token automaticamente se estiver expirado mas
  /// houver um refresh token válido disponível.
  Future<bool> isAuthenticated() async {
    bool isAuth = await _tokenStorage.hasValidToken();

    if (!isAuth) {
      // Tentar refresh se token expirado mas refresh disponível
      isAuth = await _refreshService.refreshOnStartup();
    }

    if (isAuth && _currentUser == null) {
      _currentUser = await _tokenStorage.getUser();
      if (_currentUser == null) {
        // Estado inconsistente: token válido mas sem dados de usuário
        await _tokenStorage.clearTokens();
        return false;
      }
    }

    return isAuth;
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

      await _tokenStorage.saveUser(authResponse.user);

      _currentUser = authResponse.user;
      _refreshService.startMonitoring();
      return Success(authResponse.user);
    } on DioException catch (e) {
      return handleDioError(e, context: 'AuthService.login');
    } catch (e) {
      return handleError(e, 'AuthService.login');
    }
  }

  /// Registra novo usuário.
  Future<Result<void>> register(RegisterRequest request) async {
    try {
      await _api.register(request);
      return successOfUnit();
    } on DioException catch (e) {
      return handleDioError(e, context: 'AuthService.register');
    } catch (e) {
      return handleError(e, 'AuthService.register');
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
      return handleDioError(e, context: 'AuthService.refreshToken');
    } catch (e) {
      return handleError(e, 'AuthService.refreshToken');
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
      _refreshService.stopMonitoring();
      _currentUser = null;
    }
  }

  /// Solicita reset de senha.
  Future<Result<void>> requestPasswordReset(String email) async {
    try {
      await _api.forgotPassword(PasswordResetRequest(email: email));
      return successOfUnit();
    } on DioException catch (e) {
      return handleDioError(e, context: 'AuthService.requestPasswordReset');
    } catch (e) {
      return handleError(e, 'AuthService.requestPasswordReset');
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
      return handleDioError(e, context: 'AuthService.confirmPasswordReset');
    } catch (e) {
      return handleError(e, 'AuthService.confirmPasswordReset');
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
        ...?refreshToken != null ? {'refresh_token': refreshToken} : null,
      };

      await _api.changePassword(requestData);
      return successOfUnit();
    } on DioException catch (e) {
      return handleDioError(e, context: 'AuthService.changePassword');
    } catch (e) {
      return handleError(e, 'AuthService.changePassword');
    }
  }

  /// Verifica se o token expira dentro de uma duração específica.
  ///
  /// Útil para monitorar expiração e avisar o usuário proativamente.
  Future<bool> tokenExpiresWithin(Duration duration) async {
    return _tokenStorage.tokenExpiresWithin(duration);
  }
}
