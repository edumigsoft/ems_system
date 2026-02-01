import 'package:flutter/material.dart';
import 'package:school_shared/school_shared.dart';
import 'package:design_system_shared/design_system_shared.dart';
import 'package:localizations_ui/localizations_ui.dart';
import 'school_form_widget.dart';

/// Diálogo que envolve o [SchoolFormWidget] para criação ou edição de escolas.
class SchoolFormDialog extends StatelessWidget {
  /// UseCase para criação de escolas
  final CreateUseCase createUseCase;

  /// UseCase para atualização de escolas
  final UpdateUseCase updateUseCase;

  /// Dados iniciais da escola para edição (null para criação)
  final SchoolDetails? initialData;

  const SchoolFormDialog({
    super.key,
    required this.createUseCase,
    required this.updateUseCase,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = initialData != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSRadius.medium),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 800, // Limite de altura condizente com 90vh aprox.
        ),
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? l10n.editSchool : l10n.createSchool,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: DSSpacing.medium),

              // Formulário com Scroll
              Flexible(
                child: SingleChildScrollView(
                  child: SchoolFormWidget(
                    createUseCase: createUseCase,
                    updateUseCase: updateUseCase,
                    initialData: initialData,
                    onSuccess: (school) => Navigator.of(context).pop(school),
                    onCancel: () => Navigator.of(context).pop(),
                    showCancelButton: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
