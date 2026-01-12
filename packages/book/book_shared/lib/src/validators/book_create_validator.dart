import 'package:core_shared/core_shared.dart';
import '../domain/dtos/book_create.dart';
// import '../constants/book_constants.dart';

/// Validator para criação de Book.
class BookCreateValidator extends CoreValidator<BookCreate> {
  const BookCreateValidator();

  @override
  CoreValidationResult validate(BookCreate value) {
    final List<CoreValidationError> errors = [];

    // Exemplo de validação:
    // if (value.name.isEmpty) {
    //   errors.add(CoreValidationError(field: 'name', message: 'Name required'));
    // }
    
    return CoreValidationResult(isValid: true, errors: errors);
  }
}
