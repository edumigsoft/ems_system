import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart' show DriftTableMixinPostgres;
import 'package:book_shared/book_shared.dart' show BookDetails;

/// Tabela Drift para Book.
@UseRowClass(BookDetails)
class BookTable extends Table with DriftTableMixinPostgres {
  @override
  String get tableName => 'books';
  
  TextColumn get title => text()();
  TextColumn get isbn => text()();
  IntColumn get publishYear => integer()();}
