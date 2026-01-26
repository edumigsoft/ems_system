import 'package:core_shared/core_shared.dart'
    show Result, Unit, DataException, Failure, Success, successOfUnit;
import 'package:school_shared/school_shared.dart';
import '../queries/school_queries.dart';

/// Implementação do [SchoolRepository] para o servidor.
///
/// Gerencia dados de escolas via Drift.
class SchoolRepositoryServer implements SchoolRepository {
  final SchoolQueries _schoolQueries;

  SchoolRepositoryServer({required SchoolQueries schoolQueries})
    : _schoolQueries = schoolQueries;

  @override
  Future<Result<SchoolDetails>> create(SchoolCreate school) async {
    try {
      final result = await _schoolQueries.insertSchool(school);

      if (result == null) {
        return Failure(DataException('Falha ao criar escola'));
      }

      return Success(result);
    } on Exception catch (e) {
      return Failure(DataException(e.toString()));
    }
  }

  @override
  Future<Result<Unit>> delete(String id) async {
    try {
      await _schoolQueries.deleteSchool(id);

      return successOfUnit();
    } on Exception catch (e) {
      return Failure(DataException(e.toString()));
    }
  }

  @override
  Future<Result<List<SchoolDetails>>> getAll({int? limit, int? offset}) async {
    try {
      final result = await _schoolQueries.getAll(limit: limit, offset: offset);
      return Success(result);
    } on Exception catch (e) {
      return Failure(DataException(e.toString()));
    }
  }

  @override
  Future<Result<SchoolDetails>> getByCie(String cie) async {
    try {
      final result = await _schoolQueries.getByCie(cie);

      if (result == null) {
        return Failure(DataException('Escola não encontrada pelo CIE: $cie'));
      }

      return Success(result);
    } on Exception catch (e) {
      return Failure(DataException(e.toString()));
    }
  }

  @override
  Future<Result<SchoolDetails>> getById(String id) async {
    try {
      final result = await _schoolQueries.getById(id);

      if (result == null) {
        return Failure(DataException('Escola não encontrada pelo id: $id'));
      }

      return Success(result);
    } on Exception catch (e) {
      return Failure(DataException(e.toString()));
    }
  }

  @override
  Future<Result<SchoolDetails>> getByName(String name) async {
    try {
      final result = await _schoolQueries.getByName(name);

      if (result == null) {
        return Failure(DataException('Escola não encontrada pelo nome: $name'));
      }

      return Success(result);
    } on Exception catch (e) {
      return Failure(DataException(e.toString()));
    }
  }

  @override
  Future<Result<SchoolDetails>> update(SchoolDetails school) async {
    try {
      await _schoolQueries.updateSchool(school.id, school);

      return getById(school.id);
    } on Exception catch (e) {
      return Failure(DataException(e.toString()));
    }
  }
}
