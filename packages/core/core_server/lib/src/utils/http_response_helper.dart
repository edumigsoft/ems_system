import 'dart:convert';

import 'package:core_shared/core_shared.dart' show Result, Success, Failure;
import 'package:shelf/shelf.dart';

import 'error_message_mapper.dart';

/// Helper para converter [Result] em respostas HTTP do Shelf.
///
/// Este helper padroniza o tratamento de resultados em rotas do servidor,
/// eliminando código repetitivo.
class HttpResponseHelper {
  /// Converte um [Result] em uma [Response] HTTP apropriada.
  ///
  /// [result] - O resultado da operação
  /// [successCode] - Código HTTP a ser retornado em caso de sucesso (padrão: 200)
  /// [onSuccess] - Função opcional para transformar o valor de sucesso
  ///
  /// Retorna uma [Response] com status code apropriado e corpo JSON.
  static Response toResponse<T>(
    Result<T> result, {
    int successCode = 200,
    dynamic Function(T)? onSuccess,
  }) {
    return switch (result) {
      Success(value: final data) => Response(
        successCode,
        body: json.encode(onSuccess != null ? onSuccess(data) : _toJson(data)),
        headers: {'content-type': 'application/json'},
      ),
      Failure(error: final e) => _errorResponse(e),
    };
  }

  /// Cria uma resposta de erro usando ErrorMessageMapper.
  static Response _errorResponse(Exception error) {
    final errorResponse = ErrorMessageMapper.fromException(error);
    return Response(
      errorResponse.statusCode,
      body: json.encode(errorResponse.toJson()),
      headers: {'content-type': 'application/json'},
    );
  }

  /// Converte um objeto para JSON.
  static Map<String, dynamic> _toJson(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is Iterable) {
      return {'data': data.map(_toJson).toList()};
    }
    // Tenta usar método toJson se disponível
    try {
      final result = (data as dynamic).toJson();
      return result is Map<String, dynamic>
          ? result
          : Map<String, dynamic>.from(result as Map);
    } catch (_) {
      return {'data': data.toString()};
    }
  }

  /// Cria uma resposta de sucesso com lista.
  static Response successList<T>(List<T> items, {int code = 200}) {
    return Response(
      code,
      body: json.encode({'data': items.map(_toJson).toList()}),
      headers: {'content-type': 'application/json'},
    );
  }

  /// Helper para respostas de erro.
  ///
  /// Se [error] for uma [Exception], usa [ErrorMessageMapper] para mensagens amigáveis.
  /// Caso contrário, usa a mensagem fornecida.
  static Response error(dynamic error, {int code = 400, String? message}) {
    // Se for Exception, usar ErrorMessageMapper
    if (error is Exception) {
      final errorResponse = ErrorMessageMapper.fromException(error);
      return Response(
        errorResponse.statusCode,
        body: json.encode(errorResponse.toJson()),
        headers: {'content-type': 'application/json'},
      );
    }

    // Fallback para erros não-Exception
    return Response(
      code,
      body: json.encode({
        'error': message ?? error.toString(),
        if (message != null && error.toString() != message)
          'details': error.toString(),
      }),
      headers: {'content-type': 'application/json'},
    );
  }
}
