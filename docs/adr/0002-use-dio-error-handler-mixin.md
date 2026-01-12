# 2. Uso do DioErrorHandler Mixin

Date: 2025-12-07

## Status

Aceito

## Contexto

Requisições HTTP usando o pacote `dio` geram exceções (`DioException`) que precisam ser traduzidas para erros de domínio ou mensagens amigáveis. Repetir esse tratamento em cada repositório gera duplicação de código.

## Decisão

Criar e utilizar um mixin `DioErrorHandler` no pacote `@core` que centraliza a lógica de tratamento de erros do Dio.

Este mixin fornece o método `handleDioError` que:
- Analisa o status code HTTP.
- Extrai mensagens de erro do corpo da resposta.
- Retorna um `Failure` com uma `DataException` contendo a mensagem processada.
- Realiza log estruturado do erro.

> [!NOTE]
> **Integração com Result Pattern**
>
> O `DioErrorHandler` é projetado para trabalhar em conjunto com o padrão `Result<T>` (ADR-0001).
> Todos os métodos de repositório retornam `Result<T>`, e o `handleDioError` facilita a criação de `Failure` com exceções apropriadas.

> [!TIP]
> **Uso com BaseRepository**
>
> O mixin `DioErrorHandler` é tipicamente usado em conjunto com `BaseRepositoryLocal` (ADR-0003).
> O `BaseRepositoryLocal` já incorpora o `DioErrorHandler` e fornece métodos helpers como `executeRequest` que automaticamente tratam erros do Dio.

## Consequências

- Tratamento de erro consistente em todo o aplicativo.
- Eliminação de duplicação nos repositórios.
- Facilidade de manutenção: alterar a lógica de erro em um lugar afeta todos os repositórios.
- Integração perfeita com o padrão `Result<T>` para tratamento explícito de erros.

---

## Exemplo de Implementação

> [!NOTE]
> **Exemplo de Referência**
>
> Este é um exemplo de como o `DioErrorHandler` será implementado no `core_client`.
> A implementação real ainda será criada seguindo esta especificação.

