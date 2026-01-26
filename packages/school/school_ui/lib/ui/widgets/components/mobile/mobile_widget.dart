import 'package:flutter/material.dart';
import '../../../../school_ui.dart';

class MobileWidget extends StatelessWidget {
  final SchoolViewModel viewModel;
  const MobileWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('School Mobile')),
      body: Container(),
    );
  }
}
