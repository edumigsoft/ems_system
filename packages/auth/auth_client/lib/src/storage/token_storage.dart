import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:auth_shared/auth_shared.dart';

/// Storage seguro para tokens de autenticação.
///
/// Usa [FlutterSecureStorage] para armazenamento criptografado.
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _accessExpiresAtKey = 'access_expires_at';

  final FlutterSecureStorage _storage;

  TokenStorage([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  /// Salva um par de tokens.
  Future<void> saveTokens(TokenPair tokens, {required int expiresIn}) async {
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    await Future.wait([
      _storage.write(key: _accessTokenKey, value: tokens.accessToken),
      _storage.write(key: _refreshTokenKey, value: tokens.refreshToken),
      _storage.write(
        key: _accessExpiresAtKey,
        value: expiresAt.toIso8601String(),
      ),
    ]);
  }

  /// Recupera o access token.
  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  /// Recupera o refresh token.
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  /// Verifica se existe um token válido.
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    if (token == null) return false;

    final expiresAtStr = await _storage.read(key: _accessExpiresAtKey);
    if (expiresAtStr == null) return false;

    final expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null) return false;

    return DateTime.now().isBefore(expiresAt);
  }

  /// Verifica se o token vai expirar em breve.
  Future<bool> tokenExpiresWithin(Duration duration) async {
    final expiresAtStr = await _storage.read(key: _accessExpiresAtKey);
    if (expiresAtStr == null) return true;

    final expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null) return true;

    return DateTime.now().add(duration).isAfter(expiresAt);
  }

  /// Limpa todos os tokens (logout).
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _accessExpiresAtKey),
    ]);
  }
}
