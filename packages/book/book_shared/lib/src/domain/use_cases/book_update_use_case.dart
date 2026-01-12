import 'package:core_shared/core_shared.dart';
import '../../../book_shared.dart';

/// Use case para atualizar Book.
class BookUpdateUseCase {
  final BookRepository repository;

  BookUpdateUseCase(this.repository);

  Future<Result<BookDetails>> call(BookUpdate data) async {
    return repository.update(data);
  }
}
