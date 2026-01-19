import 'package:dio/dio.dart';
import '../env/env.dart';

class DioFactory {
  /// Creates and configures the Dio instance.
  static Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: '${Env.backendBaseUrl}${Env.backendPathApi}',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }
}
