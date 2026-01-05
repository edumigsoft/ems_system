import '../../design_system_shared.dart';
// import '../colors/color_value.dart';
// import '../colors/app_color_palette.dart';

/// Configuração de tema personalizado (Dart puro)
///
/// Esta classe define as configurações de um tema sem depender do Flutter.
/// Use-a para criar temas personalizados que podem ser utilizados tanto
/// no frontend quanto no backend.
///
/// Exemplo de uso:
/// ```dart
/// // Tema customizado
/// final customTheme = DSThemeConfig(
///   seedColor: ColorValue.fromHex('#1976D2'),
///   cardBackground: ColorValue.fromHex('#E3F2FD'),
///   cardBorder: ColorValue.fromHex('#BBDEFB'),
///   cardElevation: 3.0,
///   cardBorderRadius: 16.0,
/// );
///
/// // No Flutter (design_system_ui)
/// final themeData = DSTheme.fromConfig(
///   config: customTheme,
///   brightness: Brightness.light,
/// );
/// ```
class DSThemeConfig {
  /// Cor seed para gerar o ColorScheme
  ///
  /// Esta é a cor primária base do tema. O Flutter gerará
  /// automaticamente variações desta cor para criar uma paleta harmônica.
  final ColorValue seedColor;

  /// Cor de fundo customizada para Cards
  ///
  /// Se não especificada, será usada a cor padrão do tema gerado.
  /// Use esta propriedade quando quiser que os cards tenham uma cor
  /// diferente do padrão estabelecido pelo seedColor.
  final ColorValue? cardBackground;

  /// Cor da borda dos Cards
  ///
  /// Se não especificada, os cards não terão borda.
  final ColorValue? cardBorder;

  /// Elevação (sombra) dos Cards
  ///
  /// Valor padrão: 2.0
  /// Range recomendado: 0.0 a 8.0
  final double cardElevation;

  /// Border radius dos Cards e componentes relacionados
  ///
  /// Valor padrão: 12.0
  /// Este valor também influencia botões, inputs e outros componentes.
  final double cardBorderRadius;

  /// Se deve usar Material Design 3
  ///
  /// Valor padrão: true
  final bool useMaterial3;

  /// Nome do tema (opcional, para identificação)
  final String? themeName;

  /// Configuração de tipografia (futuro)
  final String? fontFamily;

  /// Espaçamento base (futuro)
  final double? baseSpacing;

  const DSThemeConfig({
    required this.seedColor,
    this.cardBackground,
    this.cardBorder,
    this.cardElevation = 2.0,
    this.cardBorderRadius = 12.0,
    this.useMaterial3 = true,
    this.themeName,
    this.fontFamily,
    this.baseSpacing,
  });

  // ========== Métodos Utilitários ==========

  /// Cria uma cópia do tema com alterações específicas
  DSThemeConfig copyWith({
    ColorValue? seedColor,
    ColorValue? cardBackground,
    ColorValue? cardBorder,
    double? cardElevation,
    double? cardBorderRadius,
    bool? useMaterial3,
    String? themeName,
    String? fontFamily,
    double? baseSpacing,
  }) {
    return DSThemeConfig(
      seedColor: seedColor ?? this.seedColor,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      cardElevation: cardElevation ?? this.cardElevation,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      themeName: themeName ?? this.themeName,
      fontFamily: fontFamily ?? this.fontFamily,
      baseSpacing: baseSpacing ?? this.baseSpacing,
    );
  }

  /// Remove a cor de fundo customizada dos cards
  /// (volta a usar a cor padrão do tema)
  DSThemeConfig withoutCardBackground() {
    return copyWith(cardBackground: null);
  }

  /// Remove a borda customizada dos cards
  DSThemeConfig withoutCardBorder() {
    return copyWith(cardBorder: null);
  }

  /// Ajusta o border radius de todos os componentes
  DSThemeConfig withBorderRadius(double radius) {
    return copyWith(cardBorderRadius: radius);
  }

  /// Ajusta a elevação de todos os componentes
  DSThemeConfig withElevation(double elevation) {
    return copyWith(cardElevation: elevation);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSThemeConfig &&
        other.seedColor == seedColor &&
        other.cardBackground == cardBackground &&
        other.cardBorder == cardBorder &&
        other.cardElevation == cardElevation &&
        other.cardBorderRadius == cardBorderRadius &&
        other.useMaterial3 == useMaterial3 &&
        other.themeName == themeName &&
        other.fontFamily == fontFamily &&
        other.baseSpacing == baseSpacing;
  }

  @override
  int get hashCode => Object.hash(
    seedColor,
    cardBackground,
    cardBorder,
    cardElevation,
    cardBorderRadius,
    useMaterial3,
    themeName,
    fontFamily,
    baseSpacing,
  );

  @override
  String toString() {
    return 'DSThemeConfig('
        'name: $themeName, '
        'seedColor: ${seedColor.toHex()}, '
        'cardBackground: ${cardBackground?.toHex()}, '
        'cardBorder: ${cardBorder?.toHex()}, '
        'elevation: $cardElevation, '
        'borderRadius: $cardBorderRadius'
        ')';
  }

  /// Converte para um Map (útil para serialização)
  Map<String, dynamic> toMap() {
    return {
      'seedColor': seedColor.value,
      'cardBackground': cardBackground?.value,
      'cardBorder': cardBorder?.value,
      'cardElevation': cardElevation,
      'cardBorderRadius': cardBorderRadius,
      'useMaterial3': useMaterial3,
      'themeName': themeName,
      'fontFamily': fontFamily,
      'baseSpacing': baseSpacing,
    };
  }

  /// Cria um AppThemeConfig a partir de um Map
  factory DSThemeConfig.fromMap(Map<String, dynamic> map) {
    return DSThemeConfig(
      seedColor: ColorValue(map['seedColor'] as int),
      cardBackground: map['cardBackground'] != null
          ? ColorValue(map['cardBackground'] as int)
          : null,
      cardBorder: map['cardBorder'] != null
          ? ColorValue(map['cardBorder'] as int)
          : null,
      cardElevation: (map['cardElevation'] as num?)?.toDouble() ?? 2.0,
      cardBorderRadius: (map['cardBorderRadius'] as num?)?.toDouble() ?? 12.0,
      useMaterial3: map['useMaterial3'] as bool? ?? true,
      themeName: map['themeName'] as String?,
      fontFamily: map['fontFamily'] as String?,
      baseSpacing: (map['baseSpacing'] as num?)?.toDouble(),
    );
  }
}
