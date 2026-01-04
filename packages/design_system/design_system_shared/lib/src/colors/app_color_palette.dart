import '../../design_system_shared.dart';

class AppColorPalette {
  // Definições de cores em valor puro
  static const primary = ColorValue(0xFF6200EE);
  static const secondary = ColorValue(0xFF03DAC6);
  static const error = ColorValue(0xFFB00020);
  static const background = ColorValue(0xFFFFFFFF);
  static const surface = ColorValue(0xFFFFFFFF);

  // Variações
  static const primaryLight = ColorValue(0xFF9A67EA);
  static const primaryDark = ColorValue(0xFF3700B3);

  // Card Light
  static ColorValue? cardBackgroundLight;
  static ColorValue? cardBorderLight;

  // Card Dark
  static ColorValue? cardBackgroundDark;
  static ColorValue? cardBorderDark;
}
