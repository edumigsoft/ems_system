import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor seguro para logging de requisições HTTP.
///
/// Filtra dados sensíveis como senhas, tokens e headers de autenticação
/// antes de exibir no console. Ajusta verbosidade baseado no modo de build.
class SafeLogInterceptor extends Interceptor {
  /// Campos que devem ser filtrados do corpo das requisições/respostas
  static const _sensitiveFields = {
    'password',
    'senha',
    'token',
    'refresh_token',
    'access_token',
    'secret',
    'api_key',
    'apiKey',
  };

  /// Headers que devem ser filtrados
  static const _sensitiveHeaders = {
    'authorization',
    'cookie',
    'set-cookie',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────');
      debugPrint('│ 🌐 REQUEST');
      debugPrint('├─────────────────────────────────────────────────');
      debugPrint('│ ${options.method} ${options.uri}');

      // Headers filtrados
      final filteredHeaders = _filterSensitiveData(options.headers);
      if (filteredHeaders.isNotEmpty) {
        debugPrint('│ Headers: $filteredHeaders');
      }

      // Body filtrado
      if (options.data != null) {
        final filteredBody = _filterSensitiveData(options.data);
        debugPrint('│ Body: $filteredBody');
      }

      debugPrint('└─────────────────────────────────────────────────');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────');
      debugPrint('│ ✅ RESPONSE');
      debugPrint('├─────────────────────────────────────────────────');
      debugPrint('│ ${response.statusCode} ${response.requestOptions.uri}');

      // Em modo verbose, mostra corpo da resposta (filtrado)
      if (response.data != null) {
        final filteredData = _filterSensitiveData(response.data);
        debugPrint('│ Data: $filteredData');
      }

      debugPrint('└─────────────────────────────────────────────────');
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('┌─────────────────────────────────────────────────');
    debugPrint('│ ❌ ERROR');
    debugPrint('├─────────────────────────────────────────────────');
    debugPrint('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
    debugPrint('│ ${err.type}: ${err.message}');

    if (err.response != null) {
      debugPrint('│ Status: ${err.response?.statusCode}');
      if (err.response?.data != null) {
        final filteredData = _filterSensitiveData(err.response!.data);
        debugPrint('│ Error Data: $filteredData');
      }
    }

    debugPrint('└─────────────────────────────────────────────────');

    super.onError(err, handler);
  }

  /// Filtra dados sensíveis de um objeto (Map, List, ou primitivo)
  dynamic _filterSensitiveData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final filtered = <String, dynamic>{};
      data.forEach((key, value) {
        final keyStr = key.toString().toLowerCase();

        // Verifica se é campo sensível
        if (_sensitiveFields.any((field) => keyStr.contains(field))) {
          filtered[key] = '***FILTERED***';
        } else if (_sensitiveHeaders.any((header) => keyStr.contains(header))) {
          filtered[key] = '***FILTERED***';
        } else {
          // Recursivamente filtra valores aninhados
          filtered[key] = _filterSensitiveData(value);
        }
      });
      return filtered;
    }

    if (data is List) {
      return data.map((item) => _filterSensitiveData(item)).toList();
    }

    // Primitivos retornam como estão
    return data;
  }
}
