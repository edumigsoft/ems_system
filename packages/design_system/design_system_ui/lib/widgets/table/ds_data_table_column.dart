import 'package:flutter/material.dart';

/// Configuração de uma coluna da tabela.
///
/// `DSDataTableColumn` define as propriedades de uma coluna, incluindo seu
/// label e como renderizar as células. Suporta duas abordagens:
///
/// 1. **Célula pré-pronta** (via [cell]): Use componentes especializados como
///    `DSTableCellWithIcon`, `DSTableCellTwoLines`, etc.
/// 2. **Builder customizado** (via [builder]): Controle total sobre a
///    renderização da célula.
///
/// **Exemplo com célula pré-pronta:**
/// ```dart
/// DSDataTableColumn<School>(
///   label: 'ESCOLA',
///   cell: DSTableCellWithIcon(
///     icon: Icons.school,
///     title: school.name,
///     subtitle: 'Cod: ${school.code}',
///   ),
/// )
/// ```
///
/// **Exemplo com builder customizado:**
/// ```dart
/// DSDataTableColumn<School>(
///   label: 'AÇÕES',
///   builder: (school) => MyCustomActionsWidget(school),
/// )
/// ```
class DSDataTableColumn<T> {
  /// Label do cabeçalho da coluna (em uppercase por convenção).
  final String label;

  /// Widget pré-pronto para renderizar a célula.
  ///
  /// Use componentes especializados como [DSTableCellWithIcon] ou
  /// [DSTableCellTwoLines] para layouts comuns.
  ///
  /// Mutuamente exclusivo com [builder]. Pelo menos um deve ser fornecido.
  final Widget? cell;

  /// Builder customizado para renderizar a célula.
  ///
  /// Recebe o item [T] atual e retorna um [Widget].
  /// Use quando precisar de controle total sobre a renderização.
  ///
  /// Mutuamente exclusivo com [cell]. Pelo menos um deve ser fornecido.
  final Widget Function(T item)? builder;

  /// Largura opcional da coluna em pixels.
  ///
  /// Se não fornecido, a coluna usa o espaçamento padrão do DataTable.
  final double? width;

  /// Se a coluna contém valores numéricos (alinha à direita).
  final bool numeric;

  /// Tooltip opcional para o cabeçalho da coluna.
  final String? tooltip;

  const DSDataTableColumn({
    required this.label,
    this.cell,
    this.builder,
    this.width,
    this.numeric = false,
    this.tooltip,
  }) : assert(
          (cell != null && builder == null) ||
              (cell == null && builder != null),
          'Deve fornecer exatamente um: cell ou builder',
        );

  /// Renderiza a célula para o item fornecido.
  ///
  /// Usa [cell] se fornecido, caso contrário chama [builder].
  Widget buildCell(T item) {
    if (cell != null) {
      return cell!;
    }
    if (builder != null) {
      return builder!(item);
    }
    throw StateError('DSDataTableColumn deve ter cell ou builder');
  }
}
