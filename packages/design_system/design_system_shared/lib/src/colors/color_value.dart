/// Value Object para representar cores sem depender do Flutter
class ColorValue {
  final int value; // ARGB format

  const ColorValue(this.value);

  factory ColorValue.fromARGB(int a, int r, int g, int b) {
    return ColorValue(
      (a & 0xFF) << 24 | (r & 0xFF) << 16 | (g & 0xFF) << 8 | (b & 0xFF),
    );
  }

  factory ColorValue.fromRGB(int r, int g, int b) {
    return ColorValue.fromARGB(255, r, g, b);
  }

  factory ColorValue.fromHex(String hex) {
    final hexColor = hex.replaceAll('#', '');
    final hasAlpha = hexColor.length == 8;

    if (hasAlpha) {
      return ColorValue(int.parse(hexColor, radix: 16));
    } else {
      return ColorValue(int.parse('FF$hexColor', radix: 16));
    }
  }

  int get alpha => (value >> 24) & 0xFF;
  int get red => (value >> 16) & 0xFF;
  int get green => (value >> 8) & 0xFF;
  int get blue => value & 0xFF;

  double get opacity => alpha / 255.0;

  /// Retorna uma cor com opacidade modificada
  ColorValue withOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return ColorValue.fromARGB((255.0 * opacity).round(), red, green, blue);
  }

  /// Retorna o hex da cor
  String toHex({bool includeAlpha = false}) {
    if (includeAlpha) {
      return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColorValue && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ColorValue(${toHex(includeAlpha: true)})';
}
