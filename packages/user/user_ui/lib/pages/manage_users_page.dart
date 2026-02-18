import 'package:core_ui/core_ui.dart' show ResponsiveLayout;
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import '../view_models/manage_users_view_model.dart';
import '../ui/widgets/components/mobile/mobile_widget.dart';
import '../ui/widgets/components/tablet/tablet_widget.dart';
import '../ui/widgets/components/desktop/desktop_widget.dart';

/// Página de Gerenciamento de Usuários (Admin).
///
/// Sem Scaffold/AppBar — usa DSCardHeader + DSCard + ResponsiveLayout.
/// Mobile: read-only. Tablet/Desktop: edição completa.
class ManageUsersPage extends StatefulWidget {
  final ManageUsersViewModel viewModel;

  const ManageUsersPage({super.key, required this.viewModel});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.initialize();
      widget.viewModel.loadUsers(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Column(
          children: [
            const DSCardHeader(
              title: 'Gerenciar Usuários',
              subtitle: 'Gestão de Usuários',
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
      },
    );
  }
}
