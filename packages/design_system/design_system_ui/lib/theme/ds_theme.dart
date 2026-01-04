import 'package:flutter/material.dart';
import 'package:design_system_shared/design_system_shared.dart';
import '../colors/color_extensions.dart';

/// Gerenciador de temas do Design System
///
/// Prefixo: DS (Design System)
class DSTheme {
  /// Cria um ThemeData a partir de uma configuração personalizada
  static ThemeData fromConfig({
    required AppThemeConfig config,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: config.seedColor.toColor(),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: config.useMaterial3,
      colorScheme: colorScheme,
      brightness: brightness,

      // ========== Card Theme ==========
      cardTheme: CardThemeData(
        color: config.cardBackground?.toColor(),
        elevation: config.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardBorderRadius),
          side: config.cardBorder != null
              ? BorderSide(
                  color: config.cardBorder!.toColor(),
                  width: 1.0,
                )
              : BorderSide.none,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      ),

      // ========== AppBar Theme ==========
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      ),

      // ========== Button Themes ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: config.cardElevation,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.cardBorderRadius / 2),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.cardBorderRadius / 2),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.cardBorderRadius / 2),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.cardBorderRadius / 2),
          ),
        ),
      ),

      // ========== Input Decoration Theme ==========
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.cardBorderRadius / 2),
        ),
        filled: true,
        fillColor: brightness == Brightness.light
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // ========== FloatingActionButton Theme ==========
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: config.cardElevation + 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardBorderRadius),
        ),
      ),

      // ========== Dialog Theme ==========
      dialogTheme: DialogThemeData(
        elevation: config.cardElevation + 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardBorderRadius * 1.5),
        ),
      ),

      // ========== Bottom Sheet Theme ==========
      bottomSheetTheme: BottomSheetThemeData(
        elevation: config.cardElevation + 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(config.cardBorderRadius * 1.5),
          ),
        ),
      ),

      // ========== Chip Theme ==========
      chipTheme: ChipThemeData(
        elevation: config.cardElevation / 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardBorderRadius / 2),
        ),
      ),

      // ========== Divider Theme ==========
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 16,
      ),

      // ========== List Tile Theme ==========
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardBorderRadius / 2),
        ),
      ),
    );
  }

  /// Tema light padrão
  static ThemeData light([AppThemeConfig? config]) {
    return fromConfig(
      config: config ?? AppThemeConfig.light,
      brightness: Brightness.light,
    );
  }

  /// Tema dark padrão
  static ThemeData dark([AppThemeConfig? config]) {
    return fromConfig(
      config: config ?? AppThemeConfig.dark,
      brightness: Brightness.dark,
    );
  }

  /// Tema azul personalizado
  static ThemeData blueLight() {
    return fromConfig(
      config: AppThemeConfig.blueTheme,
      brightness: Brightness.light,
    );
  }

  /// Tema verde personalizado
  static ThemeData greenLight() {
    return fromConfig(
      config: AppThemeConfig.greenTheme,
      brightness: Brightness.light,
    );
  }

  /// Tema personalizado a partir de uma cor seed
  static ThemeData custom({
    required Color seedColor,
    required Brightness brightness,
    Color? cardBackground,
    Color? cardBorder,
    double cardElevation = 2.0,
    double cardBorderRadius = 12.0,
  }) {
    final config = AppThemeConfig(
      seedColor: seedColor.toColorValue(),
      cardBackground: cardBackground?.toColorValue(),
      cardBorder: cardBorder?.toColorValue(),
      cardElevation: cardElevation,
      cardBorderRadius: cardBorderRadius,
    );

    return fromConfig(
      config: config,
      brightness: brightness,
    );
  }
}
