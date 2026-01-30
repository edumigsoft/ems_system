import 'package:core_shared/core_shared.dart';
import '../repositories/school_repository.dart';
import '../entities/school_details.dart';
import '../enums/school_enum.dart';

/// Use case para buscar escolas deletadas (soft delete).
///
/// Permite que administradores visualizem escolas marcadas como deletadas
/// para possível restauração.
class GetDeletedSchoolsUseCase {
  final SchoolRepository _repository;

  GetDeletedSchoolsUseCase({required SchoolRepository repository})
    : _repository = repository;

  Future<Result<PaginatedResult<SchoolDetails>>> execute({
    int? limit,
    int? offset,
    String? search,
    SchoolStatus? status,
    String? city,
    String? district,
  }) {
    return _repository.getDeleted(
      limit: limit,
      offset: offset,
      search: search,
      status: status,
      city: city,
      district: district,
    );
  }
}
