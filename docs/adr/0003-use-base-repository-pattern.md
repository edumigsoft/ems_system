# 3. Uso do BaseRepository Pattern

Date: 2025-12-07

## Status

Aceito

## Contexto

Repositórios locais (clientes HTTP) tendem a ter muito código boilerplate: chamar serviço, try-catch, mapear resposta, tratar erro Dio. Isso viola o princípio DRY.

## Decisão

Implementar uma classe abstrata `BaseRepositoryLocal<TEntity, TCreate>` no pacote `@core` que encapsula a lógica comum de chamadas HTTP seguras.

Os repositórios devem estender essa classe e usar métodos como `executeRequest`, `executeListRequest` e `executeVoidRequest`.

> [!NOTE]
> **Integração com Padrões Existentes**
>
> O `BaseRepositoryLocal` combina dois padrões essenciais:
> - **Result Pattern** (ADR-0001): Todos os métodos retornam `Result<T>` para tratamento explícito de erros
> - **DioErrorHandler** (ADR-0002): Incorpora o mixin para tratamento centralizado de exceções do Dio

> [!IMPORTANT]
> **EntityDetails nos Repositórios**
>
> Os repositórios **SEMPRE** devem trabalhar com `EntityDetails` (não `Entity` pura) porque:
> - Repositórios lidam com persistência (id, createdAt, updatedAt, isDeleted, isActive)
> - `EntityDetails` implementa `BaseDetails` com todos os campos de auditoria do `DriftTableMixinPostgres`
> - `Entity` pura é apenas para lógica de negócio sem metadados de persistência
> - Use Cases repassam `EntityDetails` para ViewModels, que podem extrair a `Entity` pura via propriedade `data`
>
> **Exemplo**:
> ```dart
> // ✅ Correto: Repository retorna EntityDetails
> Future<Result<FinanceDetails>> getById(String id);
> 
> // ❌ Incorreto: Repository NÃO deve retornar Entity pura
> Future<Result<Finance>> getById(String id);  // Finance não tem id!
> ```
>
> **Referência**: [Padrões Arquiteturais - EntityDetails](../architecture/architecture_patterns.md#entitydetails---dados-completos)

## Consequências

- Redução drástica (~60%) de código repetitivo nos repositórios.
- Padronização do fluxo de execução.
- Logs e tratamentos de erro garantidos por herança.
- Integração automática com `Result<T>` e `DioErrorHandler`.
- Repositórios concretos focam apenas na lógica de negócio (endpoints, parsing).

---

## Exemplo de Implementação

> [!NOTE]
> **Exemplo de Referência**
>
> Este é um exemplo de como o `BaseRepositoryLocal` será implementado no `core_client`.
> A implementação real ainda será criada seguindo esta especificação.

```dart
// packages/core/core_client/lib/src/repositories/base_repository_local.dart

import 'package:dio/dio.dart';
import '../result/result.dart';
import '../mixins/dio_error_handler.dart';

/// Classe base para repositórios que acessam APIs HTTP via Dio.
///
/// Fornece métodos helpers que encapsulam:
/// - Execução segura de requisições HTTP
/// - Tratamento automático de exceções do Dio via [DioErrorHandler]
/// - Conversão para o padrão [Result<T>]
/// - Logging estruturado
///
/// Tipo genérico:
/// - [TEntity]: Tipo da entidade de domínio (ex: `FinanceDetails`)
/// - [TCreate]: Tipo do DTO de criação (ex: `FinanceCreate`)
///
/// Uso:
/// ```dart
/// class FinanceRepositoryLocal 
///     extends BaseRepositoryLocal<FinanceDetails, FinanceCreate>
///     implements FinanceRepository {
///   
///   FinanceRepositoryLocal(super.dio);
///
///   @override
///   Future<Result<FinanceDetails>> create(FinanceCreate data) async {
///     return executeRequest(
///       request: () => dio.post('/finances', data: data.toJson()),
///       parser: (json) => FinanceDetailsModel.fromJson(json).toDomain(),
///       context: 'create',
///     );
///   }
/// }
/// ```
abstract class BaseRepositoryLocal<TEntity, TCreate> with DioErrorHandler {
  /// Instância do Dio para fazer requisições HTTP.
  final Dio dio;

  BaseRepositoryLocal(this.dio);

  /// Executa uma requisição que retorna uma única entidade.
  ///
  /// [request]: Função que realiza a requisição HTTP
  /// [parser]: Função que converte o JSON para a entidade de domínio
  /// [context]: Contexto para logging (geralmente o nome do método)
  ///
  /// Retorna `Success<T>` se a requisição foi bem-sucedida,
  /// ou `Failure<T>` com [DataException] em caso de erro.
  Future<Result<T>> executeRequest<T>({
    required Future<Response> Function() request,
    required T Function(Map<String, dynamic> json) parser,
    String? context,
  }) async {
    try {
      final response = await request();
      final entity = parser(response.data as Map<String, dynamic>);
      return Success(entity);
    } on DioException catch (e) {
      return handleDioError<T>(e, context: context);
    } catch (e) {
      // Erros inesperados (parsing, etc)
      return Failure(
        DataException(
          message: 'Erro inesperado: ${e.toString()}',
        ),
      );
    }
  }

  /// Executa uma requisição que retorna uma lista de entidades.
  ///
  /// [request]: Função que realiza a requisição HTTP
  /// [parser]: Função que converte um item JSON para a entidade de domínio
  /// [context]: Contexto para logging (geralmente o nome do método)
  ///
  /// Retorna `Success<List<T>>` se a requisição foi bem-sucedida,
  /// ou `Failure<List<T>>` com [DataException] em caso de erro.
  Future<Result<List<T>>> executeListRequest<T>({
    required Future<Response> Function() request,
    required T Function(Map<String, dynamic> json) parser,
    String? context,
  }) async {
    try {
      final response = await request();
      final list = (response.data as List)
          .map((item) => parser(item as Map<String, dynamic>))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      return handleDioError<List<T>>(e, context: context);
    } catch (e) {
      return Failure(
        DataException(
          message: 'Erro inesperado ao processar lista: ${e.toString()}',
        ),
      );
    }
  }

  /// Executa uma requisição que não retorna dados (void).
  ///
  /// Útil para operações como DELETE ou ações que apenas retornam status HTTP.
  ///
  /// [request]: Função que realiza a requisição HTTP
  /// [context]: Contexto para logging (geralmente o nome do método)
  ///
  /// Retorna `Success<void>` se a requisição foi bem-sucedida,
  /// ou `Failure<void>` com [DataException] em caso de erro.
  Future<Result<void>> executeVoidRequest({
    required Future<Response> Function() request,
    String? context,
  }) async {
    try {
      await request();
      return const Success(null);
    } on DioException catch (e) {
      return handleDioError<void>(e, context: context);
    } catch (e) {
      return Failure(
        DataException(
          message: 'Erro inesperado: ${e.toString()}',
        ),
      );
    }
  }

  /// Executa uma requisição customizada com lógica específica.
  ///
  /// Use quando `executeRequest` ou `executeListRequest` não se aplicam.
  ///
  /// **Casos de uso típicos**:
  /// - Requisições que retornam estruturas aninhadas complexas
  /// - APIs que retornam formatos não-padrão (não objeto único nem lista)
  /// - Processamento customizado complexo antes de retornar
  /// - Endpoints de estatísticas, agregações ou relatórios
  ///
  /// **Quando NÃO usar**: Para operações CRUD padrão, prefira sempre
  /// `executeRequest`, `executeListRequest` ou `executeVoidRequest`.
  ///
  /// [request]: Função que realiza a requisição e processa a resposta
  /// [context]: Contexto para logging
  ///
  /// Retorna `Result<T>` conforme definido na função de request.
  Future<Result<T>> executeCustomRequest<T>({
    required Future<T> Function() request,
    String? context,
  }) async {
    try {
      final result = await request();
      return Success(result);
    } on DioException catch (e) {
      return handleDioError<T>(e, context: context);
    } catch (e) {
      return Failure(
        DataException(
          message: 'Erro inesperado: ${e.toString()}',
        ),
      );
    }
  }
}
```

---

## Exemplos de Uso

### Repositório Completo

```dart
// packages/finance/finance_client/lib/src/repositories/finance_repository_local.dart

import 'package:dio/dio.dart';
import 'package:core_client/core_client.dart';
import 'package:core_shared/core_shared.dart';
import 'package:finance_core/finance_core.dart';

/// Implementação local do repositório de Finanças usando HTTP.
class FinanceRepositoryLocal 
    extends BaseRepositoryLocal<FinanceDetails, FinanceCreate>
    implements FinanceRepository {
  
  FinanceRepositoryLocal(super.dio);

  @override
  Future<Result<FinanceDetails>> create(FinanceCreate data) async {
    return executeRequest(
      request: () => dio.post(
        '/finances',
        data: FinanceCreateModel.fromDomain(data).toJson(),
      ),
      parser: (json) => FinanceDetailsModel.fromJson(json).toDomain(),
      context: 'FinanceRepository.create',
    );
  }

  @override
  Future<Result<FinanceDetails>> getById(String id) async {
    return executeRequest(
      request: () => dio.get('/finances/$id'),
      parser: (json) => FinanceDetailsModel.fromJson(json).toDomain(),
      context: 'FinanceRepository.getById',
    );
  }

  @override
  Future<Result<List<FinanceDetails>>> getAll() async {
    return executeListRequest(
      request: () => dio.get('/finances'),
      parser: (json) => FinanceDetailsModel.fromJson(json).toDomain(),
      context: 'FinanceRepository.getAll',
    );
  }

  @override
  Future<Result<FinanceDetails>> update(FinanceUpdate data) async {
    return executeRequest(
      request: () => dio.put(
        '/finances/${data.id}',
        data: FinanceUpdateModel.fromDomain(data).toJson(),
      ),
      parser: (json) => FinanceDetailsModel.fromJson(json).toDomain(),
      context: 'FinanceRepository.update',
    );
  }

  @override
  Future<Result<void>> delete(String id) async {
    return executeVoidRequest(
      request: () => dio.delete('/finances/$id'),
      context: 'FinanceRepository.delete',
    );
  }

  @override
  Future<Result<void>> softDelete(String id) async {
    return executeVoidRequest(
      request: () => dio.patch(
        '/finances/$id/soft-delete',
      ),
      context: 'FinanceRepository.softDelete',
    );
  }

  @override
  Future<Result<void>> restore(String id) async {
    return executeVoidRequest(
      request: () => dio.patch(
        '/finances/$id/restore',
      ),
      context: 'FinanceRepository.restore',
    );
  }
}
```

### Caso de Uso Personalizado

Para operações que não se encaixam nos padrões, use `executeCustomRequest`:

```dart
@override
Future<Result<FinanceStatistics>> getStatistics(
  DateTime startDate,
  DateTime endDate,
) async {
  return executeCustomRequest(
    request: () async {
      final response = await dio.get(
        '/finances/statistics',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      
      // Processamento customizado da resposta
      final data = response.data as Map<String, dynamic>;
      return FinanceStatisticsModel.fromJson(data).toDomain();
    },
    context: 'FinanceRepository.getStatistics',
  );
}
```

### Comparação: Antes vs Depois

#### ❌ Antes (SEM BaseRepository)

```dart
class FinanceRepositoryLocal implements FinanceRepository {
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
      final String errorMessage;
      final statusCode = e.response?.statusCode;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Tempo de conexão esgotado';
          break;
        case DioExceptionType.badResponse:
          errorMessage = _extractErrorMessage(e.response, statusCode);
          break;
        // ... mais 10 linhas de tratamento de erro
      }

      return Failure(DataException(
        message: errorMessage,
        statusCode: statusCode,
      ));
    }
  }

  // Repetir tudo isso para getById, getAll, update, delete...
}
```

#### ✅ Depois (COM BaseRepository)

```dart
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
  Future<Result<FinanceDetails>> getById(String id) async {
    return executeRequest(
      request: () => dio.get('/finances/$id'),
      parser: (json) => FinanceDetailsModel.fromJson(json).toDomain(),
      context: 'getById',
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

**Redução**: ~70% menos código repetitivo! 🎉

---

## Benefícios

### 1. **DRY (Don't Repeat Yourself)**
- Lógica de tratamento de erro centralizada
- Conversão para `Result<T>` padronizada
- Logging consistente em todos os repositórios

### 2. **Type Safety**
- Genéricos garantem tipagem correta
- Compiler verifica compatibilidade entre parser e tipo de retorno

### 3. **Manutenibilidade**
- Mudanças no tratamento de erro afetam todos os repositórios automaticamente
- Fácil adicionar features como retry logic, caching, etc.

### 4. **Testabilidade**
- Fácil mockar `Dio` injetado via construtor
- Métodos helper facilitam testes unitários dos repositórios

### 5. **Consistência**
- Todos os repositórios seguem o mesmo padrão
- Facilita onboarding de novos desenvolvedores

---

## Integração com Outros Padrões

### Com Result Pattern (ADR-0001)

```dart
// No UseCase
final result = await _repository.create(financeData);

switch (result) {
  case Success<FinanceDetails>(:final value):
    // Sucesso - value é do tipo FinanceDetails
    return Success(value);
    
  case Failure<FinanceDetails>(:final error):
    // Erro - error é DataException com mensagem amigável
    return Failure(error);
}
```

### Com DioErrorHandler (ADR-0002)

O `BaseRepositoryLocal` **incorpora automaticamente** o `DioErrorHandler` via mixin:

```dart
abstract class BaseRepositoryLocal<TEntity, TCreate> with DioErrorHandler {
  // ...
  
  Future<Result<T>> executeRequest<T>({...}) async {
    try {
      // ...
    } on DioException catch (e) {
      return handleDioError<T>(e, context: context); // ← Usa o mixin
    }
  }
}
```

---

## Localização no Monorepo

O `BaseRepositoryLocal` deve ser implementado em:

```
packages/core/core_client/lib/src/repositories/base_repository_local.dart
```

Conforme a estrutura de pacotes definida no **ADR-0005**.

---

## Referências

- [ADR-0001: Padrão Result para Tratamento de Erros](./0001-use-result-pattern-for-error-handling.md)
- [ADR-0002: DioErrorHandler Mixin](./0002-use-dio-error-handler-mixin.md)
- [ADR-0005: Estrutura Padrão de Pacotes](./0005-standard-package-structure.md)
- [Padrões Arquiteturais](../architecture/architecture_patterns.md)
- [Padrões de Entities](../architecture/entity_patterns.md)
- [Guia de Criação de Features](../rules/new_feature.md)
- [Flutter & Dart Rules - Tratamento de Erros](../rules/flutter_dart_rules.md#tratamento-de-erros)

