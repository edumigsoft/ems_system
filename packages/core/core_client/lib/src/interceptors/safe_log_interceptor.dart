import 'dart:developer' as dev;

import 'package:dio/dio.dart';

/// Interceptor seguro para logging de requisições HTTP.
///
/// Filtra dados sensíveis como senhas, tokens e headers de autenticação
/// antes de exibir no console. Requisições e respostas são logadas apenas
/// em modo debug. Erros são sempre logados.
class SafeLogInterceptor extends Interceptor {
  // true em produção (AOT compilado com dart.vm.product=true)
  static const _isRelease = bool.fromEnvironment('dart.vm.product');

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
    'x-api-key',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_isRelease) {
      final filteredHeaders =
          _filterSensitiveData(options.headers) as Map<String, dynamic>;

      dev.log('┌─────────────────────────────────────────────────');
      dev.log('│ 🌐 REQUEST');
      dev.log('├─────────────────────────────────────────────────');
      dev.log('│ ${options.method} ${options.uri}');

      if (filteredHeaders.isNotEmpty) {
        dev.log('│ Headers: $filteredHeaders');
      }

      if (options.data != null) {
        final filteredBody = _filterSensitiveData(options.data);
        dev.log('│ Body: $filteredBody');
      }

      dev.log('└─────────────────────────────────────────────────');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!_isRelease) {
      dev.log('┌─────────────────────────────────────────────────');
      dev.log('│ ✅ RESPONSE');
      dev.log('├─────────────────────────────────────────────────');
      dev.log('│ ${response.statusCode} ${response.requestOptions.uri}');

      if (response.data != null) {
        final filteredData = _filterSensitiveData(response.data);
        dev.log('│ Data: $filteredData');
      }

      dev.log('└─────────────────────────────────────────────────');
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    dev.log('┌─────────────────────────────────────────────────');
    dev.log('│ ❌ ERROR');
    dev.log('├─────────────────────────────────────────────────');
    dev.log('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
    dev.log('│ Type: ${err.type}');
    dev.log('│ Message: ${err.message}');

    if (err.response != null) {
      dev.log('│ Status Code: ${err.response?.statusCode}');
      if (err.response?.data != null) {
        final filteredData = _filterSensitiveData(err.response!.data);
        dev.log('│ Response Data: $filteredData');
      }
    } else {
      dev.log('│ No response received (connection error, timeout, etc.)');
    }

    dev.log('└─────────────────────────────────────────────────');

    super.onError(err, handler);
  }

  /// Filtra dados sensíveis de um objeto (Map, List, ou primitivo)
  dynamic _filterSensitiveData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final filtered = <String, dynamic>{};
      data.forEach((key, value) {
        final keyStr = key.toString().toLowerCase();

        if (_sensitiveFields.any(keyStr.contains)) {
          filtered[key.toString()] = '***FILTERED***';
        } else if (_sensitiveHeaders.any(keyStr.contains)) {
          filtered[key.toString()] = '***FILTERED***';
        } else {
          filtered[key.toString()] = _filterSensitiveData(value);
        }
      });
      return filtered;
    }

    if (data is List) {
      return data.map(_filterSensitiveData).toList();
    }

    return data;
  }
}
