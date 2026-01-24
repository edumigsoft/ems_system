import 'package:core_server/core_server.dart'
    show BooleanConverter, DateTimeConverterNonNull;
import 'package:drift/drift.dart';
import 'package:tag_shared/tag_shared.dart' show TagDetails;

import 'tables/tag_table.dart';

part 'tag_database.g.dart';

/// Banco de dados modular para Tags.
@DriftDatabase(tables: [TagTable])
class TagDatabase extends _$TagDatabase {
  TagDatabase(super.e);

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
