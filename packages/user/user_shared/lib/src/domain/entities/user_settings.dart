/// User settings entity.
///
/// Represents user preferences and configuration.
/// Follows the pattern of being a pure Dart PODO for cross-platform use.
class UserSettings {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool darkMode;
  final String language;
  final String theme;

  const UserSettings({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.darkMode = false,
    this.language = 'pt_BR',
    this.theme = 'acqua',
  });

  /// Default settings instance.
  static const UserSettings defaultSettings = UserSettings();

  /// Serialization to Map for storage.
  Map<String, dynamic> toMap() => {
    'notifications_enabled': notificationsEnabled,
    'email_notifications': emailNotifications,
    'push_notifications': pushNotifications,
    'dark_mode': darkMode,
    'language': language,
    'theme': theme,
  };

  /// Deserialization from Map.
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      notificationsEnabled: map['notifications_enabled'] as bool? ?? true,
      emailNotifications: map['email_notifications'] as bool? ?? true,
      pushNotifications: map['push_notifications'] as bool? ?? true,
      darkMode: map['dark_mode'] as bool? ?? false,
      language: map['language'] as String? ?? 'pt_BR',
      theme: map['theme'] as String? ?? 'acqua',
    );
  }

  /// Creates a copy with specified fields changed.
  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? darkMode,
    String? language,
    String? theme,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          runtimeType == other.runtimeType &&
          notificationsEnabled == other.notificationsEnabled &&
          emailNotifications == other.emailNotifications &&
          pushNotifications == other.pushNotifications &&
          darkMode == other.darkMode &&
          language == other.language &&
          theme == other.theme;

  @override
  int get hashCode =>
      notificationsEnabled.hashCode ^
      emailNotifications.hashCode ^
      pushNotifications.hashCode ^
      darkMode.hashCode ^
      language.hashCode ^
      theme.hashCode;

  @override
  String toString() =>
      'UserSettings(notifications: $notificationsEnabled, '
      'email: $emailNotifications, push: $pushNotifications, '
      'darkMode: $darkMode, language: $language, theme: $theme)';
}
