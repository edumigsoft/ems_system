import '../constants/tag_constants.dart';
import '../domain/dtos/tag_update.dart';
import 'validation_result.dart';

/// Validator for TagUpdate DTO.
///
/// Validates tag update data according to business rules defined in [TagConstants].
class TagUpdateValidator {
  const TagUpdateValidator();

  /// Validates a TagUpdate instance.
  ///
  /// Returns a [ValidationResult] containing any validation errors.
  ValidationResult validate(TagUpdate value) {
    final List<ValidationError> errors = [];

    // Validate id (required)
    if (value.id.isEmpty) {
      errors.add(
        const ValidationError(
          field: 'id',
          message: 'ID é obrigatório',
        ),
      );
    }

    // Validate hasChanges
    if (!value.hasChanges) {
      errors.add(
        const ValidationError(
          field: 'general',
          message: 'Nenhuma alteração foi especificada',
        ),
      );
    }

    // Validate name (optional, but if present must respect constraints)
    if (value.name != null) {
      if (value.name!.isEmpty) {
        errors.add(
          const ValidationError(
            field: 'name',
            message: 'Nome não pode ser vazio',
          ),
        );
      } else if (value.name!.length < TagConstants.minNameLength) {
        errors.add(
          ValidationError(
            field: 'name',
            message:
                'Nome deve ter no mínimo ${TagConstants.minNameLength} caractere',
          ),
        );
      } else if (value.name!.length > TagConstants.maxNameLength) {
        errors.add(
          ValidationError(
            field: 'name',
            message:
                'Nome deve ter no máximo ${TagConstants.maxNameLength} caracteres',
          ),
        );
      }
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
