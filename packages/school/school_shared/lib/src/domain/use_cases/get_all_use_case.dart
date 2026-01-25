import 'package:core_shared/core_shared.dart';
import '../repositories/school_repository.dart';
import '../entities/school_details.dart';

class GetAllUseCase {
  final SchoolRepository _repository;

  GetAllUseCase({required SchoolRepository repository})
    : _repository = repository;

  Future<Result<List<SchoolDetails>>> execute({int? limit, int? offset}) async {
    return await _repository.getAll(limit: limit, offset: offset);
  }
}
