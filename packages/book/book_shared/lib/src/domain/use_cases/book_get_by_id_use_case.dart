import 'package:core_shared/core_shared.dart';
import '../../../book_shared.dart';

/// Use case para obter Book por ID.
class BookGetByIdUseCase {
  final BookRepository repository;

  BookGetByIdUseCase(this.repository);

  Future<Result<BookDetails>> call(String id) async {
    return repository.getById(id);
  }
}
