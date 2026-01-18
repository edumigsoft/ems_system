import 'package:drift/drift.dart';
import 'package:ems_system_core_server/core_server.dart'
    show DriftTableMixinPostgres, DateTimeConverterNonNull;

/// Tabela de refresh tokens.
///
/// Armazena tokens de refresh para implementar rotation e revogação.
class RefreshTokens extends Table with DriftTableMixinPostgres {
  /// FK para tabela users.
  TextColumn get userId => text()();

  /// Hash do refresh token (nunca armazenar token raw).
  TextColumn get tokenHash => text()();

  /// Data de expiração do token.
  @JsonKey('expires_at')
  TextColumn get expiresAt => text().map(const DateTimeConverterNonNull())();

  /// Data de revogação (null se não revogado).
  @JsonKey('revoked_at')
  TextColumn get revokedAt =>
      text().map(const DateTimeConverterNonNull()).nullable()();

  /// Motivo da revogação.
  @JsonKey('revoke_reason')
  TextColumn get revokeReason => text().nullable()();

  /// IP de origem da requisição.
  @JsonKey('client_ip')
  TextColumn get clientIp => text().nullable()();

  /// User agent da requisição.
  @JsonKey('user_agent')
  TextColumn get userAgent => text().nullable()();
}
