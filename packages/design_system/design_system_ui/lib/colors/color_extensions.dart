import 'package:flutter/material.dart';
import 'package:design_system_shared/design_system_shared.dart';

/// Extension para converter ColorValue em Flutter Color
extension ColorValueExtension on ColorValue {
  /// Converte ColorValue para Flutter Color
  ///
  /// Usa Color.fromARGB() que é o método estável e recomendado.
  Color toColor() {
    return Color.fromARGB(alpha, red, green, blue);
  }

  /// Alternativa mais explícita (mesmo comportamento)
  Color toFlutterColor() {
    return Color.fromARGB(alpha, red, green, blue);
  }

  /// Cria um Color do Flutter a partir dos componentes ARGB
  ///
  /// Alias para toColor() - mantido para compatibilidade.
  Color toColorFromComponents() {
    return Color.fromARGB(alpha, red, green, blue);
  }
}

/// Extension para converter Flutter Color em ColorValue
extension FlutterColorExtension on Color {
  /// Converte Flutter Color para ColorValue usando toARGB32()
  ///
  /// Este é o método recomendado que não usa a propriedade .value deprecated.
  ColorValue toColorValue() {
    // toARGB32() retorna int32 no formato ARGB
    return ColorValue(toARGB32());
  }

  /// Alternativa usando componentes ARGB
  ///
  /// Nota: No Flutter atual, a, r, g, b retornam double (0.0-1.0),
  /// então precisamos converter para int (0-255).
  ColorValue toColorValueFromComponents() {
    return ColorValue.fromARGB(
      (a * 255).round(),
      (r * 255).round(),
      (g * 255).round(),
      (b * 255).round(),
    );
  }
}
