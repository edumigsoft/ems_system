import 'package:design_system_ui/design_system_ui.dart';
import 'desktop_page.dart';
import 'mobile_page.dart';
import 'tablet_page.dart';
import '../view_models/app_view_model.dart';
import 'package:core_ui/core_ui.dart' show ResponsiveLayout;
import 'package:flutter/material.dart';

class AppPage extends StatefulWidget {
  final AppViewModel viewModel;
  const AppPage({super.key, required this.viewModel});

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
          listenable: widget.viewModel,
          builder: (context, _) {
            return ResponsiveLayout(
              mobile: MobilePage(viewModel: widget.viewModel),
              tablet: TabletPage(viewModel: widget.viewModel),
              desktop: DesktopPage(viewModel: widget.viewModel),
            );
          },
        ),
      ),
    );
  }
}
