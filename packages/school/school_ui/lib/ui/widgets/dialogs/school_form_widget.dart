import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart' show Success, Failure;
import 'package:school_shared/school_shared.dart';
import 'package:design_system_shared/design_system_shared.dart';
import 'package:localizations_ui/localizations_ui.dart';
import '../../view_models/school_form_view_model.dart';

/// Widget de formulário para criação e edição de escolas.
///
/// Utiliza [SchoolFormViewModel] internamente para gerenciamento de estado
/// e validação de formulários.
///
/// **BREAKING CHANGE (v2.0.0):**
/// - Agora recebe `CreateUseCase` e `UpdateUseCase` ao invés de callback `onSubmit`
/// - Callbacks mudaram de `onSubmit(Map)` para `onSuccess(SchoolDetails)` e `onError(Exception)`
///
/// **Migração:**
/// ```dart
/// // Antes
/// SchoolFormWidget(
///   onSubmit: (data) {
///     // processar data
///   },
/// )
///
/// // Depois
/// SchoolFormWidget(
///   createUseCase: createUseCase,
///   updateUseCase: updateUseCase,
///   onSuccess: (school) {
///     // school já é SchoolDetails validado
///   },
/// )
/// ```
class SchoolFormWidget extends StatefulWidget {
  /// UseCase para criação de escolas
  final CreateUseCase createUseCase;

  /// UseCase para atualização de escolas
  final UpdateUseCase updateUseCase;

  /// Dados iniciais da escola para edição (null para criação)
  final SchoolDetails? initialData;

  /// Callback chamado quando a operação é bem-sucedida
  final void Function(SchoolDetails school)? onSuccess;

  /// Callback chamado quando ocorre um erro
  final void Function(Exception error)? onError;

  /// Callback opcional chamado quando o usuário cancela
  final VoidCallback? onCancel;

  /// Se deve mostrar o botão de cancelar
  final bool showCancelButton;

  /// Texto do botão de submissão (padrão: "Salvar")
  final String? submitButtonText;

  const SchoolFormWidget({
    super.key,
    required this.createUseCase,
    required this.updateUseCase,
    this.initialData,
    this.onSuccess,
    this.onError,
    this.onCancel,
    this.showCancelButton = true,
    this.submitButtonText,
  });

  @override
  State<SchoolFormWidget> createState() => _SchoolFormWidgetState();
}

class _SchoolFormWidgetState extends State<SchoolFormWidget> {
  late SchoolFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SchoolFormViewModel(
      createUseCase: widget.createUseCase,
      updateUseCase: widget.updateUseCase,
      initialData: widget.initialData,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final result = await _viewModel.submit();

    if (!mounted) return;

    if (result case Success(:final value)) {
      widget.onSuccess?.call(value);
    } else if (result case Failure(:final error)) {
      widget.onError?.call(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nome da escola
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _viewModel.registerField(schoolNameByField),
                decoration: InputDecoration(
                  labelText: l10n.name,
                  errorText: _viewModel.getFieldError(schoolNameByField),
                  hintText: l10n.theNameCannotBeEmpty,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.school),
                ),
              ),
            ),

            // Email
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _viewModel.registerField(schoolEmailByField),
                decoration: InputDecoration(
                  labelText: l10n.email,
                  errorText: _viewModel.getFieldError(schoolEmailByField),
                  hintText: l10n.cannotBeEmpty,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),

            // Endereço
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _viewModel.registerField(schoolAddressByField),
                decoration: InputDecoration(
                  labelText: l10n.address,
                  errorText: _viewModel.getFieldError(schoolAddressByField),
                  hintText: l10n.cannotBeEmpty,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
            ),

            // Telefone
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _viewModel.registerField(schoolPhoneByField),
                decoration: InputDecoration(
                  labelText: l10n.phone,
                  errorText: _viewModel.getFieldError(schoolPhoneByField),
                  hintText: l10n.cannotBeEmpty,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),

            // Código/CIE
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _viewModel.registerField(schoolCieByField),
                decoration: InputDecoration(
                  labelText: l10n.cie,
                  errorText: _viewModel.getFieldError(schoolCieByField),
                  hintText: l10n.cannotBeEmpty,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.business),
                ),
              ),
            ),

            const SizedBox(height: DSSpacing.medium),

            // Botões de ação
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.showCancelButton && widget.onCancel != null) ...[
                  TextButton(
                    onPressed: widget.onCancel,
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: DSSpacing.small),
                ],
                ElevatedButton(
                  onPressed: _viewModel.isSubmitting
                      ? null
                      : (_viewModel.isFormValid && _viewModel.isFormDirty
                            ? _handleSubmit
                            : null),
                  child: _viewModel.isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.submitButtonText ?? l10n.save),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
