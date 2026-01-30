import 'package:core_shared/core_shared.dart' show EntityMapper;
import 'package:drift/drift.dart';
import 'package:school_shared/school_shared.dart'
    show SchoolCreate, SchoolDetails, SchoolStatus;
import '../database/tables/school_table.dart';
import '../database/school_database.dart';

part 'school_queries.g.dart';

@DriftAccessor(tables: [SchoolTable])
class SchoolQueries extends DatabaseAccessor<SchoolDatabase>
    with _$SchoolQueriesMixin {
  SchoolQueries(super.db);

  Future<SchoolDetails?> getById(String id) async {
    final result = await (select(
      schoolTable,
    )..where((s) => s.id.equals(id))).getSingleOrNull();

    final schoolDetails = result == null
        ? null
        : SchoolDetails(
            id: result.id,
            isDeleted: result.isDeleted,
            isActive: result.isActive,
            createdAt: result.createdAt,
            updatedAt: result.updatedAt,
            name: result.name,
            address: result.address,
            phone: result.phone,
            email: result.email,
            code: result.code,
            locationCity: result.locationCity,
            locationDistrict: result.locationDistrict,
            director: result.director,
            status: result.status,
          );

    return schoolDetails;
  }

  Future<SchoolDetails?> getByName(String name) async {
    final result = await (select(
      schoolTable,
    )..where((s) => s.name.equals(name))).getSingleOrNull();

    final schoolDetails = result == null
        ? null
        : SchoolDetails(
            id: result.id,
            isDeleted: result.isDeleted,
            isActive: result.isActive,
            createdAt: result.createdAt,
            updatedAt: result.updatedAt,
            name: result.name,
            address: result.address,
            phone: result.phone,
            email: result.email,
            code: result.code,
            locationCity: result.locationCity,
            locationDistrict: result.locationDistrict,
            director: result.director,
            status: result.status,
          );

    return schoolDetails;
  }

  Future<SchoolDetails?> getByCode(String code) async {
    final result = await (select(
      schoolTable,
    )..where((s) => s.code.equals(code))).getSingleOrNull();

    final schoolDetails = result == null
        ? null
        : SchoolDetails(
            id: result.id,
            isDeleted: result.isDeleted,
            isActive: result.isActive,
            createdAt: result.createdAt,
            updatedAt: result.updatedAt,
            name: result.name,
            address: result.address,
            phone: result.phone,
            email: result.email,
            code: result.code,
            locationCity: result.locationCity,
            locationDistrict: result.locationDistrict,
            director: result.director,
            status: result.status,
          );

    return schoolDetails;
  }

  Future<List<SchoolDetails>> getAll({
    int? limit,
    int? offset,
    String? search,
    SchoolStatus? status,
    String? city,
    String? district,
  }) async {
    final query = select(schoolTable);

    // Sempre excluir deletados
    query.where((t) => t.isDeleted.equals(0));

    // Filtro de busca textual (nome, código, diretor)
    if (search != null && search.isNotEmpty) {
      query.where(
        (t) =>
            t.name.contains(search) |
            t.code.contains(search) |
            t.director.contains(search) |
            t.locationCity.contains(search),
      );
    }

    // Filtro por status
    if (status != null) {
      query.where((t) => t.status.equals(status.name));
    }

    // Filtro por cidade
    if (city != null && city.isNotEmpty) {
      query.where((t) => t.locationCity.contains(city));
    }

    // Filtro por distrito
    if (district != null && district.isNotEmpty) {
      query.where((t) => t.locationDistrict.contains(district));
    }

    // Ordenação por nome
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);

    // Aplicar paginação
    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    final result = await query.get();

    final list = EntityMapper.mapList(
      models: result,
      mapper: (row) {
        return SchoolDetails(
          id: row.id,
          isDeleted: row.isDeleted,
          isActive: row.isActive,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          name: row.name,
          address: row.address,
          phone: row.phone,
          email: row.email,
          code: row.code,
          locationCity: row.locationCity,
          locationDistrict: row.locationDistrict,
          director: row.director,
          status: row.status,
        );
      },
    );

    return list;
  }

  /// Conta o total de escolas com filtros aplicados.
  Future<int> getTotalCount({
    String? search,
    SchoolStatus? status,
    String? city,
    String? district,
  }) async {
    final query = selectOnly(schoolTable);

    // Sempre excluir deletados
    query.where(schoolTable.isDeleted.equals(0));

    // Filtro de busca textual
    if (search != null && search.isNotEmpty) {
      query.where(
        schoolTable.name.contains(search) |
            schoolTable.code.contains(search) |
            schoolTable.director.contains(search) |
            schoolTable.locationCity.contains(search),
      );
    }

    // Filtro por status
    if (status != null) {
      query.where(schoolTable.status.equals(status.name));
    }

    // Filtro por cidade
    if (city != null && city.isNotEmpty) {
      query.where(schoolTable.locationCity.contains(city));
    }

    // Filtro por distrito
    if (district != null && district.isNotEmpty) {
      query.where(schoolTable.locationDistrict.contains(district));
    }

    query.addColumns([schoolTable.id.count()]);

    final result = await query.getSingle();
    return result.read(schoolTable.id.count()) ?? 0;
  }

  Future<SchoolDetails?> insertSchool(SchoolCreate school) async {
    final companion = SchoolTableCompanion.insert(
      name: school.name,
      address: school.address,
      phone: school.phone,
      email: school.email,
      code: school.code,
      locationCity: school.locationCity,
      locationDistrict: school.locationDistrict,
      director: school.director,
      status: Value(school.status),
      isActive: const Value(true),
      isDeleted: const Value(false),
    );

    await into(schoolTable).insert(companion);

    return getByCode(school.code);
  }

  Future<void> updateSchool(String id, SchoolDetails school) {
    return (update(schoolTable)..where((s) => s.id.equals(id))).write(
      SchoolTableCompanion(
        isDeleted: Value(school.isDeleted),
        isActive: Value(school.isActive),
        name: Value(school.name),
        address: Value(school.address),
        phone: Value(school.phone),
        email: Value(school.email),
        code: Value(school.code),
        locationCity: Value(school.locationCity),
        locationDistrict: Value(school.locationDistrict),
        director: Value(school.director),
        status: Value(school.status),
      ),
    );
  }

  Future<void> deleteSchool(String id) {
    return (update(schoolTable)..where((s) => s.id.equals(id))).write(
      const SchoolTableCompanion(isDeleted: Value(true)),
    );
  }

  /// Busca todas as escolas deletadas (soft delete).
  ///
  /// Retorna apenas escolas com `isDeleted = true`.
  /// Suporta paginação e filtros similares ao método getAll().
  Future<List<SchoolDetails>> getDeleted({
    int? limit,
    int? offset,
    String? search,
    SchoolStatus? status,
    String? city,
    String? district,
  }) async {
    final query = select(schoolTable);

    // Filtrar apenas deletados
    query.where((t) => t.isDeleted.equals(1));

    // Filtro de busca textual (nome, código, diretor)
    if (search != null && search.isNotEmpty) {
      query.where(
        (t) =>
            t.name.contains(search) |
            t.code.contains(search) |
            t.director.contains(search) |
            t.locationCity.contains(search),
      );
    }

    // Filtro por status
    if (status != null) {
      query.where((t) => t.status.equals(status.name));
    }

    // Filtro por cidade
    if (city != null && city.isNotEmpty) {
      query.where((t) => t.locationCity.contains(city));
    }

    // Filtro por distrito
    if (district != null && district.isNotEmpty) {
      query.where((t) => t.locationDistrict.contains(district));
    }

    // Ordenação por nome
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);

    // Aplicar paginação
    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    final result = await query.get();

    final list = EntityMapper.mapList(
      models: result,
      mapper: (row) {
        return SchoolDetails(
          id: row.id,
          isDeleted: row.isDeleted,
          isActive: row.isActive,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          name: row.name,
          address: row.address,
          phone: row.phone,
          email: row.email,
          code: row.code,
          locationCity: row.locationCity,
          locationDistrict: row.locationDistrict,
          director: row.director,
          status: row.status,
        );
      },
    );

    return list;
  }

  /// Conta o total de escolas deletadas com filtros aplicados.
  Future<int> getDeletedCount({
    String? search,
    SchoolStatus? status,
    String? city,
    String? district,
  }) async {
    final query = selectOnly(schoolTable);

    // Filtrar apenas deletados
    query.where(schoolTable.isDeleted.equals(1));

    // Filtro de busca textual
    if (search != null && search.isNotEmpty) {
      query.where(
        schoolTable.name.contains(search) |
            schoolTable.code.contains(search) |
            schoolTable.director.contains(search) |
            schoolTable.locationCity.contains(search),
      );
    }

    // Filtro por status
    if (status != null) {
      query.where(schoolTable.status.equals(status.name));
    }

    // Filtro por cidade
    if (city != null && city.isNotEmpty) {
      query.where(schoolTable.locationCity.contains(city));
    }

    // Filtro por distrito
    if (district != null && district.isNotEmpty) {
      query.where(schoolTable.locationDistrict.contains(district));
    }

    query.addColumns([schoolTable.id.count()]);

    final result = await query.getSingle();
    return result.read(schoolTable.id.count()) ?? 0;
  }
}
