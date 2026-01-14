import 'package:auth_ui/auth_ui.dart' show AuthViewModel;
import 'package:design_system_ui/widgets/ds_side_navigation.dart';
import 'package:flutter/material.dart';

import '../view_models/app_view_model.dart';

class DesktopPage extends StatefulWidget {
  final AppViewModel viewModel;
  final AuthViewModel authViewModel;

  const DesktopPage({
    super.key,
    required this.viewModel,
    required this.authViewModel,
  });

  @override
  State<DesktopPage> createState() => _DesktopPageState();
}

class _DesktopPageState extends State<DesktopPage> {
  /// Handler para logout com confirmação.
  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar saída'),
        content: const Text('Deseja realmente sair do sistema?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.authViewModel.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.authViewModel.currentUser;

    return Row(
      children: [
        DSSideNavigation(
          selectedRoute: widget.viewModel.selectedRoute,
          onDestinationSelected: (route) => widget.viewModel.navigateTo(route),
          items: widget.viewModel.navigationItems,
          userName: currentUser?.name,
          userRole: currentUser?.role.name.toUpperCase(),
          userAvatarUrl: currentUser?.avatarUrl,
          onLogout: () => _handleLogout(context),
          // logo: Assets.images.schoolPilot.image(width: 52.0),
        ),
        Expanded(child: widget.viewModel.currentView),
      ],
    );
  }
}
