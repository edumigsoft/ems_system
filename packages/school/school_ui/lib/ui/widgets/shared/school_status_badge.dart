import 'package:flutter/material.dart';
import 'package:school_shared/school_shared.dart';

/// Badge reutilizável para exibir o status da escola.
///
/// Mostra o status com cor correspondente:
/// - Active: verde
/// - Maintenance: amarelo
/// - Inactive: vermelho
class SchoolStatusBadge extends StatelessWidget {
  final SchoolStatus status;
  final bool compact;

  const SchoolStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  Color get _backgroundColor {
    switch (status) {
      case SchoolStatus.active:
        return Colors.green.shade100;
      case SchoolStatus.maintenance:
        return Colors.orange.shade100;
      case SchoolStatus.inactive:
        return Colors.red.shade100;
    }
  }

  Color get _textColor {
    switch (status) {
      case SchoolStatus.active:
        return Colors.green.shade900;
      case SchoolStatus.maintenance:
        return Colors.orange.shade900;
      case SchoolStatus.inactive:
        return Colors.red.shade900;
    }
  }

  String get _label {
    switch (status) {
      case SchoolStatus.active:
        return 'Ativa';
      case SchoolStatus.maintenance:
        return 'Manutenção';
      case SchoolStatus.inactive:
        return 'Inativa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _label,
        style: TextStyle(
          color: _textColor,
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: _backgroundColor,
      visualDensity: compact ? VisualDensity.compact : null,
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 4)
          : const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
