class ColorValue {
  final int value; // ARGB

  const ColorValue(this.value);

  factory ColorValue.fromARGB(int a, int r, int g, int b) {
    return ColorValue(
      (a & 0xFF) << 24 | (r & 0xFF) << 16 | (g & 0xFF) << 8 | (b & 0xFF),
    );
  }

  factory ColorValue.fromHex(String hex) {
    final hexColor = hex.replaceAll('#', '');
    return ColorValue(int.parse('FF$hexColor', radix: 16));
  }

  int get alpha => (value >> 24) & 0xFF;
  int get red => (value >> 16) & 0xFF;
  int get green => (value >> 8) & 0xFF;
  int get blue => value & 0xFF;
}
