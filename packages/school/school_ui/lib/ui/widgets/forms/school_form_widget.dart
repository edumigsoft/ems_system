import 'package:flutter/material.dart';
import 'package:zard_form/zard_form.dart';
import 'package:school_shared/school_shared.dart';
import 'package:design_system_shared/design_system_shared.dart';
import 'package:localizations_ui/localizations_ui.dart';

/// Widget de formulário compartilhado para criação e edição de escolas.
///
/// Pode ser usado em diferentes contextos (desktop, mobile, tablet)
/// com personalização via callbacks e flags.
class SchoolFormWidget extends StatefulWidget {
  /// Dados iniciais da escola para edição (null para criação)
  final SchoolDetails? initialData;

  /// Callback chamado quando o formulário é submetido com dados válidos
  final void Function(Map<String, dynamic> data) onSubmit;

  /// Callback opcional chamado quando o usuário cancela
  final VoidCallback? onCancel;

  /// Se deve mostrar o botão de cancelar
  final bool showCancelButton;

  /// Texto do botão de submissão (padrão: "Salvar")
  final String? submitButtonText;

  const SchoolFormWidget({
    super.key,
    this.initialData,
    required this.onSubmit,
    this.onCancel,
    this.showCancelButton = true,
    this.submitButtonText,
  });

  @override
  State<SchoolFormWidget> createState() => _SchoolFormWidgetState();
}

class _SchoolFormWidgetState extends State<SchoolFormWidget> {
  late ZForm<Map<String, dynamic>> _form;
  bool _isFormValid = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _form = useForm(
      resolver: zardResolver(SchoolDetailsValidator.schema),
      mode: ValidationMode.onChange,
      defaultValues: {
        schoolNameByField: widget.initialData?.name ?? '',
        schoolEmailByField: widget.initialData?.email ?? '',
        schoolAddressByField: widget.initialData?.address ?? '',
        schoolPhoneByField: widget.initialData?.phone ?? '',
        schoolCieByField: widget.initialData?.code ?? '',
      },
    );
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    _form.handleSubmit((data) async {
      widget.onSubmit(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ZFormBuilder(
      form: _form,
      builder: (context, state) {
        _isFormValid = state.isValid;
        _hasChanges = state.isDirty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nome da escola
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _form.register(schoolNameByField),
                decoration: InputDecoration(
                  labelText: l10n.name,
                  errorText: state.errors[schoolNameByField],
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
                controller: _form.register(schoolEmailByField),
                decoration: InputDecoration(
                  labelText: l10n.email,
                  errorText: state.errors[schoolEmailByField],
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
                controller: _form.register(schoolAddressByField),
                decoration: InputDecoration(
                  labelText: l10n.address,
                  errorText: state.errors[schoolAddressByField],
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
                controller: _form.register(schoolPhoneByField),
                decoration: InputDecoration(
                  labelText: l10n.phone,
                  errorText: state.errors[schoolPhoneByField],
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
                controller: _form.register(schoolCieByField),
                decoration: InputDecoration(
                  labelText: l10n.cie,
                  errorText: state.errors[schoolCieByField],
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
                  onPressed: _isFormValid && _hasChanges ? _handleSubmit : null,
                  child: Text(widget.submitButtonText ?? l10n.save),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
