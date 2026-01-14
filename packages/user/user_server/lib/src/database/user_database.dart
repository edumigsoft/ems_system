import 'package:core_shared/core_shared.dart' show UserRole;
import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
import 'package:user_server/user_server.dart' show UserRoleConverter;
import 'package:user_shared/user_shared.dart' show UserDetails;
import 'tables/users_table.dart';

part 'user_database.g.dart';

/// Banco de dados modular para Usuários.
@DriftDatabase(tables: [Users])
class UserDatabase extends _$UserDatabase {
  UserDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
