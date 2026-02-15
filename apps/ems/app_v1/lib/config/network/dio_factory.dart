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

    // ⚠️ APENAS EM DEBUG: Aceita certificados SSL autoassinados
    // Necessário para desenvolvimento local com HTTPS (ems.local)
    if (kDebugMode && baseUrl.startsWith('https://')) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          // Aceita apenas certificados do servidor local
          if (host == 'ems.local' || host.contains('localhost')) {
            if (kDebugMode) {
              debugPrint('⚠️  Accepting self-signed certificate for $host');
            }
            return true;
          }
          return false;
        };
        return client;
      };
    }

    return dio;
  }
}
