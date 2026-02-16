import 'package:core_shared/core_shared.dart';
import 'package:zard/zard.dart';

/// Nomes dos campos do formulário de notebook
const String notebookTitleField = 'title';
const String notebookContentField = 'content';
const String notebookTagsField = 'tags';

/// Validator para dados de Notebook.
///
/// Valida os campos básicos de um notebook (title, content).
/// Tags são opcionais e não são validadas pelo schema.
class NotebookValidator extends CoreValidator<Map<String, dynamic>> {
  const NotebookValidator();

  /// Schema de validação Zard para campos de notebook.
  static final schema = z.map({
    notebookTitleField: z.string().min(
      1,
      message: 'O título é obrigatório',
    ),
    notebookContentField: z.string().min(
      1,
      message: 'O conteúdo é obrigatório',
    ),
    // Tags é opcional, não precisa de validação
  });

  @override
  CoreValidationResult validate(Map<String, dynamic> value) {
    final result = schema.safeParse(value);

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
