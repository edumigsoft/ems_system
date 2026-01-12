import 'package:core_shared/core_shared.dart';
import '../domain/dtos/book_update.dart';
// import '../constants/book_constants.dart';

/// Validator para atualização de Book.
class BookUpdateValidator extends CoreValidator<BookUpdate> {
  const BookUpdateValidator();

  @override
  CoreValidationResult validate(BookUpdate value) {
    final List<CoreValidationError> errors = [];

    // Validar ID (obrigatório em updates)
    if (value.id.isEmpty) {
       errors.add(const CoreValidationError(field: 'id', message: 'ID is required'));
    }

    // Exemplo de validação opcional
    // if (value.name != null && value.name!.isEmpty) {
    //   errors.add(ValidationError(field: 'name', message: 'Name cannot be empty'));
    // }
    
    return CoreValidationResult(isValid: true, errors: errors);
  }
}
