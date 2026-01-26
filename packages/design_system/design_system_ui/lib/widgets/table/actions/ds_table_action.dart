import 'package:flutter/material.dart';

/// Modelo de ação para tabelas.
///
/// Representa uma ação que pode ser executada em uma linha da tabela,
/// como editar, excluir, visualizar, etc.
///
/// **Exemplo de uso:**
/// ```dart
/// DSTableAction(
///   icon: Icons.edit,
///   onPressed: () => editItem(item),
///   tooltip: 'Editar',
/// )
/// ```
class DSTableAction {
  /// Ícone da ação.
  final IconData icon;

  /// Callback executado quando a ação é pressionada.
  final VoidCallback onPressed;

  /// Cor opcional do ícone (usa tema padrão se null).
  final Color? color;

  /// Tooltip opcional para a ação.
  final String? tooltip;

  const DSTableAction({
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });
}
