import 'package:flutter/material.dart';
import 'package:design_system_shared/design_system_shared.dart';

/// Extension para converter ColorValue em Flutter Color
extension ColorValueExtension on ColorValue {
  Color toFlutterColor() => Color(value);
}

/// Extension para converter Flutter Color em ColorValue
extension FlutterColorExtension on Color {
  ColorValue toColorValue() => ColorValue(value);
}
