import 'package:core_shared/core_shared.dart' show UserRole;
import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
import '../../user_server.dart' show UserRoleConverter;
import 'package:user_shared/user_shared.dart' show UserDetails;
import 'tables/users_table.dart';

part 'user_database.g.dart';

/// Banco de dados modular para Usuários.
@DriftDatabase(tables: [Users])
class UserDatabase extends _$UserDatabase {
  UserDatabase(super.e);

  @override
  int get schemaVersion => 1;

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
