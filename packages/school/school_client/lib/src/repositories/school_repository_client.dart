import 'package:core_client/core_client.dart'
    show BaseRepositoryLocal, Result, Unit;
import 'package:school_shared/school_shared.dart'
    show
        SchoolRepository,
        SchoolCreate,
        SchoolDetails,
        SchoolCreateModel,
        SchoolDetailsModel;

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
  Future<Result<List<SchoolDetails>>> getAll({int? limit, int? offset}) async {
    final result = await executeRequest(
      request: () => _schoolService.getAll(limit, offset),
      context: 'fetching schools',
      mapper: (models) => models, // Temporary, will map below
    );

    // Manual mapping since executeRequest expects single T -> T
    // But mapList logic is often handled inside executeRequest if generic T is List.
    // However, BaseRepositoryLocal usually has T, and mapper T -> T.
    // If T is List<SchoolDetails>, mapper must convert List<Model> to List<Entity>.

    return result.map(
      (models) => models.map((m) => m.toDomain()).toList(),
    );
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
