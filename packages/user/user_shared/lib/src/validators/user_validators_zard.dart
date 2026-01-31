import 'package:core_shared/core_shared.dart';
import 'package:zard/zard.dart';
import '../domain/dtos/user_create.dart';
import '../domain/dtos/user_update.dart';
import '../domain/dtos/user_create_admin.dart';

// Field constants
const String userNameField = 'name';
const String userEmailField = 'email';
const String userUsernameField = 'username';
const String userPasswordField = 'password';
const String userPhoneField = 'phone';
const String userAvatarUrlField = 'avatarUrl';

/// Validator Zard para UserCreate DTO.
///
/// Valida todos os campos de criação de usuário usando schema declarativo:
/// - Nome: mínimo 2 caracteres
/// - Email: formato válido
/// - Username: mínimo 3 caracteres, sem espaços
/// - Senha: mínimo 8 caracteres
class UserCreateValidatorZard extends CoreValidator<UserCreate> {
  const UserCreateValidatorZard();

  static final schema = z.map({
    userNameField: z.string().min(
      2,
      message: 'Nome deve ter no mínimo 2 caracteres',
    ),
    userEmailField: z.string().email(message: 'Formato de email inválido'),
    userUsernameField: z
        .string()
        .min(3, message: 'Username deve ter no mínimo 3 caracteres')
        .regex(
          RegExp(r'^\S+$'),
          message: 'Username não pode conter espaços',
        ),
    userPasswordField: z.string().min(
      8,
      message: 'Senha deve ter no mínimo 8 caracteres',
    ),
  });

  @override
  CoreValidationResult validate(UserCreate value) {
    final data = {
      userNameField: value.name,
      userEmailField: value.email,
      userUsernameField: value.username,
      userPasswordField: value.password,
    };

    final result = schema.safeParse(data);

    if (result.success) {
      return CoreValidationResult.success();
    } else {
      final List<CoreValidationError> errors = [];

      try {
        // ignore: avoid_dynamic_calls
        final error = (result as dynamic).error;
        // ignore: avoid_dynamic_calls
        final issues = error.issues as List?;

        if (issues != null) {
          for (final issue in issues) {
            // ignore: avoid_dynamic_calls
            final path = (issue.path as List?)?.join('.') ?? 'unknown';
            // ignore: avoid_dynamic_calls
            final msg = issue.message?.toString() ?? 'Erro inválido';

            errors.add(CoreValidationError(field: path, message: msg));
          }
        }
      } catch (e) {
        errors.add(
          CoreValidationError(
            field: 'parsing',
            message: 'Erro ao processar validação: $e',
          ),
        );
      }

      return CoreValidationResult.failure(errors);
    }
  }
}

/// Validator Zard para UserUpdate DTO.
///
/// Valida campos opcionais de atualização de usuário.
/// Campos são opcionais mas quando presentes devem ser válidos:
/// - Nome: mínimo 2 caracteres (se presente)
/// - Phone: mínimo 10 dígitos (se presente)
/// - AvatarUrl: URL válida (se presente)
class UserUpdateValidatorZard extends CoreValidator<UserUpdate> {
  const UserUpdateValidatorZard();

  static final schema = z.map({
    userNameField: z
        .string()
        .min(
          2,
          message: 'Nome deve ter no mínimo 2 caracteres',
        )
        .optional(),
    userPhoneField: z
        .string()
        .min(10, message: 'Telefone deve ter no mínimo 10 dígitos')
        .optional(),
    userAvatarUrlField: z
        .string()
        .regex(
          RegExp(r'^https?://[\w\.-]+\.\w{2,}.*$'),
          message: 'URL de avatar inválida',
        )
        .optional(),
  });

  @override
  CoreValidationResult validate(UserUpdate value) {
    final data = <String, String?>{
      if (value.name != null) userNameField: value.name,
      if (value.phone != null) userPhoneField: value.phone,
      if (value.avatarUrl != null) userAvatarUrlField: value.avatarUrl,
    };

    final result = schema.safeParse(data);

    if (result.success) {
      return CoreValidationResult.success();
    } else {
      final List<CoreValidationError> errors = [];

      try {
        // ignore: avoid_dynamic_calls
        final error = (result as dynamic).error;
        // ignore: avoid_dynamic_calls
        final issues = error.issues as List?;

        if (issues != null) {
          for (final issue in issues) {
            // ignore: avoid_dynamic_calls
            final path = (issue.path as List?)?.join('.') ?? 'unknown';
            // ignore: avoid_dynamic_calls
            final msg = issue.message?.toString() ?? 'Erro inválido';

            errors.add(CoreValidationError(field: path, message: msg));
          }
        }
      } catch (e) {
        errors.add(
          CoreValidationError(
            field: 'parsing',
            message: 'Erro ao processar validação: $e',
          ),
        );
      }

      return CoreValidationResult.failure(errors);
    }
  }
}

/// Validator Zard para UserCreateAdmin DTO.
///
/// Valida todos os campos de criação administrativa de usuário:
/// - Nome: mínimo 2 caracteres
/// - Email: formato válido
/// - Username: mínimo 3 caracteres, sem espaços
/// - Phone: mínimo 10 dígitos (opcional)
///
/// NÃO valida senha (criação administrativa não requer senha).
class UserCreateAdminValidatorZard extends CoreValidator<UserCreateAdmin> {
  const UserCreateAdminValidatorZard();

  static final schema = z.map({
    userNameField: z.string().min(
      2,
      message: 'Nome deve ter no mínimo 2 caracteres',
    ),
    userEmailField: z.string().email(message: 'Formato de email inválido'),
    userUsernameField: z
        .string()
        .min(3, message: 'Username deve ter no mínimo 3 caracteres')
        .regex(
          RegExp(r'^\S+$'),
          message: 'Username não pode conter espaços',
        ),
    userPhoneField: z
        .string()
        .min(10, message: 'Telefone deve ter no mínimo 10 dígitos')
        .optional(),
  });

  @override
  CoreValidationResult validate(UserCreateAdmin value) {
    final data = <String, String?>{
      userNameField: value.name,
      userEmailField: value.email,
      userUsernameField: value.username,
      if (value.phone != null) userPhoneField: value.phone,
    };

    final result = schema.safeParse(data);

    if (result.success) {
      return CoreValidationResult.success();
    } else {
      final List<CoreValidationError> errors = [];

      try {
        // ignore: avoid_dynamic_calls
        final error = (result as dynamic).error;
        // ignore: avoid_dynamic_calls
        final issues = error.issues as List?;

        if (issues != null) {
          for (final issue in issues) {
            // ignore: avoid_dynamic_calls
            final path = (issue.path as List?)?.join('.') ?? 'unknown';
            // ignore: avoid_dynamic_calls
            final msg = issue.message?.toString() ?? 'Erro inválido';

            errors.add(CoreValidationError(field: path, message: msg));
          }
        }
      } catch (e) {
        errors.add(
          CoreValidationError(
            field: 'parsing',
            message: 'Erro ao processar validação: $e',
          ),
        );
      }

      return CoreValidationResult.failure(errors);
    }
  }
}
