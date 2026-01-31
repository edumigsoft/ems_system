import 'package:flutter/material.dart';
import 'package:localizations_shared/localizations_shared.dart';
import 'app_localizations.dart'; // Arquivo gerado pelo flutter gen-l10n

/// Adapter que faz o AppLocalizations (gerado) implementar I18nStrings.
///
/// Como o AppLocalizations é gerado automaticamente e não podemos
/// modificá-lo diretamente, este adapter serve de ponte entre o
/// código gerado e nossa interface I18nStrings.
class AppLocalizationsAdapter implements I18nStrings {
  final AppLocalizations _delegate;

  const AppLocalizationsAdapter(this._delegate);

  /// Factory para criar a partir do context
  factory AppLocalizationsAdapter.of(BuildContext context) {
    return AppLocalizationsAdapter(AppLocalizations.of(context));
  }

  // ========== Delegação para AppLocalizations ==========

  @override
  String get appName => _delegate.appName;

  @override
  String get welcomeMessage => _delegate.welcomeMessage;

  @override
  String get errorGeneric => _delegate.errorGeneric;

  @override
  String loginError(String reason) => _delegate.loginError(reason);

  @override
  String serverErrorLog(String error) => _delegate.serverErrorLog(error);

  @override
  String emailSubjectWelcome(String userName) =>
      _delegate.emailSubjectWelcome(userName);

  @override
  String itemCount(int count) => _delegate.itemCount(count);

  @override
  String lastUpdated(DateTime date) => _delegate.lastUpdated(date);

  @override
  String get buttonSave => _delegate.buttonSave;

  @override
  String get buttonCancel => _delegate.buttonCancel;

  @override
  String get buttonConfirm => _delegate.buttonConfirm;

  @override
  String get buttonDelete => _delegate.buttonDelete;

  @override
  String get validationEmailInvalid => _delegate.validationEmailInvalid;

  @override
  String get validationPasswordTooShort => _delegate.validationPasswordTooShort;

  @override
  String get validationRequired => _delegate.validationRequired;

  @override
  String get school => _delegate.school;

  @override
  String get schools => _delegate.schools;

  @override
  String get editSchool => _delegate.editSchool;

  @override
  String get createSchool => _delegate.createSchool;

  @override
  String get cie => _delegate.cie;
}
