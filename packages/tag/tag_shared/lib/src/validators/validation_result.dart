/// Result of a validation operation.
class ValidationResult {
  final List<ValidationError> errors;

  /// Creates a validation result.
  const ValidationResult(this.errors);

  /// Whether the validation passed (no errors).
  bool get isValid => errors.isEmpty;

  /// Whether the validation failed (has errors).
  bool get isInvalid => errors.isNotEmpty;

  /// Gets the first error message, or null if valid.
  String? get firstErrorMessage =>
      errors.isNotEmpty ? errors.first.message : null;

  @override
  String toString() => 'ValidationResult(errors: ${errors.length})';
}

/// Represents a validation error.
class ValidationError {
  final String field;
  final String message;

  /// Creates a validation error.
  const ValidationError({
    required this.field,
    required this.message,
  });

  @override
  String toString() => '$field: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationError &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          message == other.message;

  @override
  int get hashCode => Object.hash(field, message);
}
