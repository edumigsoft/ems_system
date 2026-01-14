import 'package:core_shared/core_shared.dart';
import '../domain/dtos/user_create.dart';
import '../domain/dtos/user_update.dart';

/// Validator para UserCreate DTO.
///
/// Valida todos os campos de criação de usuário:
/// - Nome: mínimo 2 caracteres
/// - Email: formato válido
/// - Username: mínimo 3 caracteres, sem espaços
/// - Senha: mínimo 8 caracteres
class UserCreateValidator extends CoreValidator<UserCreate> {
  const UserCreateValidator();

  @override
  CoreValidationResult validate(UserCreate value) {
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

/// Validator para UserUpdate DTO.
///
/// Valida campos opcionais de atualização de usuário.
/// Campos são opcionais mas quando presentes devem ser válidos.
class UserUpdateValidator extends CoreValidator<UserUpdate> {
  const UserUpdateValidator();

  @override
  CoreValidationResult validate(UserUpdate value) {
    final errors = <CoreValidationError>[];

    // Validar nome (opcional)
    if (value.name != null && value.name!.trim().length < 2) {
      errors.add(
        const CoreValidationError(
          field: 'name',
          message: 'Nome deve ter no mínimo 2 caracteres',
        ),
      );
    }

    // Validar phone (opcional) - formato básico
    if (value.phone != null && value.phone!.isNotEmpty) {
      if (value.phone!.length < 10) {
        errors.add(
          const CoreValidationError(
            field: 'phone',
            message: 'Telefone deve ter no mínimo 10 dígitos',
          ),
        );
      }
    }

    // Validar avatarUrl (opcional) - formato básico de URL
    if (value.avatarUrl != null && value.avatarUrl!.isNotEmpty) {
      if (!_isValidUrl(value.avatarUrl!)) {
        errors.add(
          const CoreValidationError(
            field: 'avatarUrl',
            message: 'URL de avatar inválida',
          ),
        );
      }
    }

    return errors.isEmpty
        ? CoreValidationResult.success()
        : CoreValidationResult.failure(errors);
  }

  bool _isValidUrl(String url) {
    final urlRegex = RegExp(r'^https?://[\w\.-]+\.\w{2,}.*$');
    return urlRegex.hasMatch(url);
  }
}
