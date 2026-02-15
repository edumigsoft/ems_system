import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../env/env.dart';

class DioFactory {
  /// Creates and configures the Dio instance.
  ///
  /// [customBaseUrl] pode ser fornecida para substituir a URL padrão do .env
  static Dio create({String? customBaseUrl}) {
    final baseUrl = customBaseUrl ?? '${Env.backendBaseUrl}${Env.backendPathApi}';

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // ⚠️ APENAS EM DEBUG: Aceita certificados SSL auto-assinados
    if (kDebugMode) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    return dio;
  }
}
