import 'package:core_ui/core_ui.dart';
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
// import 'package:localizations_ui/localizations_ui.dart';
import '../../school_ui.dart';

class SchoolPage extends StatefulWidget {
  final SchoolViewModel viewModel;
  const SchoolPage({super.key, required this.viewModel});

  @override
  State<SchoolPage> createState() => _SchoolPageState();
}

class _SchoolPageState extends State<SchoolPage> {
  @override
  void initState() {
    widget.viewModel.init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Column(
          children: [
            const DSCardHeader(
              title: /*AppLocalizations.of(context)!.schools*/ 'Escolas',
              subtitle: /*AppLocalizations.of(context)!.schoolManagement*/
                  'Gestão de Escolas',
              showSearch: false,
              notificationCount: 1,
            ),
            Expanded(
              child: DSCard(
                // boxShadow: DSShadows.cardExtraSmall,
                // margin: DSPaddings.extraSmall,
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
