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

  /// Cor da sombra dos Cards
  ///
  /// Se não especificada, a cor padrão do tema gerado será usada.
  final ColorValue? cardShadowColor;

  /// Padding vertical dos Cards
  ///
  /// Se não especificada, o padding vertical será 0.0.
  final double cardPaddingVertical;

  /// Padding horizontal dos Cards
  ///
  /// Se não especificada, o padding horizontal será 0.0.
  final double cardPaddingHorizontal;

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
    this.cardShadowColor,
    this.cardPaddingVertical = 8.0,
    this.cardPaddingHorizontal = 0.0,
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
    ColorValue? cardShadowColor,
    double? cardPaddingVertical,
    double? cardPaddingHorizontal,
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
      cardShadowColor: cardShadowColor ?? this.cardShadowColor,
      cardPaddingVertical: cardPaddingVertical ?? this.cardPaddingVertical,
      cardPaddingHorizontal:
          cardPaddingHorizontal ?? this.cardPaddingHorizontal,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      themeName: themeName ?? this.themeName,
      fontFamily: fontFamily ?? this.fontFamily,
      baseSpacing: baseSpacing ?? this.baseSpacing,
    );
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
        other.cardShadowColor == cardShadowColor &&
        other.cardPaddingVertical == cardPaddingVertical &&
        other.cardPaddingHorizontal == cardPaddingHorizontal &&
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
    cardShadowColor,
    cardPaddingVertical,
    cardPaddingHorizontal,
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
      'cardShadowColor': cardShadowColor?.value,
      'cardPaddingVertical': cardPaddingVertical,
      'cardPaddingHorizontal': cardPaddingHorizontal,
      'useMaterial3': useMaterial3,
      'themeName': themeName,
      'fontFamily': fontFamily,
      'baseSpacing': baseSpacing,
    };
  }

  /// Cria um DSThemeConfig a partir de um Map
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
      cardShadowColor: ColorValue(map['cardShadowColor'] as int),
      cardPaddingVertical:
          (map['cardPaddingVertical'] as num?)?.toDouble() ?? 8.0,
      cardPaddingHorizontal:
          (map['cardPaddingHorizontal'] as num?)?.toDouble() ?? 0.0,
      useMaterial3: map['useMaterial3'] as bool? ?? true,
      themeName: map['themeName'] as String?,
      fontFamily: map['fontFamily'] as String?,
      baseSpacing: (map['baseSpacing'] as num?)?.toDouble(),
    );
  }
}
