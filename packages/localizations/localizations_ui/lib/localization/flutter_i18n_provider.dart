import 'package:flutter/material.dart';
import 'package:localizations_shared/localizations_shared.dart';
import 'app_localizations_adapter.dart';

/// Provider de localização para Flutter UI.
/// Usa o sistema de localização nativo do Flutter.
class FlutterI18nProvider implements I18nProvider {
  final BuildContext context;

  FlutterI18nProvider(this.context);

  @override
  I18nStrings getStrings(LocaleData locale) {
    // Retorna o adapter que implementa I18nStrings
    return AppLocalizationsAdapter.of(context);
  }

  @override
  LocaleData get currentLocale {
    final locale = Localizations.localeOf(context);
    return LocaleData(locale.languageCode, locale.countryCode);
  }

  @override
  List<LocaleData> get supportedLocales => LocaleData.supportedLocales;
}
