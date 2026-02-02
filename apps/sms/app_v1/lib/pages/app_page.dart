import 'package:auth_ui/auth_ui.dart'
    show AuthViewModel, AuthGuard, AuthFlowPage;
import 'package:design_system_ui/design_system_ui.dart';
import 'package:core_ui/core_ui.dart' show ResponsiveLayout;
import 'package:flutter/material.dart';

import '../view_models/app_view_model.dart';
import 'desktop_page.dart';
import 'mobile_page.dart';
import 'tablet_page.dart';

class AppPage extends StatefulWidget {
  final AppViewModel viewModel;
  final AuthViewModel authViewModel;

  const AppPage({
    super.key,
    required this.viewModel,
    required this.authViewModel,
  });

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DSCard(
        margin: EdgeInsets.zero,
        isBorderRadius: false,
        child: ListenableBuilder(
          listenable: Listenable.merge([
            widget.viewModel,
            widget.authViewModel,
          ]),
          builder: (context, _) {
            return AuthGuard(
              authViewModel: widget.authViewModel,
              authenticatedChild: ResponsiveLayout(
                mobile: MobilePage(
                  viewModel: widget.viewModel,
                  authViewModel: widget.authViewModel,
                ),
                tablet: TabletPage(
                  viewModel: widget.viewModel,
                  authViewModel: widget.authViewModel,
                ),
                desktop: DesktopPage(
                  viewModel: widget.viewModel,
                  authViewModel: widget.authViewModel,
                ),
              ),
              unauthenticatedChild: AuthFlowPage(
                authViewModel: widget.authViewModel,
              ),
            );
          },
        ),
      ),
    );
  }
}
