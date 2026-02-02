import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
import 'package:school_shared/school_shared.dart'
    show SchoolDetails, SchoolStatus;
import 'tables/school_table.dart';
import 'converters/school_status_converter.dart';

part 'school_database.g.dart';

@DriftDatabase(tables: [SchoolTable])
class SchoolDatabase extends _$SchoolDatabase {
  SchoolDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from == 1) {
          // await migrator.addColumn(schoolTable, schoolTable.mustChangePassword);
        }
      },
    );
  }

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
