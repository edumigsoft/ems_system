import 'package:flutter/material.dart';

/// Contrato para widgets registráveis no Dashboard.
///
/// Cada módulo de feature implementa esta interface para expor
/// seus widgets ao DashboardPage sem acoplamento direto.
abstract class DashboardWidgetEntry {
  /// Identificador único da entry (ex: 'notebook_reminders').
  String get id;

  /// Título exibido no card do dashboard.
  String get title;

  /// Ícone exibido no card do dashboard.
  IconData get icon;

  /// Constrói o conteúdo do widget para exibição no dashboard.
  Widget build(BuildContext context);
}
