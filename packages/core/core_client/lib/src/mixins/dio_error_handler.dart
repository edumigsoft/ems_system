import 'package:dio/dio.dart';
import 'package:core_shared/core_shared.dart'
    show Loggable, Failure, Result, DataException;

/// Mixin para tratamento centralizado de erros do Dio
mixin DioErrorHandler on Loggable {
  /// Converte exceções do Dio em [Failure] com [DataException]
  Failure<T> handleDioError<T>(DioException e, {String? context}) {
    String errorMessage;
    final int? statusCode = e.response?.statusCode;

    // Log estruturado
    logger.severe('Error in $context', e, e.stackTrace);

    // Tratamento específico por tipo de erro
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Tempo de conexão esgotado';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Tempo de envio esgotado';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Tempo de resposta esgotado';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Certificado de segurança inválido';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _extractErrorMessage(e.response, statusCode);
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Operação cancelada';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Sem conexão com a internet';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Erro desconhecido na comunicação com o servidor';
        break;
    }

    // Mapeia códigos HTTP para mensagens mais específicas
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          // Se já temos uma mensagem específica do backend, usamos ela
          // Caso contrário, adicionamos o prefixo
          if (!errorMessage.contains(
            RegExp(r'inválid|required|missing', caseSensitive: false),
          )) {
            errorMessage = 'Requisição inválida: $errorMessage';
          }
          break;
        case 401:
          errorMessage = 'Não autorizado. Verifique suas credenciais.';
          break;
        case 403:
          errorMessage =
              'Acesso negado. Você não tem permissão para esta operação.';
          break;
        case 404:
          errorMessage = 'Recurso não encontrado.';
          break;
        case 409:
          errorMessage = 'Conflito: $errorMessage';
          break;
        case 422:
          errorMessage = 'Erro de validação: $errorMessage';
          break;
        case 500:
          errorMessage =
              'Erro interno do servidor. Tente novamente mais tarde.';
          break;
        case 502:
          errorMessage = 'Erro no gateway. Tente novamente mais tarde.';
          break;
        case 503:
          errorMessage = 'Serviço indisponível. Tente novamente mais tarde.';
          break;
        case 504:
          errorMessage =
              'Tempo limite do gateway esgotado. Tente novamente mais tarde.';
          break;
      }
    }

    return Failure(
      DataException(errorMessage, statusCode: e.response?.statusCode),
    );
  }

  String _extractErrorMessage(Response<dynamic>? response, int? statusCode) {
    if (statusCode == 401) return 'Não autorizado. Faça login novamente.';
    if (statusCode == 403) return 'Acesso negado.';
    if (statusCode == 404) return 'Recurso não encontrado.';
    if (statusCode == 500) return 'Erro interno do servidor.';

    // Tenta extrair mensagem do corpo da resposta (ajustar conforme API)
    try {
      final data = response?.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'] as String;
      }
    } catch (_) {}

    return 'Erro na requisição (Status: $statusCode)';
  }

  /// Trata uma exceção genérica e retorna um [Result] com erro.
  Result<T> handleError<T>(
    Object error,
    String context, [
    StackTrace? stackTrace,
  ]) {
    logger.severe('Error in $context', error, stackTrace);

    if (error is DataException) {
      return Failure(error);
    }

    return Failure(
      DataException('Erro inesperado em $context: ${error.toString()}'),
    );
  }
}
