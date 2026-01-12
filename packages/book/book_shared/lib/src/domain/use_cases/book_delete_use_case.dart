import 'package:core_shared/core_shared.dart';
import '../../../book_shared.dart';

/// Use case para deletar Book.
class BookDeleteUseCase {
  final BookRepository repository;

  BookDeleteUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    return repository.delete(id);
  }
}
