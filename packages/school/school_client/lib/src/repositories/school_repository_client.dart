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
        SchoolStatus,
        PaginatedResponse;

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
    final result =
        await executeRequest<
          PaginatedResponse<SchoolDetailsModel>,
          PaginatedResult<SchoolDetails>
        >(
          request: () => _schoolService.getAll(
            limit,
            offset,
            search,
            status?.name,
            city,
            district,
          ),
          context: 'fetching schools',
          mapper: (response) {
            final items = response.data.map((m) => m.toDomain()).toList();
            // Converter page para offset-based result
            final page = (offset ?? 0) ~/ (limit ?? 50) + 1;
            return PaginatedResult<SchoolDetails>(
              items: items,
              total: response.total,
              page: page,
              limit: response.limit,
            );
          },
        );

    return result;
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

  @override
  Future<Result<PaginatedResult<SchoolDetails>>> getDeleted({
    int? limit,
    int? offset,
    String? search,
    SchoolStatus? status,
    String? city,
    String? district,
  }) async {
    final result =
        await executeRequest<
          PaginatedResponse<SchoolDetailsModel>,
          PaginatedResult<SchoolDetails>
        >(
          request: () => _schoolService.getDeleted(
            limit,
            offset,
            search,
            status?.name,
            city,
            district,
          ),
          context: 'fetching deleted schools',
          mapper: (response) {
            final items = response.data.map((m) => m.toDomain()).toList();
            final page = (offset ?? 0) ~/ (limit ?? 50) + 1;
            return PaginatedResult<SchoolDetails>(
              items: items,
              total: response.total,
              page: page,
              limit: response.limit,
            );
          },
        );

    return result;
  }

  @override
  Future<Result<Unit>> restore(String id) async {
    return executeVoidRequest(
      request: () => _schoolService.restore(id),
      context: 'restoring school',
    );
  }
}
