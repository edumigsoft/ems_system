import 'package:flutter/material.dart';
import '../../../../view_models/notebook_list_view_model.dart';
import 'desktop_table_widget.dart';

/// Wrapper desktop — conecta ViewModel ao DesktopTableWidget.
class DesktopWidget extends StatelessWidget {
  final NotebookListViewModel viewModel;

  const DesktopWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => DesktopTableWidget(viewModel: viewModel),
    );
  }
}
