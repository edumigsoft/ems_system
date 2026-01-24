/// Constants for tag validation and business rules.
class TagConstants {
  TagConstants._(); // Private constructor to prevent instantiation

  /// Minimum length for tag name.
  static const int minNameLength = 1;

  /// Maximum length for tag name.
  static const int maxNameLength = 50;

  /// Maximum length for tag description.
  static const int maxDescriptionLength = 200;

  /// Regex pattern for valid hex color codes.
  /// Supports: #RGB, #RRGGBB, #RRGGBBAA
  static const String hexColorPattern = r'^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$';
}
