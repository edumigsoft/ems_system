import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart';
import 'package:user_shared/user_shared.dart';
import 'package:user_client/user_client.dart';
import 'package:auth_client/auth_client.dart';

/// ViewModel para gerenciar configurações do usuário.
///
/// Gerencia preferências locais e configurações de perfil.
class SettingsViewModel extends ChangeNotifier with Loggable {
  final SettingsStorage _storage;
  final AuthService _authService;

  SettingsViewModel({
    required SettingsStorage storage,
    required AuthService authService,
  }) : _storage = storage,
       _authService = authService;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  bool _emailNotifications = true;
  bool get emailNotifications => _emailNotifications;

  bool _pushNotifications = true;
  bool get pushNotifications => _pushNotifications;

  bool _darkMode = false;
  bool get darkMode => _darkMode;

  String _language = 'pt_BR';
  String get language => _language;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _passwordChangeError;
  String? get passwordChangeError => _passwordChangeError;

  bool _isChangingPassword = false;
  bool get isChangingPassword => _isChangingPassword;

  /// Alterna notificações gerais.
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
    _autoSave();
  }

  /// Alterna notificações por email.
  void toggleEmailNotifications(bool value) {
    _emailNotifications = value;
    notifyListeners();
    _autoSave();
  }

  /// Alterna notificações push.
  void togglePushNotifications(bool value) {
    _pushNotifications = value;
    notifyListeners();
    _autoSave();
  }

  /// Alterna modo escuro.
  void toggleDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
    _autoSave();
  }

  /// Define idioma.
  void setLanguage(String languageCode) {
    _language = languageCode;
    notifyListeners();
    _autoSave();
  }

  /// Auto-save after changes (fire-and-forget).
  void _autoSave() {
    saveSettings();
  }

  /// Carrega configurações salvas.
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    logger.info('Loading settings...');
    final result = await _storage.loadSettings();

    result.when(
      success: (settings) {
        _notificationsEnabled = settings.notificationsEnabled;
        _emailNotifications = settings.emailNotifications;
        _pushNotifications = settings.pushNotifications;
        _darkMode = settings.darkMode;
        _language = settings.language;
        logger.info('Settings loaded successfully');
      },
      failure: (error) {
        // Should not happen as loadSettings returns defaults on error
        logger.warning('Failed to load settings: $error');
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Salva configurações.
  Future<bool> saveSettings() async {
    final settings = UserSettings(
      notificationsEnabled: _notificationsEnabled,
      emailNotifications: _emailNotifications,
      pushNotifications: _pushNotifications,
      darkMode: _darkMode,
      language: _language,
    );

    logger.info('Saving settings...');
    final result = await _storage.saveSettings(settings);

    return result.when(
      success: (_) {
        logger.info('Settings saved successfully');
        return true;
      },
      failure: (error) {
        logger.severe('Failed to save settings: $error');
        return false;
      },
    );
  }

  /// Reseta configurações para os valores padrão.
  Future<void> resetSettings() async {
    final defaults = UserSettings.defaultSettings;
    _notificationsEnabled = defaults.notificationsEnabled;
    _emailNotifications = defaults.emailNotifications;
    _pushNotifications = defaults.pushNotifications;
    _darkMode = defaults.darkMode;
    _language = defaults.language;
    notifyListeners();
    await saveSettings();
  }

  /// Muda a senha do usuário.
  ///
  /// Retorna mensagem de erro se falhar, null se sucesso.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isChangingPassword = true;
    _passwordChangeError = null;
    notifyListeners();

    logger.info('Changing password...');

    // Validação client-side
    if (currentPassword.isEmpty) {
      _passwordChangeError = 'Senha atual é obrigatória';
      _isChangingPassword = false;
      notifyListeners();
      return _passwordChangeError;
    }

    if (newPassword.length < 8) {
      _passwordChangeError = 'Nova senha deve ter no mínimo 8 caracteres';
      _isChangingPassword = false;
      notifyListeners();
      return _passwordChangeError;
    }

    if (newPassword != confirmPassword) {
      _passwordChangeError = 'As senhas não coincidem';
      _isChangingPassword = false;
      notifyListeners();
      return _passwordChangeError;
    }

    final result = await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    _isChangingPassword = false;

    result.when(
      success: (_) {
        logger.info('Password changed successfully');
        _passwordChangeError = null;
      },
      failure: (error) {
        logger.severe('Failed to change password: $error');
        _passwordChangeError = error.toString().replaceAll('Exception: ', '');
      },
    );

    notifyListeners();
    return _passwordChangeError;
  }
}
