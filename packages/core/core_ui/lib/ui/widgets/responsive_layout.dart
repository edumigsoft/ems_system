import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthMedia = MediaQuery.of(context).size.width;

        if (widthMedia >= 900) {
          return desktop;
        }

        if (widthMedia >= 600) {
          return tablet;
        }

        if (widthMedia < 600) {
          return mobile;
        }

        return const Center(child: Text('Undefined Layout'));
      },
    );
  }
}
