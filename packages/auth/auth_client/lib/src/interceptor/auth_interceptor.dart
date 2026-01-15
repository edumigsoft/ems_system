import 'dart:async';

import 'package:dio/dio.dart';
import 'package:auth_shared/auth_shared.dart';
import '../storage/token_storage.dart';

/// Interceptor para adicionar token e realizar refresh automático.
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio; // Dio instance para retry
  final String _refreshUrl; // URL para evitar loop no refresh
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio dio,
    String refreshUrl = '/auth/refresh',
  }) : _tokenStorage = tokenStorage,
       _dio = dio,
       _refreshUrl = refreshUrl;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Pular adição de token para login/refresh/register/public e se já tiver header
    if (options.path.contains('login') ||
        options.path.contains('register') ||
        options.path.contains('refresh') ||
        options.path.contains('forgot-password') ||
        options.path.contains('reset-password')) {
      return handler.next(options);
    }

    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains(_refreshUrl)) {
      // Se já estiver refreshando, esperar
      if (_isRefreshing) {
        if (_refreshCompleter != null) {
          await _refreshCompleter!.future;
          // Tentar novamente com novo token
          return _retry(err.requestOptions, handler);
        }
      }

      _isRefreshing = true;
      _refreshCompleter = Completer<void>();

      try {
        final refreshed = await _performRefresh();
        if (refreshed) {
          _refreshCompleter?.complete();
          _isRefreshing = false;
          return _retry(err.requestOptions, handler);
        }
      } catch (e) {
        _isRefreshing = false;
        _refreshCompleter?.completeError(e);
        // Logout se falhar
        await _tokenStorage.clearTokens();
      }
    }

    return handler.next(err);
  }

  Future<void> _retry(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    try {
      final response = await _dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options,
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      // Usar uma nova instância de Dio ou pular interceptor para evitar loop
      // mas como verificamos o path no onRequest, ok usar a mesma desde que requestOptions não tenha o token antigo?
      // Refresh geralmente não precisa de Auth Header access token, manda refresh token no body

      // Criar AuthApiService temporário ou chamar endpoint manual
      // Vamos chamar manualmente para não depender de AuthApiService aqui dentro (circular)
      // Ou injetar uma função de refresh.

      // Para simplificar, chamar via dio direto:
      final response = await _dio.post<Map<String, dynamic>>(
        _refreshUrl,
        data: {'refresh_token': refreshToken},
      ); // O onRequest vai ignorar _refreshUrl

      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        // AuthResponse ou RefreshResponse
        // Endpoint server retorna AuthResponse com access e refresh
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];
        final expiresIn = data['expiresIn'];

        if (newAccessToken is String && newRefreshToken is String) {
          await _tokenStorage.saveTokens(
            TokenPair(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            ),
            expiresIn: expiresIn is int ? expiresIn : 3600, // fallback
          );
          return true;
        }
      }
    } catch (e) {
      // Refresh falhou
    }
    return false;
  }
}
