import 'package:design_system_ui/design_system_ui.dart';
import 'package:design_system_ui/widgets/ds_side_navigation.dart';
import 'package:flutter/material.dart';

import '../view_models/app_view_model.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  final AppViewModel _viewModel = AppViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return DSCard(
          margin: EdgeInsets.zero,
          isBorderRadius: false,
          child: Row(
            children: [
              DSSideNavigation(
                selectedRoute: _viewModel.selectedRoute,
                onDestinationSelected: (route) => _viewModel.navigateTo(route),
                items: _viewModel.navigationItems,
                userName: "Usuário",
                // userRole: user?.roles.map((e) => e.description).join('\n'),
                // logo: Assets.images.schoolPilot.image(width: 52.0),
              ),
              Expanded(
                child: _viewModel.currentView,
              ),
            ],
          ),
        );
      },
    );
  }
}
