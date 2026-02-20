import 'package:flutter/material.dart';
import '../../../view_models/tag_view_model.dart';
import 'desktop_table_widget.dart';

class DesktopWidget extends StatelessWidget {
  final TagViewModel viewModel;

  const DesktopWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => DesktopTableWidget(viewModel: viewModel),
    );
  }
}
