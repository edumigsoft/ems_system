import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
import 'package:school_shared/school_shared.dart' show SchoolDetails;
import '../tables/school_table.dart';

part 'school_database.g.dart';

@DriftDatabase(tables: [SchoolTable])
class SchoolDatabase extends _$SchoolDatabase {
  SchoolDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
