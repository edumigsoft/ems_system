import 'package:core_client/core_client.dart'
    show BaseRepositoryLocal, Result, Unit;
import 'package:core_shared/core_shared.dart' show PaginatedResult;
import 'package:school_shared/school_shared.dart'
    show
        SchoolRepository,
        SchoolCreate,
        SchoolDetails,
        SchoolCreateModel,
        SchoolDetailsModel,
        SchoolStatus;

import '../services/school_service.dart';

class SchoolRepositoryClient extends BaseRepositoryLocal
    implements SchoolRepository {
  final SchoolService _schoolService;

  SchoolRepositoryClient({required SchoolService schoolService})
    : _schoolService = schoolService;

  @override
  Future<Result<SchoolDetails>> create(SchoolCreate school) async {
    return executeRequest(
      request: () =>
          _schoolService.create(SchoolCreateModel.fromDomain(school)),
      context: 'adding school',
      mapper: (e) => e.toDomain(),
    );
  }

  @override
  Future<Result<Unit>> delete(String id) async {
    return executeVoidRequest(
      request: () => _schoolService.delete(id),
      context: 'deleting school',
    );
  }

  @override
  Future<Result<PaginatedResult<SchoolDetails>>> getAll({
    int? limit,
    int? offset,
    String? search,
    SchoolStatus? status,
    String? city,
    String? district,
  }) async {
    final result = await executeRequest(
      request: () => _schoolService.getAll(
        limit,
        offset,
        search,
        status?.name,
        city,
        district,
      ),
      context: 'fetching schools',
      mapper: (models) => models,
    );

    // Como o service ainda retorna List, vamos criar um PaginatedResult simples
    // TODO: Atualizar SchoolService para retornar dados paginados do backend
    return result.map((models) {
      final items = models.map((m) => m.toDomain()).toList();
      return PaginatedResult.fromOffset(
        items: items,
        total: items.length, // Temporário: não temos total do servidor
        offset: offset ?? 0,
        limit: limit ?? 50,
      );
    });
  }

  @override
  Future<Result<SchoolDetails>> getByCie(String cie) async {
    return executeRequest(
      request: () => _schoolService.getByCie(cie),
      context: 'fetching school by CIE',
      mapper: (e) => e.toDomain(),
    );
  }

  @override
  Future<Result<SchoolDetails>> getById(String id) async {
    return executeRequest(
      request: () => _schoolService.getById(id),
      context: 'fetching school by ID',
      mapper: (e) => e.toDomain(),
    );
  }

  @override
  Future<Result<SchoolDetails>> getByName(String name) async {
    return executeRequest(
      request: () => _schoolService.getByName(name),
      context: 'fetching school by name',
      mapper: (e) => e.toDomain(),
    );
  }

  @override
  Future<Result<SchoolDetails>> update(SchoolDetails school) async {
    return executeRequest(
      request: () => _schoolService.update(
        school.id, // ID como parâmetro separado no path
        SchoolDetailsModel.fromDomain(school),
      ),
      context: 'updating school',
      mapper: (e) => e.toDomain(),
    );
  }
}
