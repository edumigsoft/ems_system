import 'package:flutter/material.dart';
import '../../../../school_ui.dart';

class TabletWidget extends StatelessWidget {
  final SchoolViewModel viewModel;
  const TabletWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('School Tablet')),
      body: Container(),
    );
  }
}
