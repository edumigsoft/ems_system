import 'package:flutter/material.dart';

/// Extension para facilitar o acesso ao tema do Design System
extension DSThemeExtension on BuildContext {
  ThemeData get dsTheme => Theme.of(this);
  ColorScheme get dsColors => Theme.of(this).colorScheme;
  TextTheme get dsTextStyles => Theme.of(this).textTheme;
  CardThemeData get dsCardTheme => Theme.of(this).cardTheme;
}
