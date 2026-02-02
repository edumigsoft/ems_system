import 'package:flutter/material.dart';
import '../../../../school_ui.dart';
import 'desktop_table_widget.dart';

class DesktopWidget extends StatefulWidget {
  final SchoolViewModel viewModel;
  const DesktopWidget({super.key, required this.viewModel});

  @override
  State<DesktopWidget> createState() => _DesktopWidgetState();
}

class _DesktopWidgetState extends State<DesktopWidget> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return DesktopTableWidget(viewModel: widget.viewModel);
      },
    );
  }
}
