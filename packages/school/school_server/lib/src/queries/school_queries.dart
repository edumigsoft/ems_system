import 'package:core_shared/core_shared.dart' show EntityMapper;
import 'package:drift/drift.dart';
import 'package:school_shared/school_shared.dart';
import '../tables/school_table.dart';
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
            cie: result.cie,
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
            cie: result.cie,
          );

    return schoolDetails;
  }

  Future<SchoolDetails?> getByCie(String cie) async {
    final result = await (select(
      schoolTable,
    )..where((s) => s.cie.equals(cie))).getSingleOrNull();

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
            cie: result.cie,
          );

    return schoolDetails;
  }

  Future<List<SchoolDetails>> getAll({int? limit, int? offset}) async {
    final query = select(schoolTable);
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
          cie: row.cie,
        );
      },
    );

    return list;
  }

  Future<SchoolDetails?> insertSchool(SchoolCreate school) async {
    final companion = SchoolTableCompanion.insert(
      name: school.name,
      address: school.address,
      phone: school.phone,
      email: school.email,
      cie: school.cie,
      isActive: const Value(true),
      isDeleted: const Value(false),
    );

    await into(schoolTable).insert(companion);

    return getByCie(school.cie);
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
        cie: Value(school.cie),
      ),
    );
  }

  Future<void> deleteSchool(String id) {
    return (update(schoolTable)..where((s) => s.id.equals(id))).write(
      const SchoolTableCompanion(isDeleted: Value(true)),
    );
  }
}
