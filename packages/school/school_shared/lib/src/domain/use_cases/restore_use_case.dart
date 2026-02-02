import 'package:core_shared/core_shared.dart';
import '../repositories/school_repository.dart';

/// Use case para restaurar uma escola deletada (soft delete).
///
/// Marca uma escola previamente deletada como ativa novamente,
/// permitindo que ela seja visualizada e gerenciada normalmente.
class RestoreSchoolUseCase {
  final SchoolRepository _repository;

  RestoreSchoolUseCase({required SchoolRepository repository})
    : _repository = repository;

  Future<Result<Unit>> execute(String id) {
    return _repository.restore(id);
  }
}
