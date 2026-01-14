import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
import 'tables/user_credentials_table.dart';
import 'tables/refresh_tokens_table.dart';
import 'tables/resource_members_table.dart';

part 'auth_database.g.dart';

/// Banco de dados modular para Autenticação.
@DriftDatabase(tables: [UserCredentials, RefreshTokens, ResourceMembers])
class AuthDatabase extends _$AuthDatabase {
  AuthDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
