import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart';

class SchoolRestoreConfirmDialog extends StatelessWidget {
  final String schoolName;

  const SchoolRestoreConfirmDialog({
    super.key,
    required this.schoolName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.confirmsRestoration),
      content: Text(
        '${l10n.schoolRestoreConfirm} "$schoolName"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.restore),
        ),
      ],
    );
  }
}
