import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart' show DriftTableMixinPostgres;
import 'package:school_shared/school_shared.dart' show SchoolDetails;

import '../converters/school_status_converter.dart';

@UseRowClass(SchoolDetails, constructor: 'create')
class SchoolTable extends Table with DriftTableMixinPostgres {
  @override
  String get tableName => 'schools';

  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().unique()();
  TextColumn get code => text().unique()(); // CIE
  @JsonKey('location_city')
  TextColumn get locationCity => text()();
  @JsonKey('location_district')
  TextColumn get locationDistrict => text()();
  TextColumn get director => text()();
  TextColumn get status => text()
      .map(const SchoolStatusConverter())
      .withDefault(const Constant('active'))();
}
