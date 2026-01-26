import 'package:design_system_shared/design_system_shared.dart';
import 'package:flutter/material.dart';

/// Tipos de alerta disponíveis.
enum DSAlertType { success, warning, error, info }

/// Sistema de alertas do Design System.
///
/// Exibe notificações temporárias usando SnackBar com animação de progresso.
/// Usa tokens do Design System para cores e espaçamentos.
///
/// Exemplo de uso:
/// ```dart
/// DSAlert.success(context, message: 'Operação realizada com sucesso!');
/// DSAlert.error(context, message: 'Erro ao processar requisição');
/// DSAlert.warning(context, message: 'Atenção: dados não salvos');
/// ```
class DSAlert {
  /// Exibe um alerta de sucesso.
  static void success(BuildContext context, {required String message}) =>
      _show(context, message: message, type: DSAlertType.success);

  /// Exibe um alerta de aviso.
  static void warning(BuildContext context, {required String message}) =>
      _show(context, message: message, type: DSAlertType.warning);

  /// Exibe um alerta de erro.
  static void error(BuildContext context, {required String message}) =>
      _show(context, message: message, type: DSAlertType.error);

  /// Exibe um alerta informativo.
  static void info(BuildContext context, {required String message}) =>
      _show(context, message: message, type: DSAlertType.info);

  static void _show(
    BuildContext context, {
    required String message,
    required DSAlertType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.clearSnackBars();

    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      content: _DSAlertContent(
        message: message,
        type: type,
        duration: duration,
      ),
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }
}

class _DSAlertContent extends StatefulWidget {
  final String message;
  final DSAlertType type;
  final Duration duration;

  const _DSAlertContent({
    required this.message,
    required this.type,
    required this.duration,
  });

  @override
  State<_DSAlertContent> createState() => _DSAlertContentState();
}

class _DSAlertContentState extends State<_DSAlertContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Color _getColor(BuildContext context) {
    switch (widget.type) {
      case DSAlertType.success:
        return Colors.green;
      case DSAlertType.warning:
        return Colors.yellow;
      case DSAlertType.error:
        return Colors.red;
      case DSAlertType.info:
        return Colors.blue;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case DSAlertType.success:
        return Icons.check_box;
      case DSAlertType.warning:
        return Icons.warning;
      case DSAlertType.error:
        return Icons.error_outline;
      case DSAlertType.info:
        return Icons.info_outline;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration + const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getColor(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DSSpacing.md),
          topRight: Radius.circular(DSSpacing.md),
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Row(
              children: [
                Icon(_icon, color: statusColor),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: Text(
                    widget.message,
                    // style: DSTextStyles.alertTitle.copyWith(
                    //   color: Colors.white,
                    // ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(DSSpacing.md),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => LinearProgressIndicator(
                  value: _controller.value,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
