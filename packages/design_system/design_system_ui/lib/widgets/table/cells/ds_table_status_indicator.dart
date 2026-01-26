import 'package:design_system_shared/design_system_shared.dart';
import 'package:flutter/material.dart';

/// Indicador visual de status com círculo colorido e label.
///
/// Componente especializado para renderizar status em tabelas usando um
/// círculo colorido seguido de um texto descritivo.
///
/// **Exemplo de uso:**
/// ```dart
/// DSTableStatusIndicator(
///   label: 'Ativa',
///   color: DSColors.success,
/// )
///
/// DSTableStatusIndicator(
///   label: 'Em Manutenção',
///   color: DSColors.warning,
///   indicatorSize: 10,
/// )
/// ```
class DSTableStatusIndicator extends StatelessWidget {
  /// Texto descritivo do status.
  final String label;

  /// Cor do indicador (círculo colorido).
  final Color color;

  /// Tamanho do círculo indicador (padrão: 8).
  final double indicatorSize;

  const DSTableStatusIndicator({
    super.key,
    required this.label,
    required this.color,
    this.indicatorSize = 8,
  });

  @override
  Widget build(BuildContext context) {
    final dsTheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: indicatorSize,
          height: indicatorSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: DSSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: dsTheme.onSurface,
          ),
        ),
      ],
    );
  }
}
