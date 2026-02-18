import 'package:core_ui/core_ui.dart' show ResponsiveLayout;
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import '../view_models/tag_view_model.dart';
import '../widgets/components/mobile/mobile_widget.dart';
import '../widgets/components/tablet/tablet_widget.dart';
import '../widgets/components/desktop/desktop_widget.dart';

/// Página de listagem de tags.
///
/// Sem Scaffold/AppBar — usa DSCardHeader + DSCard + ResponsiveLayout.
/// Mobile: read-only. Tablet/Desktop: edição completa.
class TagListPage extends StatefulWidget {
  final TagViewModel viewModel;

  const TagListPage({
    required this.viewModel,
    super.key,
  });

  @override
  State<TagListPage> createState() => _TagListPageState();
}

class _TagListPageState extends State<TagListPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
    widget.viewModel.loadTags();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
      if (widget.viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.errorMessage!),
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
          title: 'Tags',
          subtitle: 'Gestão de Tags',
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
