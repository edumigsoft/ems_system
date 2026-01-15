import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
import 'package:auth_shared/auth_shared.dart';
import 'tables/user_credentials_table.dart';
import 'tables/refresh_tokens_table.dart';
import 'tables/project_user_role_table.dart';
import 'converters/feature_user_role_converter.dart';

part 'auth_database.g.dart';

/// Banco de dados modular para Autenticação.
@DriftDatabase(tables: [UserCredentials, RefreshTokens, ProjectUserRoles])
class AuthDatabase extends _$AuthDatabase {
  AuthDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Criar nova tabela project_user_roles
        await m.createTable(projectUserRoles);

        // Nota: ResourceMembers será removida em um passo posterior
        // após confirmar que a migração funciona corretamente
      }
    },
  );

  /// Garante que as tabelas do módulo existam.
  Future<void> init() async {
    final m = createMigrator();
    for (final table in allTables) {
      try {
        await m.createTable(table);
      } catch (e) {
        // Ignora erro se a tabela já existe (Postgres error 42P07 ou mensagem similar)
        if (!e.toString().contains('already exists') &&
            !e.toString().contains('42P07')) {
          rethrow;
        }
      }
    }
  }
}
