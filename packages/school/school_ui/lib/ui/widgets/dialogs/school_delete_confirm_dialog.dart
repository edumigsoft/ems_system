import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart';

class SchoolDeleteConfirmDialog extends StatelessWidget {
  final String schoolName;

  const SchoolDeleteConfirmDialog({
    super.key,
    required this.schoolName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.confirmDeletion),
      content: Text(
        '${l10n.schoolDeleteConfirm} "$schoolName"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.delete),
        ),
      ],
    );
  }
}
