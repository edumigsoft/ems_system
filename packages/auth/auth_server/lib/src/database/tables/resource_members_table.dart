import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
// import 'package:user_server/user_server.dart';

/// Tabela de membros de recursos (RBAC genérico).
class ResourceMembers extends Table with DriftTableMixinPostgres {
  TextColumn get userId => text()();

  @JsonKey('resource_type')
  TextColumn get resourceType => text()();

  @JsonKey('resource_id')
  TextColumn get resourceId => text()();

  TextColumn get permission => text()();
}
