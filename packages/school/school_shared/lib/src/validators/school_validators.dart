import 'package:core_shared/core_shared.dart';
import 'package:zard/zard.dart';
import '../domain/entities/school_details.dart';

class SchoolDetailsValidator extends CoreValidator<SchoolDetails> {
  const SchoolDetailsValidator();

  @override
  CoreValidationResult validate(SchoolDetails value) {
    final schema = z.map({
      'name': z.string().min(1, message: 'O nome não pode ser vazio.'),
      'email': z
          .string()
          .email(message: 'E-mail inválido.')
          .min(1, message: 'O e-mail não pode ser vazio.'),
      'address': z.string().min(
        1,
        message: 'O endereço não pode ser vazio.',
      ),
      'phone': z
          .string()
          .regex(
            RegExp(r"^\(?[1-9]{2}\)?\s?(?:9\d{4}|\d{4})\-?\d{4}$"),
            message: 'Telefone inválido - use (XX) XXXXX-XXXX',
          )
          .min(1, message: 'O telefone não pode ser vazio.'),
      'cie': z.string().min(1, message: 'O cie não pode ser vazio.'),
    });

    // Extrair dados do DTO para validação
    final data = {
      'name': value.name,
      'email': value.email,
      'address': value.address,
      'phone': value.phone,
      'cie': value.cie,
    };

    final result = schema.safeParse(data);

    if (result.success) {
      return CoreValidationResult.success();
    } else {
      // Access error from result
      // The library might not expose strict types for all properties, so we handle defensively.

      // ignore: avoid_dynamic_calls
      final error = (result as dynamic).error;

      final List<CoreValidationError> errors = [];

      if (error != null) {
        try {
          // Access .issues
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
      }

      return CoreValidationResult.failure(errors);
    }
  }
}
