import 'package:core_shared/core_shared.dart';
import 'package:core_client/core_client.dart';
import 'package:book_shared/book_shared.dart';
import '../services/book_service.dart';

/// Implementação client do BookRepository.
class BookRepositoryClient extends BaseRepositoryLocal 
    implements BookRepository {
  final BookService _service;
  final BookDetailsConverter _converter = 
      const BookDetailsConverter();

  BookRepositoryClient(this._service);

  @override
  Future<Result<List<BookDetails>>> getAll({
    int? limit,
    int? offset,
  }) async {
    return executeListRequest(
      request: () => _service.getAll(limit: limit, offset: offset),
      context: 'get all ',
      mapper: _converter.toDomain,
    );
  }

  @override
  Future<Result<BookDetails>> getById(String id) async {
    return executeRequest(
      request: () => _service.getById(id),
      context: 'get Book by id',
      mapper: _converter.toDomain,
    );
  }

  @override
  Future<Result<BookDetails>> create(BookCreate data) async {
    return executeRequest(
      request: () async {
        final model = BookCreateModel.fromDomain(data);
        return _service.create(model);
      },
      context: 'create Book',
      mapper: _converter.toDomain,
    );
  }

  @override
  Future<Result<BookDetails>> update(BookUpdate data) async {
    return executeRequest(
      request: () async {
        final model = BookUpdateModel.fromDomain(data);
        return _service.update(data.id, model);
      },
      context: 'update Book',
      mapper: _converter.toDomain,
    );
  }

  @override
  Future<Result<void>> delete(String id) async {
    return executeVoidRequest(
      request: () => _service.delete(id),
      context: 'delete Book',
    );
  }
}
