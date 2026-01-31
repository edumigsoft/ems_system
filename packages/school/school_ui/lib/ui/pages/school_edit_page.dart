import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_shared/school_shared.dart';
import 'package:design_system_shared/design_system_shared.dart';
import 'package:design_system_ui/design_system_ui.dart';
import 'package:localizations_ui/localizations_ui.dart';
import '../view_models/school_view_model.dart';
import '../widgets/forms/school_form_widget.dart';

/// Página de edição de escola para dispositivos móveis e tablet.
///
/// Recebe uma [SchoolDetails] e permite editar seus dados.
/// Retorna `true` se a edição foi bem-sucedida, `false` ou `null` caso contrário.
class SchoolEditPage extends StatelessWidget {
  final SchoolDetails school;

  const SchoolEditPage({
    super.key,
    required this.school,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = context.watch<SchoolViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editSchool),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DSPaddings.large),
        child: SchoolFormWidget(
          createUseCase: viewModel.createUseCase,
          updateUseCase: viewModel.updateUseCase,
          initialData: school,
          showCancelButton: false,
          onSuccess: (updatedSchool) {
            DSAlert.success(
              context,
              message: l10n.savedSuccessfully,
            );
            Navigator.of(context).pop(true);
          },
          onError: (error) {
            DSAlert.error(
              context,
              message: error.toString(),
            );
          },
        ),
      ),
    );
  }
}
