/// Value Object para representar cores sem depender do Flutter.
///
/// Armazena a cor no formato ARGB (Alpha, Red, Green, Blue) como um int32.
/// Compatível com Flutter Color, mas pode ser usado em código Dart puro.
///
/// Exemplo de uso:
/// ```dart
/// // Criar cor RGB
/// final red = ColorValue.fromRGB(255, 0, 0);
///
/// // Criar cor com alpha
/// final semiTransparentRed = ColorValue.fromARGB(128, 255, 0, 0);
///
/// // Criar cor de hex
/// final blue = ColorValue.fromHex('#0000FF');
/// final blueWithAlpha = ColorValue.fromHex('#800000FF');
///
/// // Modificar opacidade
/// final faded = blue.withOpacity(0.5);
///
/// // Acessar componentes
/// print('R: ${red.red}, G: ${red.green}, B: ${red.blue}');
///
/// // Converter para hex
/// print(red.toHex()); // #FF0000
/// ```
class ColorValue {
  /// Valor da cor no formato ARGB como int32
  final int value;

  /// Cria uma cor a partir do valor ARGB int32
  const ColorValue(this.value);

  /// Cria uma cor a partir dos componentes ARGB (0-255)
  factory ColorValue.fromARGB(int a, int r, int g, int b) {
    assert(a >= 0 && a <= 255, 'Alpha deve estar entre 0 e 255');
    assert(r >= 0 && r <= 255, 'Red deve estar entre 0 e 255');
    assert(g >= 0 && g <= 255, 'Green deve estar entre 0 e 255');
    assert(b >= 0 && b <= 255, 'Blue deve estar entre 0 e 255');

    return ColorValue(
      (a & 0xFF) << 24 | (r & 0xFF) << 16 | (g & 0xFF) << 8 | (b & 0xFF),
    );
  }

  /// Cria uma cor RGB opaca (alpha = 255)
  factory ColorValue.fromRGB(int r, int g, int b) {
    return ColorValue.fromARGB(255, r, g, b);
  }

  /// Cria uma cor a partir de uma string hexadecimal
  ///
  /// Aceita formatos:
  /// - RGB: "#RGB" -> converte para "#FFRRGGBB"
  /// - RRGGBB: "#RRGGBB" -> converte para "#FFRRGGBB"
  /// - AARRGGBB: "#AARRGGBB" -> usa como está
  ///
  /// O prefixo "#" é opcional.
  factory ColorValue.fromHex(String hex) {
    var hexColor = hex.replaceAll('#', '').toUpperCase();

    // Expande formato curto RGB para RRGGBB
    if (hexColor.length == 3) {
      hexColor = hexColor.split('').map((c) => '$c$c').join();
    }

    // Adiciona FF (opaco) se não tiver alpha
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }

    if (hexColor.length != 8) {
      throw FormatException(
        'Formato hex inválido: $hex. Use #RGB, #RRGGBB ou #AARRGGBB',
      );
    }

    return ColorValue(int.parse(hexColor, radix: 16));
  }

  /// Componente Alpha (0-255)
  int get alpha => (value >> 24) & 0xFF;

  /// Componente Red (0-255)
  int get red => (value >> 16) & 0xFF;

  /// Componente Green (0-255)
  int get green => (value >> 8) & 0xFF;

  /// Componente Blue (0-255)
  int get blue => value & 0xFF;

  /// Opacidade como double (0.0 a 1.0)
  double get opacity => alpha / 255.0;

  /// Retorna uma nova cor com a opacidade modificada
  ///
  /// [opacity] deve estar entre 0.0 (transparente) e 1.0 (opaco)
  ColorValue withOpacity(double opacity) {
    assert(
      opacity >= 0.0 && opacity <= 1.0,
      'Opacity deve estar entre 0.0 e 1.0',
    );
    return ColorValue.fromARGB(
      (255.0 * opacity).round(),
      red,
      green,
      blue,
    );
  }

  /// Retorna uma nova cor com o alpha modificado
  ///
  /// [alpha] deve estar entre 0 (transparente) e 255 (opaco)
  ColorValue withAlpha(int alpha) {
    assert(alpha >= 0 && alpha <= 255, 'Alpha deve estar entre 0 e 255');
    return ColorValue.fromARGB(alpha, red, green, blue);
  }

  /// Retorna a cor em formato hexadecimal
  ///
  /// Se [includeAlpha] for true, retorna "#AARRGGBB", caso contrário "#RRGGBB"
  String toHex({bool includeAlpha = false}) {
    if (includeAlpha) {
      return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
    final rgb = value & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// Retorna uma string representando os componentes ARGB
  String toARGBString() {
    return 'ARGB($alpha, $red, $green, $blue)';
  }

  /// Retorna uma string representando os componentes RGB
  String toRGBString() {
    return 'RGB($red, $green, $blue)';
  }

  /// Retorna uma string CSS rgba()
  String toCSSRGBA() {
    return 'rgba($red, $green, $blue, ${opacity.toStringAsFixed(2)})';
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
