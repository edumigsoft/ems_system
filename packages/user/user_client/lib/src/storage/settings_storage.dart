import 'dart:convert';
import 'package:core_shared/core_shared.dart'
    show
        Loggable,
        Unit,
        Result,
        successOfUnit,
        StorageException,
        Failure,
        Success;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user_shared/user_shared.dart' show UserSettings;

/// Secure storage for user settings.
///
/// Uses [FlutterSecureStorage] for encrypted storage of user preferences.
///
/// NOTA: Desde flutter_secure_storage 9.2.4+, todas as plataformas
/// (Android, iOS, Linux, Windows, macOS, Web) são suportadas automaticamente.
/// As opções específicas de plataforma são configuradas por quem instancia.
class SettingsStorage with Loggable {
  static const _settingsKey = 'user_settings';

  final FlutterSecureStorage _storage;

  /// Cria uma instância de SettingsStorage.
  ///
  /// [storage] - Opcional. Se não fornecido, usa configuração padrão
  /// que funciona em todas as plataformas (Android, iOS, Desktop, Web).
  SettingsStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  /// Saves user settings.
  ///
  /// Returns [Result<Unit>] indicating success or failure.
  Future<Result<Unit>> saveSettings(UserSettings settings) async {
    try {
      logger.info('Saving user settings: $settings');
      final json = jsonEncode(settings.toMap());
      await _storage.write(key: _settingsKey, value: json);
      logger.info('User settings saved successfully');
      return successOfUnit();
    } catch (e, stackTrace) {
      logger.severe('Failed to save user settings', e, stackTrace);
      return Failure(
        StorageException(
          'Failed to save user settings: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Loads user settings.
  ///
  /// Returns [Result<UserSettings>] with loaded settings or defaults if not found.
  Future<Result<UserSettings>> loadSettings() async {
    try {
      logger.info('Loading user settings');
      final json = await _storage.read(key: _settingsKey);

      if (json == null) {
        logger.info('No saved settings found, using defaults');
        return Success(UserSettings.defaultSettings);
      }

      final map = jsonDecode(json) as Map<String, dynamic>;
      final settings = UserSettings.fromMap(map);
      logger.info('User settings loaded: $settings');
      return Success(settings);
    } catch (e, stackTrace) {
      logger.warning(
        'Failed to load user settings, using defaults',
        e,
        stackTrace,
      );
      // Return defaults instead of failure to ensure app continues working
      return Success(UserSettings.defaultSettings);
    }
  }

  /// Clears saved user settings.
  ///
  /// Useful for logout or reset scenarios.
  Future<Result<Unit>> clearSettings() async {
    try {
      logger.info('Clearing user settings');
      await _storage.delete(key: _settingsKey);
      logger.info('User settings cleared successfully');
      return successOfUnit();
    } catch (e, stackTrace) {
      logger.severe('Failed to clear user settings', e, stackTrace);
      return Failure(
        StorageException(
          'Failed to clear user settings: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Checks if settings exist in storage.
  Future<bool> hasSettings() async {
    try {
      final json = await _storage.read(key: _settingsKey);
      return json != null;
    } catch (e) {
      logger.warning('Error checking for settings existence', e);
      return false;
    }
  }
}
