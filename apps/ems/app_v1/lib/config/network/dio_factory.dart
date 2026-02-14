import 'package:dio/dio.dart';
import '../env/env.dart';

class DioFactory {
  /// Creates and configures the Dio instance.
  ///
  /// [customBaseUrl] pode ser fornecida para substituir a URL padrão do .env
  static Dio create({String? customBaseUrl}) {
    final baseUrl = customBaseUrl ?? '${Env.backendBaseUrl}${Env.backendPathApi}';

    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }
}
