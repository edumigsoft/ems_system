import 'package:flutter/material.dart';

/// Extension para facilitar o acesso ao tema do Design System
extension DSThemeExtension on BuildContext {
  /// Obtém o ThemeData atual
  ThemeData get dsTheme => Theme.of(this);

  /// Obtém o ColorScheme atual
  ColorScheme get dsColors => Theme.of(this).colorScheme;

  /// Obtém o TextTheme atual
  TextTheme get dsTextStyles => Theme.of(this).textTheme;

  /// Obtém o CardTheme atual
  CardThemeData get dsCardTheme => Theme.of(this).cardTheme;
}
