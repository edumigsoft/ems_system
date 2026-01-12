import 'package:flutter/material.dart';

import '../zard_form.dart';

class ZFormBuilder extends StatelessWidget {
  final ZForm<dynamic> form;
  final Widget Function(BuildContext context, ZFormState formState) builder;

  const ZFormBuilder({
    super.key,
    required this.form,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: form,
      builder: (context, _) => builder(
        context,
        form.formState,
      ),
    );
  }
}
