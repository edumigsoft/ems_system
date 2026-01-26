import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart' show DriftTableMixinPostgres;
import 'package:school_shared/school_shared.dart' show SchoolDetails;

@UseRowClass(SchoolDetails)
class SchoolTable extends Table with DriftTableMixinPostgres {
  @override
  String get tableName => 'schools';

  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().unique()();
  TextColumn get cie => text().unique()();
}
