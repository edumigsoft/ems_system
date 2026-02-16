import 'package:auth_ui/auth_ui.dart' show AuthViewModel;
import '../view_models/app_view_model.dart';
import 'package:flutter/material.dart';

class MobilePage extends StatelessWidget {
  final AppViewModel viewModel;
  final AuthViewModel authViewModel;

  const MobilePage({
    super.key,
    required this.viewModel,
    required this.authViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: viewModel.currentView,
      bottomNavigationBar: BottomNavigationBar(
        items: viewModel.flatVisibleNavigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.labelBuilder(context),
          );
        }).toList(),
        currentIndex: _getSelectedIndex(context),
        onTap: (index) {
          if (index >= 0 && index < viewModel.flatVisibleNavigationItems.length) {
            final item = viewModel.flatVisibleNavigationItems[index];
            if (item.hasRoute) {
              viewModel.navigateTo(item.route!);
            }
          }
        },
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final index = viewModel.flatVisibleNavigationItems.indexWhere(
      (item) => item.route == viewModel.selectedRoute,
    );
    return index != -1 ? index : 0; // Proteção para rota não encontrada
  }
}
