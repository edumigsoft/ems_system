import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:auth_shared/auth_shared.dart';
import 'package:user_shared/user_shared.dart';

/// Storage seguro para tokens de autenticação.
///
/// Usa [FlutterSecureStorage] para armazenamento criptografado.
///
/// NOTA: Desde flutter_secure_storage 9.2.4+, todas as plataformas
/// (Android, iOS, Linux, Windows, macOS, Web) são suportadas automaticamente.
/// As opções específicas de plataforma são configuradas por quem instancia.
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _accessExpiresAtKey = 'access_expires_at';
  static const _rememberMeKey = 'remember_me';
  static const _userKey = 'user_details';

  final FlutterSecureStorage _storage;

  /// Cria uma instância de TokenStorage.
  ///
  /// [storage] - Opcional. Se não fornecido, usa configuração padrão
  /// que funciona em todas as plataformas (Android, iOS, Desktop, Web).
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  /// Salva um par de tokens.
  ///
  /// Se [rememberMe] for false, o refresh token não será armazenado,
  /// fazendo com que a sessão expire após o access token expirar.
  Future<void> saveTokens(
    TokenPair tokens, {
    required int expiresIn,
    bool rememberMe = true,
  }) async {
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    final writes = [
      _storage.write(key: _accessTokenKey, value: tokens.accessToken),
      _storage.write(
        key: _accessExpiresAtKey,
        value: expiresAt.toIso8601String(),
      ),
      _storage.write(key: _rememberMeKey, value: rememberMe.toString()),
    ];

    // Só salvar refresh token se rememberMe = true
    if (rememberMe) {
      writes.add(
        _storage.write(key: _refreshTokenKey, value: tokens.refreshToken),
      );
    } else {
      // Limpar refresh token antigo se existir
      writes.add(_storage.delete(key: _refreshTokenKey));
    }

    await Future.wait(writes);
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

  /// Recupera a preferência de "lembrar-me".
  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: _rememberMeKey);
    return value == 'true';
  }

  /// Salva os detalhes do usuário.
  Future<void> saveUser(UserDetails user) async {
    final userJson = jsonEncode(UserDetailsModel.fromDomain(user).toJson());
    await _storage.write(key: _userKey, value: userJson);
  }

  /// Recupera os detalhes do usuário.
  Future<UserDetails?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;

    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserDetailsModel.fromJson(map).toDomain();
    } catch (_) {
      await _storage.delete(key: _userKey);
      return null;
    }
  }

  /// Limpa todos os tokens e dados do usuário (logout).
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _accessExpiresAtKey),
      _storage.delete(key: _userKey),
    ]);
  }
}
