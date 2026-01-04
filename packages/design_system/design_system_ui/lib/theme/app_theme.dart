import 'package:flutter/material.dart';
import 'package:design_system_shared/design_system_shared.dart';

import '../colors/app_colors.dart';
import '../colors/color_extensions.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),
      fontFamily: 'Roboto',
      // ... outras configurações
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme.dark(
        primary: AppColorPalette.primaryLight.toFlutterColor(),
        // ...
      ),
    );
  }
}
