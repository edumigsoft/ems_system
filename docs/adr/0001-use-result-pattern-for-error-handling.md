# 1. Uso do Padrão Result para Tratamento de Erros

Date: 2025-12-07

## Status

Aceito

## Contexto

O tratamento de erros com exceções (`try-catch`) pode tornar o fluxo de controle confuso e propenso a falhas se as exceções não forem documentadas ou tratadas corretamente. Precisamos de uma maneira explicita e segura de lidar com falhas em operações.

## Decisão

Adotar o padrão `Result<T>` (também conhecido como Either ou Option em outras linguagens funcionais) para todas as operações que podem falhar, especialmente em Repositórios e Services.

O tipo `Result` é definido no pacote `@core` e possui duas subclasses:
- `Success<T>`: Contém o valor de sucesso.
- `Failure<T>`: Contém a exceção ou erro ocorrido.

### Uso Atual (Pattern Matching - Dart 3)

```dart
final result = await repository.create(data);

// Switch com pattern matching
switch (result) {
  case Success<FinanceDetails>(:final value):
    _finances.add(value);
    notifyListeners();
  case Failure<FinanceDetails>(:final error):
    _errorMessage = error.toString();
    notifyListeners();
}

// Verificação inline para retornos rápidos
if (result case Failure(error: final error)) {
  return Failure(error);
}
```

## Consequências

- Código mais seguro e previsível.
- Obrigatoriedade de tratar casos de falha.
- API mais clara sobre o que pode falhar.
- Redução de blocos `try-catch` espalhados na camada de UI/ViewModel (o tratamento ocorre antes).
- Pattern matching fornece verificação em tempo de compilação de todos os casos.

## Próxima Evolução (Proposta)

### Implementar método `.when()` no `Result<T>`

Seguindo o padrão sugerido pela Google para Flutter/Dart e práticas funcionais modernas, propõe-se adicionar o método `.when()` ao `Result<T>`:

```dart
// Proposta de implementação em result.dart
sealed class Result<T> {
  R when<R>({
    required R Function(T value) success,
    required R Function(Exception error) failure,
  }) {
    return switch (this) {
      Success<T>(:final value) => success(value),
      Failure<T>(:final error) => failure(error),
    };
  }
}
```

**Uso:**
```dart
final result = await repository.create(data);

result.when(
  success: (finance) {
    _finances.add(finance);
    notifyListeners();
  },
  failure: (exception) {
    _errorMessage = exception.message;
    notifyListeners();
  },
);
```

**Benefícios do `.when()`:**
- Mais fluente e idiomático
- Facilita composição funcional
- Código mais expressivo e limpo
- Padrão amplamente usado em bibliotecas funcionais (dartz, fpdart)
- Recomendado pela Google para Dart/Flutter

**Tarefa:** Implementar `.when()` em `packages/core/core_shared/lib/src/result/result.dart` e migrar gradualmente o código existente.

---

## Exemplo de Implementação Completa

> [!NOTE]
> **Exemplo de Referência**
>
> Este é um exemplo de como o `Result<T>` será implementado no `core_shared`.
> A implementação real ainda será criada seguindo esta especificação.

```dart
// packages/core/core_shared/lib/src/result/result.dart

/// Representa o resultado de uma operação que pode falhar.
///
/// [Result] é um tipo soma (sealed class) que pode ser:
/// - [Success]: Contém o valor de sucesso do tipo [T]
/// - [Failure]: Contém a exceção que causou a falha
///
/// Uso:
/// ```dart
/// Future<Result<User>> getUser(String id) async {
///   try {
///     final user = await api.getUser(id);
///     return Success(user);
///   } on ApiException catch (e) {
///     return Failure(e);
///   }
/// }
///
/// // Consumir com pattern matching
/// final result = await getUser('123');
/// switch (result) {
///   case Success(:final value):
///     print('User: ${value.name}');
///   case Failure(:final error):
///     print('Error: $error');
/// }
///
/// // Ou usar .when()
/// result.when(
///   success: (user) => print('User: ${user.name}'),
///   failure: (error) => print('Error: $error'),
/// );
/// ```
sealed class Result<T> {
  const Result();

  /// Executa funções diferentes baseado no resultado.
  ///
  /// [success]: Função executada se o resultado for [Success]
  /// [failure]: Função executada se o resultado for [Failure]
  ///
  /// Retorna o valor de tipo [R] da função executada.
  R when<R>({
    required R Function(T value) success,
    required R Function(Exception error) failure,
  }) {
    return switch (this) {
      Success<T>(:final value) => success(value),
      Failure<T>(:final error) => failure(error),
    };
  }

  /// Transforma o valor em caso de sucesso.
  ///
  /// Mantém o erro em caso de falha.
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(:final value) => Success(transform(value)),
      Failure<T>(:final error) => Failure(error),
    };
  }

  /// Transforma o valor em caso de sucesso para outro Result.
  ///
  /// Útil para encadear operações que podem falhar.
  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    return switch (this) {
      Success<T>(:final value) => transform(value),
      Failure<T>(:final error) => Failure(error),
    };
  }

  /// Retorna o valor em caso de sucesso, ou null em caso de falha.
  T? get valueOrNull {
    return switch (this) {
      Success<T>(:final value) => value,
      Failure<T>() => null,
    };
  }

  /// Retorna true se é um Success.
  bool get isSuccess => this is Success<T>;

  /// Retorna true se é um Failure.
  bool get isFailure => this is Failure<T>;
}

/// Representa um resultado de sucesso contendo um valor do tipo [T].
final class Success<T> extends Result<T> {
  /// O valor de sucesso.
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Representa um resultado de falha contendo uma exceção.
final class Failure<T> extends Result<T> {
  /// A exceção que causou a falha.
  final Exception error;

  const Failure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}
```

### Exemplos de Uso Avançados

#### Composição de Operações

```dart
// Encadear operações que podem falhar
Future<Result<String>> getUserEmail(String userId) async {
  return (await getUser(userId))
    .flatMap((user) => getUserProfile(user.id))
    .map((profile) => profile.email);
}
```

#### Transformação de Dados

```dart
// Transformar valor de sucesso
final result = await getFinances();
final names = result.map((finances) => finances.map((f) => f.name).toList());
```

#### Tratamento em ViewModels

```dart
class FinanceViewModel extends ChangeNotifier {
  List<Finance> _items = [];
  String? _errorMessage;

  Future<void> loadFinances() async {
    final result = await _getAllUseCase();
    
    result.when(
      success: (finances) {
        _items = finances;
        _errorMessage = null;
        notifyListeners();
      },
      failure: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }
}
```

---

## Referências

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Railway Oriented Programming](https://fsharpforfunandprofit.com/rop/)
- [Dart 3 Pattern Matching](https://dart.dev/language/patterns)
- [ADR-0002: DioErrorHandler Mixin](./0002-use-dio-error-handler-mixin.md)
- [ADR-0003: BaseRepository Pattern](./0003-use-base-repository-pattern.md)
