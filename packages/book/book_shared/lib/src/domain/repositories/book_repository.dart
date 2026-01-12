import 'package:core_shared/core_shared.dart';
import '../entities/book_details.dart';
import '../dtos/book_create.dart';
import '../dtos/book_update.dart';

/// Repository para operações CRUD de Book.
abstract class BookRepository {
  Future<Result<List<BookDetails>>> getAll({int? limit, int? offset});
  Future<Result<BookDetails>> getById(String id);
  Future<Result<BookDetails>> create(BookCreate data);
  Future<Result<BookDetails>> update(BookUpdate data);
  Future<Result<void>> delete(String id);
}
