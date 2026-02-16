import 'package:flutter/material.dart';

/// Estilos de texto especializados para componentes de tabela.
///
/// Encapsula toda a tipografia usada em tabelas, permitindo que cada tema
/// (Acqua, Lolo, etc) defina estilos específicos sem hardcoding.
class DSTableTextStyles {
  /// Estilo para labels dos cabeçalhos da tabela.
  final TextStyle headerLabel;

  /// Estilo para texto principal das células.
  final TextStyle cellPrimary;

  /// Estilo para texto secundário das células.
  final TextStyle cellSecondary;

  /// Estilo para labels da paginação.
  final TextStyle paginationLabel;

  const DSTableTextStyles({
    required this.headerLabel,
    required this.cellPrimary,
    required this.cellSecondary,
    required this.paginationLabel,
  });

  /// Cria estilos de texto para tabela a partir do tema base.
  ///
  /// Mapeia os estilos padrão do Material Design para uso em tabelas:
  /// - headerLabel: `labelMedium` (12px, bold, letterSpacing: 0.5)
  /// - cellPrimary: `bodyMedium` (14px, normal)
  /// - cellSecondary: `bodySmall` (12px, normal)
  /// - paginationLabel: `bodyMedium` (14px, normal)
  factory DSTableTextStyles.fromTextTheme(TextTheme textTheme) {
    return DSTableTextStyles(
      headerLabel:
          textTheme.labelMedium ??
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
      cellPrimary:
          textTheme.bodyMedium ??
          const TextStyle(
            fontSize: 14,
            letterSpacing: 0.25,
          ),
      cellSecondary:
          textTheme.bodySmall ??
          const TextStyle(
            fontSize: 12,
            letterSpacing: 0.4,
          ),
      paginationLabel:
          textTheme.bodyMedium ??
          const TextStyle(
            fontSize: 14,
            letterSpacing: 0.25,
          ),
    );
  }

  DSTableTextStyles copyWith({
    TextStyle? headerLabel,
    TextStyle? cellPrimary,
    TextStyle? cellSecondary,
    TextStyle? paginationLabel,
  }) {
    return DSTableTextStyles(
      headerLabel: headerLabel ?? this.headerLabel,
      cellPrimary: cellPrimary ?? this.cellPrimary,
      cellSecondary: cellSecondary ?? this.cellSecondary,
      paginationLabel: paginationLabel ?? this.paginationLabel,
    );
  }

  static DSTableTextStyles lerp(
    DSTableTextStyles? a,
    DSTableTextStyles? b,
    double t,
  ) {
    if (a == null && b == null) {
      return DSTableTextStyles.fromTextTheme(const TextTheme());
    }
    if (a == null) return b!;
    if (b == null) return a;

    return DSTableTextStyles(
      headerLabel: TextStyle.lerp(a.headerLabel, b.headerLabel, t)!,
      cellPrimary: TextStyle.lerp(a.cellPrimary, b.cellPrimary, t)!,
      cellSecondary: TextStyle.lerp(a.cellSecondary, b.cellSecondary, t)!,
      paginationLabel: TextStyle.lerp(a.paginationLabel, b.paginationLabel, t)!,
    );
  }
}

/// Configuração de tema para componentes de tabela.
///
/// `DSTableThemeData` é uma [ThemeExtension] que armazena valores padrão de
/// layout e tipografia específicos para tabelas. Isso permite que diferentes
/// temas (Acqua light/dark, Lolo, etc) customizem a aparência das tabelas
/// de forma agnóstica e consistente.
///
/// Exemplo de uso:
/// ```dart
/// final tableTheme = Theme.of(context).extension<DSTableThemeData>();
/// final headerHeight = tableTheme?.headingRowHeight ?? 48;
/// ```
class DSTableThemeData extends ThemeExtension<DSTableThemeData> {
  /// Altura da linha de cabeçalho (padrão: 48).
  final double headingRowHeight;

  /// Altura mínima das linhas de dados (padrão: 72).
  final double dataRowMinHeight;

  /// Altura máxima das linhas de dados (padrão: 72).
  final double dataRowMaxHeight;

  /// Espaçamento entre colunas (padrão: 24).
  final double columnSpacing;

  /// Margem horizontal da tabela (padrão: 16).
  final double horizontalMargin;

  /// Espessura do divisor entre linhas (padrão: 1).
  final double dividerThickness;

  /// Se deve mostrar borda inferior na tabela (padrão: true).
  final bool showBottomBorder;

  /// Estilos de texto especializados para a tabela.
  final DSTableTextStyles textStyles;

  const DSTableThemeData({
    this.headingRowHeight = 48,
    this.dataRowMinHeight = 72,
    this.dataRowMaxHeight = 72,
    this.columnSpacing = 24,
    this.horizontalMargin = 16,
    this.dividerThickness = 1,
    this.showBottomBorder = true,
    required this.textStyles,
  });

  /// Cria um tema padrão para tabelas a partir do [TextTheme] fornecido.
  factory DSTableThemeData.defaultTheme(TextTheme textTheme) {
    return DSTableThemeData(
      textStyles: DSTableTextStyles.fromTextTheme(textTheme),
    );
  }

  @override
  ThemeExtension<DSTableThemeData> copyWith({
    double? headingRowHeight,
    double? dataRowMinHeight,
    double? dataRowMaxHeight,
    double? columnSpacing,
    double? horizontalMargin,
    double? dividerThickness,
    bool? showBottomBorder,
    DSTableTextStyles? textStyles,
  }) {
    return DSTableThemeData(
      headingRowHeight: headingRowHeight ?? this.headingRowHeight,
      dataRowMinHeight: dataRowMinHeight ?? this.dataRowMinHeight,
      dataRowMaxHeight: dataRowMaxHeight ?? this.dataRowMaxHeight,
      columnSpacing: columnSpacing ?? this.columnSpacing,
      horizontalMargin: horizontalMargin ?? this.horizontalMargin,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      showBottomBorder: showBottomBorder ?? this.showBottomBorder,
      textStyles: textStyles ?? this.textStyles,
    );
  }

  @override
  ThemeExtension<DSTableThemeData> lerp(
    ThemeExtension<DSTableThemeData>? other,
    double t,
  ) {
    if (other is! DSTableThemeData) {
      return this;
    }

    return DSTableThemeData(
      headingRowHeight: _lerpDouble(
        headingRowHeight,
        other.headingRowHeight,
        t,
      ),
      dataRowMinHeight: _lerpDouble(
        dataRowMinHeight,
        other.dataRowMinHeight,
        t,
      ),
      dataRowMaxHeight: _lerpDouble(
        dataRowMaxHeight,
        other.dataRowMaxHeight,
        t,
      ),
      columnSpacing: _lerpDouble(columnSpacing, other.columnSpacing, t),
      horizontalMargin: _lerpDouble(
        horizontalMargin,
        other.horizontalMargin,
        t,
      ),
      dividerThickness: _lerpDouble(
        dividerThickness,
        other.dividerThickness,
        t,
      ),
      showBottomBorder: t < 0.5 ? showBottomBorder : other.showBottomBorder,
      textStyles: DSTableTextStyles.lerp(textStyles, other.textStyles, t),
    );
  }
}

/// Helper para interpolar valores double.
double _lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}