```dart
// packages/core/core_client/lib/src/mixins/dio_error_handler.dart

import 'package:dio/dio.dart';
import '../result/result.dart';
import '../exceptions/data_exception.dart';

/// Mixin que fornece tratamento centralizado de erros do Dio.
///
/// Uso:
/// ```dart
/// class MyRepository with DioErrorHandler {
///   Future<Result<User>> getUser(String id) async {
///     try {
///       final response = await _dio.get('/users/$id');
///       return Success(User.fromJson(response.data));
///     } on DioException catch (e) {
///       return handleDioError(e);
///     }
///   }
/// }
/// ```
mixin DioErrorHandler {
  /// Trata uma [DioException] e retorna um [Failure] apropriado.
  ///
  /// Analisa o tipo de erro, status code HTTP e corpo da resposta
  /// para criar uma mensagem de erro amigável ao usuário.
  ///
  /// [error]: A exceção do Dio a ser tratada
  /// [context]: Contexto adicional para logging (opcional)
  ///
  /// Retorna sempre um [Failure] contendo uma [DataException].
  Failure<T> handleDioError<T>(
    DioException error, {
    String? context,
  }) {
    final String errorMessage;
    final int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Tempo de conexão esgotado. Verifique sua internet.';
        
      case DioExceptionType.connectionError:
        errorMessage = 'Erro de conexão. Verifique sua internet.';
        
      case DioExceptionType.badResponse:
        errorMessage = _extractErrorMessage(error.response, statusCode);
        
      case DioExceptionType.cancel:
        errorMessage = 'Requisição cancelada.';
        
      case DioExceptionType.unknown:
        errorMessage = 'Erro desconhecido ao processar a requisição.';
        
      default:
        errorMessage = 'Erro ao processar requisição.';
    }

    // Log estruturado (em produção, usar logger real)
    _logError(error, errorMessage, context);

    return Failure(
      DataException(
        message: errorMessage,
        statusCode: statusCode,
        originalError: error,
      ),
    );
  }

  /// Extrai mensagem de erro do corpo da resposta HTTP.
  String _extractErrorMessage(Response? response, int? statusCode) {
    if (response?.data != null) {
      // Tenta extrair mensagem do corpo JSON
      try {
        final data = response!.data;
        if (data is Map<String, dynamic>) {
          // Padrões comuns de APIs REST
          final message = data['message'] ?? 
                         data['error'] ?? 
                         data['detail'];
          if (message != null) {
            return message.toString();
          }
        }
      } catch (_) {
        // Se falhar ao extrair, usa mensagem padrão baseada no status
      }
    }

    // Mensagens padrão baseadas no status code HTTP
    return switch (statusCode) {
      400 => 'Requisição inválida. Verifique os dados enviados.',
      401 => 'Não autorizado. Faça login novamente.',
      403 => 'Acesso negado.',
      404 => 'Recurso não encontrado.',
      409 => 'Conflito. O recurso já existe.',
      422 => 'Dados inválidos. Verifique os campos.',
      500 => 'Erro interno do servidor. Tente novamente mais tarde.',
      503 => 'Serviço temporariamente indisponível.',
      _ => 'Erro no servidor (código: $statusCode).',
    };
  }

  /// Registra o erro para debugging/monitoramento.
  void _logError(DioException error, String message, String? context) {
    // Em produção, usar logger adequado (e.g., Firebase Crashlytics, Sentry)
    print('═══════════════════════════════════════════════════════');
    print('❌ DIO ERROR ${context != null ? "[$context]" : ""}');
    print('Message: $message');
    print('Type: ${error.type}');
    print('Status: ${error.response?.statusCode}');
    print('URL: ${error.requestOptions.uri}');
    print('Method: ${error.requestOptions.method}');
    if (error.response?.data != null) {
      print('Response: ${error.response?.data}');
    }
    print('═══════════════════════════════════════════════════════');
  }
}
```

### Exceção de Domínio

```dart
// packages/core/core_shared/lib/src/exceptions/data_exception.dart

import 'package:dio/dio.dart';

/// Exceção que representa erros de acesso a dados (API, BD, etc).
///
/// Encapsula informações sobre falhas de requisições HTTP,
/// incluindo status code, mensagem amigável e erro original.
class DataException implements Exception {
  /// Mensagem de erro amigável ao usuário.
  final String message;

  /// Código de status HTTP (se aplicável).
  final int? statusCode;

  /// Erro original do Dio (para debugging).
  final DioException? originalError;

  const DataException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(message, statusCode);
}
```

---

## Exemplos de Uso

### Uso Direto em Repository

```dart
// packages/finance/finance_client/lib/src/repositories/finance_repository_local.dart

import 'package:dio/dio.dart';
import 'package:core_client/core_client.dart'; // Importa DioErrorHandler
import 'package:core_shared/core_shared.dart'; // Importa Exceptions/Result
import 'package:finance_core/finance_core.dart';

class FinanceRepositoryLocal 
    with DioErrorHandler 
    implements FinanceRepository {
  
  final Dio _dio;

  FinanceRepositoryLocal(this._dio);

  @override
  Future<Result<FinanceDetails>> create(FinanceCreate data) async {
    try {
      final model = FinanceCreateModel.fromDomain(data);
      final response = await _dio.post(
        '/finances',
        data: model.toJson(),
      );

      final created = FinanceDetailsModel.fromJson(response.data).toDomain();
      return Success(created);
    } on DioException catch (e) {
      return handleDioError(e, context: 'FinanceRepository.create');
    }
  }

  @override
  Future<Result<List<FinanceDetails>>> getAll() async {
    try {
      final response = await _dio.get('/finances');
      
      final finances = (response.data as List)
          .map((json) => FinanceDetailsModel.fromJson(json).toDomain())
          .toList();
          
      return Success(finances);
    } on DioException catch (e) {
      return handleDioError(e, context: 'FinanceRepository.getAll');
    }
  }

  @override
  Future<Result<FinanceDetails>> update(FinanceUpdate data) async {
    try {
      final model = FinanceUpdateModel.fromDomain(data);
      final response = await _dio.put(
        '/finances/${data.id}',
        data: model.toJson(),
      );

      final updated = FinanceDetailsModel.fromJson(response.data).toDomain();
      return Success(updated);
    } on DioException catch (e) {
      return handleDioError(e, context: 'FinanceRepository.update');
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dio.delete('/finances/$id');
      return const Success(null);
    } on DioException catch (e) {
      return handleDioError(e, context: 'FinanceRepository.delete');
    }
  }
}
```

### Uso com BaseRepository (Recomendado)

> [!TIP]
> **Abordagem Recomendada**
>
> Para eliminar ainda mais boilerplate, use `BaseRepositoryLocal` que já incorpora o `DioErrorHandler`:

```dart
// packages/finance/finance_client/lib/src/repositories/finance_repository_local.dart

