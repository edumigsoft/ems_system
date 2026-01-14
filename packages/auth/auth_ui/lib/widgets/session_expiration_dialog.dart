import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart';
import '../view_models/auth_view_model.dart';

/// Diálogo que avisa sobre expiração iminente da sessão.
///
/// Exibido quando o token está prestes a expirar (5 minutos antes).
/// Oferece opções para renovar a sessão ou fazer logout.
class SessionExpirationDialog extends StatelessWidget {
  final AuthViewModel viewModel;

  const SessionExpirationDialog({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      icon: Icon(Icons.schedule, size: 48, color: theme.colorScheme.primary),
      title: Text(l10n.authSessionExpiringTitle),
      content: Text(l10n.authSessionExpiringMessage),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            viewModel.logout();
          },
          child: Text(l10n.authLogout),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final success = await viewModel.renewSession();

            if (!context.mounted) return;

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.authSessionRenewed),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.authSessionRenewalError),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Text(l10n.authRenewSession),
        ),
      ],
    );
  }
}
