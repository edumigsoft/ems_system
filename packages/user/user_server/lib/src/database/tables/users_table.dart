import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
import 'package:user_shared/user_shared.dart';

import '../converters/user_role_converter.dart';

/// Tabela de usuários do sistema.
///
/// Usa [DriftTableMixinPostgres] para campos padrão (id, createdAt, updatedAt, etc.)
/// e [@UseRowClass] para integração direta com [UserDetails] do domínio.
///
/// Vantagens do @UseRowClass sobre @DataClassName:
/// - Evita duplicação de classes (não gera classe separada)
/// - Integração direta com a entity de domínio
/// - Drift popula UserDetails automaticamente
@UseRowClass(UserDetails, constructor: 'create')
class Users extends Table with DriftTableMixinPostgres {
  /// Email do usuário (único).
  TextColumn get email => text().unique()();

  /// Nome completo do usuário.
  TextColumn get name => text()();

  /// Username para identificação pública (único).
  TextColumn get username => text().unique()();

  /// Role global do usuário no sistema.
  TextColumn get role => text()
      .map(const UserRoleConverter())
      .withDefault(const Constant('user'))();

  /// Indica se o email foi verificado.
  @JsonKey('email_verified')
  BoolColumn get emailVerified =>
      boolean().withDefault(const Constant(false))();

  /// URL do avatar do usuário.
  @JsonKey('avatar_url')
  TextColumn get avatarUrl => text().nullable()();

  /// Número de telefone do usuário.
  TextColumn get phone => text().nullable()();
}
