import 'package:core_shared/core_shared.dart';
import '../models/auth_request.dart';

/// Validator para LoginRequest.
///
/// Valida email e senha seguindo regras de negócio:
/// - Email: formato válido
/// - Senha: mínimo 1 caractere (presença)
class LoginRequestValidator extends CoreValidator<LoginRequest> {
  const LoginRequestValidator();

  @override
  CoreValidationResult validate(LoginRequest value) {
    final errors = <CoreValidationError>[];

    // Validar email
    if (value.email.isEmpty) {
      errors.add(
        const CoreValidationError(
          field: 'email',
          message: 'Email é obrigatório',
        ),
      );
    } else if (!_isValidEmail(value.email)) {
      errors.add(
        const CoreValidationError(
          field: 'email',
          message: 'Formato de email inválido',
        ),
      );
    }

    // Validar senha
    if (value.password.isEmpty) {
      errors.add(
        const CoreValidationError(
          field: 'password',
          message: 'Senha é obrigatória',
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
}

/// Validator para RegisterRequest.
///
/// Valida todos os campos de registro:
/// - Nome: mínimo 2 caracteres
/// - Email: formato válido
/// - Username: mínimo 3 caracteres, sem espaços
/// - Senha: mínimo 8 caracteres
class RegisterRequestValidator extends CoreValidator<RegisterRequest> {
  const RegisterRequestValidator();

  @override
  CoreValidationResult validate(RegisterRequest value) {
    final errors = <CoreValidationError>[];

    // Validar nome
    if (value.name.isEmpty) {
      errors.add(
        const CoreValidationError(field: 'name', message: 'Nome é obrigatório'),
      );
    } else if (value.name.trim().length < 2) {
      errors.add(
        const CoreValidationError(
          field: 'name',
          message: 'Nome deve ter no mínimo 2 caracteres',
        ),
      );
    }

    // Validar email
    if (value.email.isEmpty) {
      errors.add(
        const CoreValidationError(
          field: 'email',
          message: 'Email é obrigatório',
        ),
      );
    } else if (!_isValidEmail(value.email)) {
      errors.add(
        const CoreValidationError(
          field: 'email',
          message: 'Formato de email inválido',
        ),
      );
    }

    // Validar username
    if (value.username.isEmpty) {
      errors.add(
        const CoreValidationError(
          field: 'username',
          message: 'Username é obrigatório',
        ),
      );
    } else if (value.username.length < 3) {
      errors.add(
        const CoreValidationError(
          field: 'username',
          message: 'Username deve ter no mínimo 3 caracteres',
        ),
      );
    } else if (value.username.contains(' ')) {
      errors.add(
        const CoreValidationError(
          field: 'username',
          message: 'Username não pode conter espaços',
        ),
      );
    }

    // Validar senha
    if (value.password.isEmpty) {
      errors.add(
        const CoreValidationError(
          field: 'password',
          message: 'Senha é obrigatória',
        ),
      );
    } else if (value.password.length < 8) {
      errors.add(
        const CoreValidationError(
          field: 'password',
          message: 'Senha deve ter no mínimo 8 caracteres',
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
}

/// Validator para PasswordResetRequest.
class PasswordResetRequestValidator
    extends CoreValidator<PasswordResetRequest> {
  const PasswordResetRequestValidator();

  @override
  CoreValidationResult validate(PasswordResetRequest value) {
    final errors = <CoreValidationError>[];

    if (value.email.isEmpty) {
      errors.add(
        const CoreValidationError(
          field: 'email',
          message: 'Email é obrigatório',
        ),
      );
    } else if (!_isValidEmail(value.email)) {
      errors.add(
        const CoreValidationError(
          field: 'email',
          message: 'Formato de email inválido',
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
}

/// Validator para PasswordResetConfirm.
class PasswordResetConfirmValidator
    extends CoreValidator<PasswordResetConfirm> {
  const PasswordResetConfirmValidator();

  @override
  CoreValidationResult validate(PasswordResetConfirm value) {
    final errors = <CoreValidationError>[];

    if (value.token.isEmpty) {
      errors.add(
        const CoreValidationError(
          field: 'token',
          message: 'Token é obrigatório',
        ),
      );
    }

    if (value.newPassword.isEmpty) {
      errors.add(
        const CoreValidationError(
          field: 'newPassword',
          message: 'Nova senha é obrigatória',
        ),
      );
    } else if (value.newPassword.length < 8) {
      errors.add(
        const CoreValidationError(
          field: 'newPassword',
          message: 'Nova senha deve ter no mínimo 8 caracteres',
        ),
      );
    }

    return errors.isEmpty
        ? CoreValidationResult.success()
        : CoreValidationResult.failure(errors);
  }
}
