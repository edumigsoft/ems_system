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

  /// Executa uma função assíncrona se o resultado for [Success].
  Future<Result<R>> mapAsync<R>(Future<R> Function(T) mapper) async {
    return switch (this) {
      Success(value: final value) => Success(await mapper(value)),
      Failure(error: final error) => Failure(error),
    };
  }

  /// Executa uma função se o resultado for [Failure].
  Result<T> mapError(Exception Function(Exception) mapper) {
    return switch (this) {
      Success() => this,
      Failure(error: final error) => Failure(mapper(error)),
    };
  }

  /// Combina dois resultados em um único resultado de tupla.
  Result<(T, R)> combine<R>(Result<R> other) {
    return switch ((this, other)) {
      (Success(value: final a), Success(value: final b)) => Success((a, b)),
      (Failure(error: final e), _) => Failure(e),
      (_, Failure(error: final e)) => Failure(e),
    };
  }

  /// Retorna o valor em caso de sucesso, ou null em caso de falha.
  T? get valueOrNull {
    return switch (this) {
      Success<T>(:final value) => value,
      Failure<T>() => null,
    };
  }

  /// Retorna o valor se for [Success], caso contrário lança a exceção.
  T get valueOrThrow {
    return switch (this) {
      Success(value: final value) => value,
      Failure(error: final error) => throw error,
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

/// Classe utilitária para representar um valor vazio.
class Unit {}

/// Retorna um [Success] com um [Unit].
Result<Unit> successOfUnit() => Success(Unit());
