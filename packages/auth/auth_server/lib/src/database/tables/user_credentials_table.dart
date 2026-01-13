import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
import 'package:user_server/user_server.dart';

/// Tabela de credenciais de usuário.
///
/// Armazena dados sensíveis de autenticação separados da tabela [Users].
/// O password hash nunca é exposto na entity [UserDetails].
class UserCredentials extends Table with DriftTableMixinPostgres {
  /// FK para tabela users.
  TextColumn get userId => text().references(Users, #id)();

  /// Hash bcrypt da senha.
  TextColumn get passwordHash => text()();

  /// Data do último login bem-sucedido.
  @JsonKey('last_login_at')
  TextColumn get lastLoginAt =>
      text().map(const DateTimeConverterNonNull()).nullable()();

  /// Contador de tentativas de login falhas.
  @JsonKey('failed_attempts')
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();

  /// Data até quando a conta está bloqueada.
  @JsonKey('locked_until')
  TextColumn get lockedUntil =>
      text().map(const DateTimeConverterNonNull()).nullable()();
}
