import 'package:core_shared/core_shared.dart';

/// Mapeia exceções de domínio em mensagens amigáveis para API REST.
///
/// Implementa o padrão definido em ADR-0007 para consistência de
/// mensagens de erro em toda a API.
///
/// **Uso:**
/// ```dart
/// try {
///   // ... operação
/// } catch (e) {
///   final errorResponse = ErrorMessageMapper.fromException(e as Exception);
///   return Response(
///     errorResponse.statusCode,
///     body: json.encode(errorResponse.toJson()),
///   );
/// }
/// ```
class ErrorMessageMapper {
  /// Converte uma exceção em [ErrorResponse] com mensagem user-friendly.
  static ErrorResponse fromException(Exception error) {
    // ValidationException - erros de validação de dados
    if (error is ValidationException) {
      return ErrorResponse(
        error: 'Dados inválidos',
        message: 'Verifique os campos e tente novamente',
        statusCode: 400,
        details: error.errors, // Mapa de campo -> lista de erros
      );
    }

    // UnauthorizedException - autenticação/autorização
    if (error is UnauthorizedException) {
      return ErrorResponse(
        error: 'Não autorizado',
        message: 'Faça login novamente',
        statusCode: 401,
      );
    }

    // StorageException - erros de banco de dados/armazenamento
    // IMPORTANTE: Verificar ANTES de DataException (StorageException extends DataException)
    if (error is StorageException) {
      return ErrorResponse(
        error: 'Erro no servidor',
        message: 'Erro ao acessar dados. Tente novamente mais tarde.',
        statusCode: 500,
      );
    }

    // DataException - erros de processamento de dados
    if (error is DataException) {
      // DataException já tem mensagens user-friendly no domínio
      final statusCode = error.statusCode ?? 500;
      return ErrorResponse(
        error: statusCode >= 500
            ? 'Erro no servidor'
            : 'Erro ao processar requisição',
        message: error.message,
        statusCode: statusCode,
      );
    }

    // Exception genérico - erro não mapeado
    return ErrorResponse(
      error: 'Erro interno',
      message: 'Ocorreu um erro inesperado. Tente novamente mais tarde.',
      statusCode: 500,
    );
  }
}

/// Resposta estruturada de erro para API REST.
///
/// Segue o padrão definido em ADR-0007.
class ErrorResponse {
  /// Título curto do erro (ex: "Dados inválidos")
  final String error;

  /// Mensagem descritiva para o usuário
  final String message;

  /// Código HTTP correspondente
  final int statusCode;

  /// Informações adicionais estruturadas (opcional)
  ///
  /// Útil para ValidationException com erros por campo:
  /// ```json
  /// {
  ///   "name": ["Nome é obrigatório"],
  ///   "email": ["Email inválido"]
  /// }
  /// ```
  final Map<String, dynamic>? details;

  const ErrorResponse({
    required this.error,
    required this.message,
    required this.statusCode,
    this.details,
  });

  /// Converte para JSON para resposta HTTP
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'error': error,
      'message': message,
      'statusCode': statusCode,
    };

    if (details != null && details!.isNotEmpty) {
      json['details'] = details;
    }

    return json;
  }

  @override
  String toString() => 'ErrorResponse($error: $message, status: $statusCode)';
}
