/// Interface base para validadores do sistema.
abstract class CoreValidator<T> {
  const CoreValidator();

  /// Valida um valor e retorna um resultado padronizado.
  CoreValidationResult validate(T value);
}

/// Resultado de validação agnóstico.
class CoreValidationResult {
  final bool isValid;
  final List<CoreValidationError> errors;

  const CoreValidationResult({
    required this.isValid,
    this.errors = const [],
  });

  factory CoreValidationResult.success() =>
      const CoreValidationResult(isValid: true);

  factory CoreValidationResult.failure(List<CoreValidationError> errors) =>
      CoreValidationResult(isValid: false, errors: errors);
}

/// Erro de validação padronizado.
class CoreValidationError {
  final String field;
  final String message;

  const CoreValidationError({required this.field, required this.message});
}
