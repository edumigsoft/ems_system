import 'package:auth_ui/auth_ui.dart' show AuthViewModel;
import 'package:flutter/material.dart';

import '../view_models/app_view_model.dart';

class TabletPage extends StatelessWidget {
  final AppViewModel viewModel;
  final AuthViewModel authViewModel;

  const TabletPage({
    super.key,
    required this.viewModel,
    required this.authViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            // leading: Assets.images.schoolPilot.image(width: 80.0),
            selectedIndex: _getSelectedIndex(context),
            onDestinationSelected: (index) {
              if (index >= 0 &&
                  index < viewModel.flatVisibleNavigationItems.length) {
                final item = viewModel.flatVisibleNavigationItems[index];
                if (item.hasRoute) {
                  viewModel.navigateTo(item.route!);
                }
              }
            },
            labelType: NavigationRailLabelType.selected,
            destinations: viewModel.flatVisibleNavigationItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                label: Text(item.labelBuilder(context)),
              );
            }).toList(),
          ),
          Expanded(child: viewModel.currentView),
        ],
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final index = viewModel.flatVisibleNavigationItems.indexWhere(
      (item) => item.route == viewModel.selectedRoute,
    );
    return index != -1 ? index : 0;
  }
}
