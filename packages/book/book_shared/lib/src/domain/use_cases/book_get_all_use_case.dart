import 'package:core_shared/core_shared.dart';
import '../../../book_shared.dart';

/// Use case para obter lista de Books.
class BookGetAllUseCase {
  final BookRepository repository;

  BookGetAllUseCase(this.repository);

  Future<Result<List<BookDetails>>> call({
    int? limit,
    int? offset,
  }) async {
    return repository.getAll(limit: limit, offset: offset);
  }
}
