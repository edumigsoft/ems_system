import '../view_models/app_view_model.dart';
import 'package:flutter/material.dart';

class MobilePage extends StatelessWidget {
  final AppViewModel viewModel;

  const MobilePage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: viewModel.currentView,
      bottomNavigationBar: BottomNavigationBar(
        items: viewModel.navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.labelBuilder(context),
          );
        }).toList(),
        currentIndex: _getSelectedIndex(context),
        onTap: (index) {
          if (index >= 0 && index < viewModel.navigationItems.length) {
            final item = viewModel.navigationItems[index];
            if (item.hasRoute) {
              viewModel.navigateTo(item.route!);
            }
          }
        },
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final index = viewModel.navigationItems.indexWhere(
      (item) => item.route == viewModel.selectedRoute,
    );
    return index != -1 ? index : 0; // Proteção para rota não encontrada
  }
}
