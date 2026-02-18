import 'package:core_ui/core_ui.dart' show ResponsiveLayout;
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import '../view_models/notebook_list_view_model.dart';
import '../ui/widgets/components/mobile/mobile_widget.dart';
import '../ui/widgets/components/tablet/tablet_widget.dart';
import '../ui/widgets/components/desktop/desktop_widget.dart';

/// Página de listagem de cadernos.
///
/// Sem Scaffold/AppBar — usa DSCardHeader + DSCard + ResponsiveLayout.
/// Mobile: read-only. Tablet/Desktop: edição completa.
class NotebookListPage extends StatefulWidget {
  final NotebookListViewModel viewModel;

  const NotebookListPage({super.key, required this.viewModel});

  @override
  State<NotebookListPage> createState() => _NotebookListPageState();
}

class _NotebookListPageState extends State<NotebookListPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
    widget.viewModel.loadNotebooks();
    widget.viewModel.loadAvailableTags();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
      if (widget.viewModel.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'OK',
              onPressed: widget.viewModel.clearError,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DSCardHeader(
          title: 'Cadernos',
          subtitle: 'Gestão de Cadernos',
          showSearch: false,
        ),
        Expanded(
          child: DSCard(
            child: ResponsiveLayout(
              mobile: MobileWidget(viewModel: widget.viewModel),
              tablet: TabletWidget(viewModel: widget.viewModel),
              desktop: DesktopWidget(viewModel: widget.viewModel),
            ),
          ),
        ),
      ],
    );
  }
}
