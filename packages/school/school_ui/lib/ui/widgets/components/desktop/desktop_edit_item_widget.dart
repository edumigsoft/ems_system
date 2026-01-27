import 'dart:developer';

import 'package:core_shared/core_shared.dart'
    show Failure, DataException, Success;
import 'package:design_system_shared/design_system_shared.dart';
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart';
import 'package:school_shared/school_shared.dart'
    show
        SchoolDetailsValidator,
        schoolNameByField,
        schoolEmailByField,
        schoolAddressByField,
        schoolPhoneByField,
        schoolCieByField,
        SchoolStatus;
import '../../../../school_ui.dart';
import 'package:zard_form/zard_form.dart';

class DesktopEditItemWidget extends StatefulWidget {
  final SchoolViewModel viewModel;

  const DesktopEditItemWidget({super.key, required this.viewModel});

  @override
  State<DesktopEditItemWidget> createState() => _DesktopEditItemWidgetState();
}

class _DesktopEditItemWidgetState extends State<DesktopEditItemWidget> {
  late ZForm<Map<String, dynamic>> form;
  bool _isValid = false;
  Map<String, dynamic>? _lastSubmittedData;

  @override
  void initState() {
    super.initState();
    final school = widget.viewModel.details!;
    form = useForm(
      resolver: zardResolver(SchoolDetailsValidator.schema),
      mode: ValidationMode.onChange,
      defaultValues: {
        'name': school.name,
        'email': school.email,
        'address': school.address,
        'phone': school.phone,
        'code': school.code,
        'location_city': school.locationCity,
        'location_district': school.locationDistrict,
        'director': school.director,
        'status': school.status,
      },
    );

    _init();

    widget.viewModel.saveCommand.addListener(listener);
  }

  @override
  void dispose() {
    widget.viewModel.saveCommand.removeListener(listener);
    form.dispose();

    super.dispose();
  }

  Future<void> _init() async {
    final isValid = await form.handleValid();
    if (!mounted) return;

    if (_isValid != isValid) {
      setState(() {
        _isValid = isValid;
      });
    }

    widget.viewModel.canSaved(isValid);
  }

  Future<void> onValid(dynamic data) async {
    log('Form valid: $data');

    widget.viewModel.details = widget.viewModel.details!.copyWith(
      name: (data as Map<String, dynamic>)['name'] as String?,
      address: data['address'] as String?,
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      code: data['code'] as String?,
      locationCity: data['location_city'] as String?,
      locationDistrict: data['location_district'] as String?,
      director: data['director'] as String?,
      status: data['status'] as SchoolStatus?,
    );

    _lastSubmittedData = Map<String, dynamic>.from(data as Map);

    widget.viewModel.canSaved(true);
  }

  bool _hasDataChanged(Map<String, dynamic> currentData) {
    if (_lastSubmittedData == null) return true;

    return currentData['name'] != _lastSubmittedData!['name'] ||
        currentData['email'] != _lastSubmittedData!['email'] ||
        currentData['address'] != _lastSubmittedData!['address'] ||
        currentData['phone'] != _lastSubmittedData!['phone'] ||
        currentData['cie'] != _lastSubmittedData!['cie'];
  }

  void _handleValidationChange(bool isValid, Map<String, dynamic> formData) {
    if (!isValid) {
      widget.viewModel.canSaved(false);
      return;
    }

    // Only update/submit if data actually changed to avoid infinite loops
    if (_hasDataChanged(formData)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (_isValid != isValid) {
          setState(() {
            _isValid = isValid;
          });
        }

        form.handleSubmit(onValid);
      });
    } else {
      // If valid but data didn't change, still ensure viewModel reports canSaved = true
      widget.viewModel.canSaved(true);
    }
  }

  void listener() {
    if (!mounted) return;

    final result = widget.viewModel.saveCommand.result;

    if (result is Failure) {
      final error = (result as Failure).error;
      final message = error is DataException ? error.message : error.toString();
      DSAlert.error(context, message: message);
    }

    if (result is Success) {
      DSAlert.success(
        context,
        message: AppLocalizations.of(context).savedSuccessfully,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZFormBuilder(
      form: form,
      builder: (context, state) {
        _handleValidationChange(state.isValid, form.values);

        return Padding(
          padding: const EdgeInsets.all(DSPaddings.xLarge),
          child: Column(
            spacing: 16,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: form.register(schoolNameByField),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).name,
                    errorText: state.errors[schoolNameByField],
                    hintText: AppLocalizations.of(
                      context,
                    ).theNameCannotBeEmpty,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: form.register(schoolEmailByField),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).email,
                    errorText: state.errors[schoolEmailByField],
                    hintText: AppLocalizations.of(context).cannotBeEmpty,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: form.register(schoolAddressByField),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).address,
                    errorText: state.errors[schoolAddressByField],
                    hintText: AppLocalizations.of(context).cannotBeEmpty,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: form.register(schoolPhoneByField),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).phone,
                    errorText: state.errors[schoolPhoneByField],
                    hintText: AppLocalizations.of(context).cannotBeEmpty,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: form.register(schoolCieByField),
                  decoration: InputDecoration(
                    labelText: /*AppLocalizations.of(context)!.cie*/ 'CIE',
                    errorText: state.errors[schoolCieByField],
                    hintText: AppLocalizations.of(context).cannotBeEmpty,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.business),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
