import 'package:core_shared/core_shared.dart';
import '../../../book_shared.dart';

/// Use case para criar Book.
class BookCreateUseCase {
  final BookRepository repository;

  BookCreateUseCase(this.repository);

  Future<Result<BookDetails>> call(BookCreate data) async {
    return repository.create(data);
  }
}
