import '../../design_system_shared.dart';

class AppThemeData {
  final AppColorPalette colors;
  final String fontFamily;
  final double baseFontSize;

  const AppThemeData({
    required this.colors,
    this.fontFamily = 'Roboto',
    this.baseFontSize = 14.0,
  });
}
