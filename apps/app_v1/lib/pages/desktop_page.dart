import 'package:design_system_ui/widgets/ds_side_navigation.dart';
import 'package:flutter/material.dart';

import '../view_models/app_view_model.dart';

class DesktopPage extends StatefulWidget {
  final AppViewModel viewModel;

  const DesktopPage({super.key, required this.viewModel});

  @override
  State<DesktopPage> createState() => _DesktopPageState();
}

class _DesktopPageState extends State<DesktopPage> {
  @override
  void initState() {
    widget.viewModel.init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DSSideNavigation(
          selectedRoute: widget.viewModel.selectedRoute,
          onDestinationSelected: (route) => widget.viewModel.navigateTo(route),
          items: widget.viewModel.navigationItems,
          // userName: 'User Name',
          // userRole: 'User Role',
          // logo: Assets.images.schoolPilot.image(width: 52.0),
        ),
        Expanded(child: widget.viewModel.currentView),
      ],
    );
  }
}
