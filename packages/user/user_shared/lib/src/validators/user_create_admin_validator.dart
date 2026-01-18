import 'package:ems_system_core_shared/core_shared.dart'
    show CoreValidator, CoreValidationResult, CoreValidationError;

import '../domain/dtos/user_create_admin.dart';

/// Validator para UserCreateAdmin DTO.
///
/// Valida todos os campos de criação administrativa de usuário:
/// - Nome: mínimo 2 caracteres
/// - Email: formato válido
/// - Username: mínimo 3 caracteres, sem espaços
/// - Role: válido (mas não valida permissões - isso é feito na rota)
///
/// NÃO valida senha (criação administrativa não requer senha).
class UserCreateAdminValidator extends CoreValidator<UserCreateAdmin> {
  const UserCreateAdminValidator();

  @override
  CoreValidationResult validate(UserCreateAdmin value) {
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

    // Validar telefone (opcional)
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

    return errors.isEmpty
        ? CoreValidationResult.success()
        : CoreValidationResult.failure(errors);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return emailRegex.hasMatch(email);
  }
}
