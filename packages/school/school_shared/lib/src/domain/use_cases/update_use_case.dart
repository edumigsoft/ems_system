import 'package:core_shared/core_shared.dart';
import '../repositories/school_repository.dart';
import '../entities/school_details.dart';

class UpdateUseCase {
  final SchoolRepository _repository;

  UpdateUseCase({required SchoolRepository repository})
    : _repository = repository;

  Future<Result<SchoolDetails>> execute(SchoolDetails school) async {
    return await _repository.update(school);
  }
}
