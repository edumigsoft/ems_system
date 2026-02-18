import 'package:dio/dio.dart';

/// Interceptor Dio que injeta a API Key no header `x-api-key` de todo request.
class ApiKeyInterceptor extends Interceptor {
  final String apiKey;
  static const _headerName = 'x-api-key';

  const ApiKeyInterceptor({required this.apiKey});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[_headerName] = apiKey;
    super.onRequest(options, handler);
  }
}
