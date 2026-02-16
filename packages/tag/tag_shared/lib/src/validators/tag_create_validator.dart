import '../constants/tag_constants.dart';
import '../domain/dtos/tag_create.dart';
import 'validation_result.dart';

/// Validator for TagCreate DTO.
///
/// Validates tag creation data according to business rules defined in [TagConstants].
class TagCreateValidator {
  const TagCreateValidator();

  /// Validates a TagCreate instance.
  ///
  /// Returns a [ValidationResult] containing any validation errors.
  ValidationResult validate(TagCreate value) {
    final List<ValidationError> errors = [];

    // Validate name
    if (value.name.isEmpty) {
      errors.add(
        const ValidationError(
          field: 'name',
          message: 'Nome é obrigatório',
        ),
      );
    } else if (value.name.length < TagConstants.minNameLength) {
      errors.add(
        ValidationError(
          field: 'name',
          message:
              'Nome deve ter no mínimo ${TagConstants.minNameLength} caractere',
        ),
      );
    } else if (value.name.length > TagConstants.maxNameLength) {
      errors.add(
        ValidationError(
          field: 'name',
          message:
              'Nome deve ter no máximo ${TagConstants.maxNameLength} caracteres',
        ),
      );
    }

    // Validate description (optional, but if present must respect max length)
    if (value.description != null &&
        value.description!.length > TagConstants.maxDescriptionLength) {
      errors.add(
        ValidationError(
          field: 'description',
          message:
              'Descrição deve ter no máximo ${TagConstants.maxDescriptionLength} caracteres',
        ),
      );
    }

    // Validate color (optional, but if present must be valid hex)
    if (value.color != null && value.color!.isNotEmpty) {
      final colorRegex = RegExp(TagConstants.hexColorPattern);
      if (!colorRegex.hasMatch(value.color!)) {
        errors.add(
          const ValidationError(
            field: 'color',
            message: 'Cor deve ser um código hexadecimal válido (ex: #FF5722)',
          ),
        );
      }
    }

    return ValidationResult(errors);
  }
}
