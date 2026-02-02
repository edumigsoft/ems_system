import 'package:flutter/material.dart';

/// Célula de tabela com duas linhas de texto (primário/secundário).
///
/// Componente especializado para renderizar células com um texto principal
/// e um texto secundário em linhas separadas.
///
/// **Exemplo de uso:**
/// ```dart
/// DSTableCellTwoLines(
///   primary: 'São Paulo, SP',
///   secondary: 'Centro',
/// )
/// ```
class DSTableCellTwoLines extends StatelessWidget {
  /// Texto principal (primeira linha).
  final String primary;

  /// Texto secundário (segunda linha).
  final String secondary;

  /// Se os textos podem quebrar em múltiplas linhas (padrão: false).
  final bool softWrap;

  const DSTableCellTwoLines({
    super.key,
    required this.primary,
    required this.secondary,
    this.softWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final dsTheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          primary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: dsTheme.onSurface,
          ),
          overflow: softWrap ? null : TextOverflow.ellipsis,
          softWrap: softWrap,
        ),
        Text(
          secondary,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: dsTheme.onSurface.withValues(alpha: 0.6),
          ),
          overflow: softWrap ? null : TextOverflow.ellipsis,
          softWrap: softWrap,
        ),
      ],
    );
  }
}
