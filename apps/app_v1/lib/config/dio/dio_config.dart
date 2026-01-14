import 'dart:ui';

// import 'package:core_shared/core_shared.dart' show Success, Failure;
import 'package:dio/dio.dart';

class BackendAuthInterceptor extends Interceptor {
  final Dio dio;
  // final AuthRepository authRepository;
  final String backendBaseApi;
  final VoidCallback onUnauthorized; // Callback para quando refresh falha

  BackendAuthInterceptor({
    required this.dio,
    // required this.authRepository,
    required this.backendBaseApi,
    required this.onUnauthorized,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // final result = await authRepository.getSession();
    // if (result case Success(value: final authEntity)) {
    //   final token = authEntity.refreshToken;

    //   if (token != null) {
    //     options.headers['Authorization'] = 'Bearer $token';
    // }
    // }

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
