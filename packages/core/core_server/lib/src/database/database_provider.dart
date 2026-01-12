import 'package:drift_postgres/drift_postgres.dart';
import 'package:drift/drift.dart';
import 'package:postgres/postgres.dart';

/// Provedor de conexão com banco de dados PostgreSQL.
///
/// Singleton que gerencia a conexão com o banco via Drift.
/// Deve ser inicializado com connect() antes do uso.
class DatabaseProvider {
  // Singleton
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  factory DatabaseProvider() => _instance;
  DatabaseProvider._internal();

  QueryExecutor? _executor;

  Future<void> connect({
    required String host,
    required int port,
    required String name,
    required String user,
    required String password,
    bool useSsl = false,
  }) async {
    if (_executor != null) return;

    _executor = PgDatabase(
      endpoint: Endpoint(
        host: host,
        port: port,
        database: name,
        username: user,
        password: password,
      ),
      settings: ConnectionSettings(
        sslMode: useSsl ? SslMode.require : SslMode.disable,
      ),
    );
  }

  // Os módulos vão consumir este executor
  /// Executor de queries do banco de dados.
  ///
  /// Lça exceção se o banco não foi inicializado. Chame connect() primeiro.
  QueryExecutor get executor {
    if (_executor == null) {
      throw Exception("Database not initialized. Call connect() first.");
    }
    return _executor!;
  }
}
