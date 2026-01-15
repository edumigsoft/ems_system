import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:auth_client/auth_client.dart' show TokenStorage;
import 'package:core_shared/core_shared.dart' show Loggable;

class BackendAuthInterceptor extends Interceptor with Loggable {
  final Dio dio;
  final TokenStorage tokenStorage;
  final String backendBaseApi;
  final VoidCallback onUnauthorized; // Callback para quando refresh falha

  BackendAuthInterceptor({
    required this.dio,
    required this.tokenStorage,
    required this.backendBaseApi,
    required this.onUnauthorized,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Adiciona access token no header Authorization
    final accessToken = await tokenStorage.getAccessToken();

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      logger.info('🔑 Token adicionado: ${accessToken.substring(0, 20)}...');
    } else {
      logger.info('⚠️ Nenhum token disponível');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final RequestOptions requestOptions = err.requestOptions;

    if (err.response?.statusCode == 401) {
      // Verifica se é uma tentativa de refresh falha (evita loop)
      if (requestOptions.path.contains('/auth/refresh')) {
        // Refresh falhou, limpa tokens e desloga
        // await authRepository.removeSession();
        onUnauthorized();

        return;
      }

      // Tenta refresh
      // final result = await authRepository.getSession();
      // if (result case Failure()) {
      //   // Refresh falhou, limpa tokens e desloga
      //   await authRepository.removeSession();
      //   onUnauthorized();

      //   return;
      // }

      // final AuthEntity authEntity = (result as Success<AuthEntity>).value;
      // final refreshToken = authEntity.refreshToken;

      // if (refreshToken == null) {
      //   // Não tem refresh token, desloga
      //   await authRepository.removeSession();
      //   onUnauthorized();

      //   return;
      // }

      // try {
      //   final result = await authRepository.refresh(refreshToken);
      //   if (result case Failure()) {
      //     // Refresh falhou, limpa tokens e desloga
      //     await authRepository.removeSession();
      //     onUnauthorized();

      //     return;
      //   }

      //   // Sucesso no refresh, atualiza o token na requisição original
      //   final AuthEntity authEntity = (result as Success<AuthEntity>).value;
      //   requestOptions.headers['Authorization'] = 'Bearer ${authEntity.token}';

      //   // Reenvia a requisição original
      //   final response = await dio.request<dynamic>(
      //     requestOptions.path,
      //     options: Options(
      //       method: requestOptions.method,
      //       headers: requestOptions.headers,
      //       receiveTimeout: const Duration(seconds: 30),
      //       sendTimeout: const Duration(seconds: 30),
      //     ),
      //     data: requestOptions.data,
      //     queryParameters: requestOptions.queryParameters,
      //   );

      //   handler.resolve(response);

      //   return;
      // } catch (e) {
      //   // Refresh falhou
      //   await authRepository.removeSession();
      //   onUnauthorized();

      //   return;
      // }
    }

    handler.reject(err);
  }
}
