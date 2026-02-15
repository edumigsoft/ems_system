import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../env/env.dart';

class DioFactory {
  /// Creates and configures the Dio instance.
  static Dio create({String? customBaseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: customBaseUrl ?? '${Env.backendBaseUrl}${Env.backendPathApi}',
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
