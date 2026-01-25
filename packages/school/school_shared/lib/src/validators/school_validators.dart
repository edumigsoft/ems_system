import 'package:core_shared/core_shared.dart';
import '../domain/entities/school_details.dart';

class SchoolDetailsValidator extends CoreValidator<SchoolDetails> {
  const SchoolDetailsValidator();

  @override
  CoreValidationResult validate(SchoolDetails value) {
    final errors = <CoreValidationError>[];

    // Validar nome
    if (value.name.isEmpty) {
      errors.add(
        const CoreValidationError(
          field: 'name',
          message: 'O nome não pode ser vazio.',
        ),
      );
    }

    // Validar email
    if (value.email.isEmpty) {
      errors.add(
        const CoreValidationError(
          field: 'email',
          message: 'O e-mail não pode ser vazio.',
        ),
      );
    } else if (!_isValidEmail(value.email)) {
      errors.add(
        const CoreValidationError(
          field: 'email',
          message: 'E-mail inválido.',
        ),
      );
    }

    // Validar endereço
    if (value.address.isEmpty) {
      errors.add(
        const CoreValidationError(
          field: 'address',
          message: 'O endereço não pode ser vazio.',
        ),
      );
    }

    // Validar telefone
    if (value.phone.isEmpty) {
      errors.add(
        const CoreValidationError(
          field: 'phone',
          message: 'O telefone não pode ser vazio.',
        ),
      );
    } else if (!_isValidPhone(value.phone)) {
      errors.add(
        const CoreValidationError(
          field: 'phone',
          message: 'Telefone inválido - use (XX) XXXXX-XXXX',
        ),
      );
    }

    // Validar CIE
    if (value.cie.isEmpty) {
      errors.add(
        const CoreValidationError(
          field: 'cie',
          message: 'O cie não pode ser vazio.',
        ),
      );
    }

    return errors.isEmpty
        ? CoreValidationResult.success()
        : CoreValidationResult.failure(errors);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r"^\(?[1-9]{2}\)?\s?(?:9\d{4}|\d{4})\-?\d{4}$");
    return phoneRegex.hasMatch(phone);
  }
}