import 'package:dio/dio.dart';
import 'package:core_client/core_client.dart'; // Importa DioErrorHandler
import 'package:core_shared/core_shared.dart'; // Importa Exceptions/Result
import 'package:finance_core/finance_core.dart';

class FinanceRepositoryLocal 
    extends BaseRepositoryLocal<FinanceDetails, FinanceCreate>
    implements FinanceRepository {
  
  FinanceRepositoryLocal(super.dio);

  @override
  Future<Result<FinanceDetails>> create(FinanceCreate data) async {
    return executeRequest(
      request: () => dio.post('/finances', data: FinanceCreateModel.fromDomain(data).toJson()),
      parser: (json) => FinanceDetailsModel.fromJson(json).toDomain(),
      context: 'create',
    );
  }

  @override
  Future<Result<List<FinanceDetails>>> getAll() async {
    return executeListRequest(
      request: () => dio.get('/finances'),
      parser: (json) => FinanceDetailsModel.fromJson(json).toDomain(),
      context: 'getAll',
    );
  }

  @override
  Future<Result<FinanceDetails>> update(FinanceUpdate data) async {
    return executeRequest(
      request: () => dio.put('/finances/${data.id}', data: FinanceUpdateModel.fromDomain(data).toJson()),
      parser: (json) => FinanceDetailsModel.fromJson(json).toDomain(),
      context: 'update',
    );
  }

  @override
  Future<Result<void>> delete(String id) async {
    return executeVoidRequest(
      request: () => dio.delete('/finances/$id'),
      context: 'delete',
    );
  }
}
```

### Consumo em ViewModel

```dart
// packages/finance/finance_ui/lib/ui/view_models/finance_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:core_client/core_client.dart';
import 'package:finance_core/finance_core.dart';

class FinanceViewModel extends ChangeNotifier {
  final CreateFinanceUseCase _createUseCase;
  final GetAllFinancesUseCase _getAllUseCase;

  List<FinanceDetails> _finances = [];
  String? _errorMessage;
  bool _isLoading = false;

  List<FinanceDetails> get finances => _finances;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  FinanceViewModel(this._createUseCase, this._getAllUseCase);

  Future<void> loadFinances() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getAllUseCase();

    // Tratamento do Result com pattern matching
    switch (result) {
      case Success<List<FinanceDetails>>(:final value):
        _finances = value;
        _errorMessage = null;
        
      case Failure<List<FinanceDetails>>(:final error):
        _errorMessage = error.toString(); // DataException.message
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createFinance(FinanceCreate data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _createUseCase(data);

    result.when(
      success: (finance) {
        _finances.add(finance);
        _errorMessage = null;
      },
      failure: (error) {
        _errorMessage = error.toString(); // Mensagem amigável
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
```

---

## Referências

- [ADR-0001: Padrão Result para Tratamento de Erros](./0001-use-result-pattern-for-error-handling.md)
- [ADR-0003: BaseRepository Pattern](./0003-use-base-repository-pattern.md)
- [Padrões Arquiteturais](../architecture/architecture_patterns.md)
- [Flutter & Dart Rules - Tratamento de Erros](../rules/flutter_dart_rules.md#tratamento-de-erros)
