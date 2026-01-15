import 'package:drift/drift.dart';

import '../database/auth_database.dart';
import '../database/tables/refresh_tokens_table.dart';
import '../database/tables/user_credentials_table.dart';

part 'auth_repository.g.dart';

/// Repository para gestão de credenciais e tokens.
@DriftAccessor(tables: [UserCredentials, RefreshTokens])
class AuthRepository extends DatabaseAccessor<AuthDatabase>
    with _$AuthRepositoryMixin {
  AuthRepository(super.db);

  /// Busca credenciais por userId.
  Future<UserCredential?> getCredentials(String userId) {
    return (select(
      userCredentials,
    )..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();
  }

  /// Cria ou atualiza credenciais.
  Future<void> saveCredentials(UserCredentialsCompanion credentials) async {
    await into(userCredentials).insertOnConflictUpdate(credentials);
  }

  /// Salva um refresh token.
  Future<void> saveRefreshToken(RefreshTokensCompanion token) async {
    await into(refreshTokens).insert(token);
  }

  /// Busca um refresh token válido (não revogado e não expirado).
  Future<RefreshToken?> getRefreshToken(String token) {
    return (select(refreshTokens)
          ..where((tbl) => tbl.tokenHash.equals(token))
          ..where((tbl) => tbl.revokedAt.isNull())
          ..where(
            (tbl) => tbl.expiresAt.isBiggerThanValue(
              DateTime.now().toIso8601String(),
            ),
          ))
        .getSingleOrNull();
  }

  /// Revoga um refresh token específico.
  Future<void> revokeRefreshToken(String token) async {
    await (update(refreshTokens)..where((tbl) => tbl.tokenHash.equals(token)))
        .write(RefreshTokensCompanion(revokedAt: Value(DateTime.now())));
  }

  /// Revoga todos os refresh tokens de um usuário.
  Future<void> revokeAllRefreshTokens(String userId) async {
    await (update(refreshTokens)..where((tbl) => tbl.userId.equals(userId)))
        .write(RefreshTokensCompanion(revokedAt: Value(DateTime.now())));
  }

  /// Revoga todos os refresh tokens de um usuário, exceto o token especificado.
  ///
  /// Usado na mudança de senha para invalidar outras sessões mas manter
  /// a sessão atual ativa.
  Future<void> revokeAllRefreshTokensExcept(
    String userId,
    String? currentToken,
  ) async {
    final query = update(refreshTokens)
      ..where((tbl) => tbl.userId.equals(userId));

    // Se há token atual, exclui da revogação
    if (currentToken != null) {
      query.where((tbl) => tbl.tokenHash.equals(currentToken).not());
    }

    await query.write(RefreshTokensCompanion(revokedAt: Value(DateTime.now())));
  }

  /// Registra tentativa de login falha.
  Future<void> incrementFailedAttempts(String userId) async {
    // Nota: Lógica simplificada, idealmente seria transacional com verificação de lockout
    final creds = await getCredentials(userId);
    if (creds != null) {
      final attempts = creds.failedAttempts + 1;
      await (update(userCredentials)..where((tbl) => tbl.userId.equals(userId)))
          .write(UserCredentialsCompanion(failedAttempts: Value(attempts)));
    }
  }

  /// Reseta tentativas de login falhas.
  Future<void> resetFailedAttempts(String userId) async {
    await (update(
      userCredentials,
    )..where((tbl) => tbl.userId.equals(userId))).write(
      const UserCredentialsCompanion(
        failedAttempts: Value(0),
        lockedUntil: Value(null),
      ),
    );
  }

  /// Atualiza a senha do usuário.
  Future<void> updatePassword(String userId, String passwordHash) async {
    await (update(userCredentials)..where((tbl) => tbl.userId.equals(userId)))
        .write(UserCredentialsCompanion(passwordHash: Value(passwordHash)));
  }

  /// Atualiza o último login.
  Future<void> updateLastLogin(String userId) async {
    await (update(userCredentials)..where((tbl) => tbl.userId.equals(userId)))
        .write(UserCredentialsCompanion(lastLoginAt: Value(DateTime.now())));
  }
}
