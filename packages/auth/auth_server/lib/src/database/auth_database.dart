import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart'
    show BooleanConverter, DateTimeConverterNonNull;

import 'tables/refresh_tokens_table.dart';
import 'tables/user_credentials_table.dart';

part 'auth_database.g.dart';

/// Banco de dados modular para Autenticação.
@DriftDatabase(tables: [UserCredentials, RefreshTokens])
class AuthDatabase extends _$AuthDatabase {
  AuthDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
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
