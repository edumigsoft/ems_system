import 'package:localizations_shared/localizations_shared.dart';

import 'strings/en_us_strings.dart';
import 'strings/es_es_strings.dart';
import 'strings/pt_br_strings.dart';

class ServerI18nProvider implements I18nProvider {
  final Map<String, I18nStrings> _translations = {
    'pt_BR': const PtBrStrings(),
    'pt': const PtBrStrings(), // fallback
    'en_US': const EnUsStrings(),
    'en': const EnUsStrings(), // fallback
    'es_ES': const EsEsStrings(),
    'es': const EsEsStrings(), // fallback
  };

  LocaleData _currentLocale = const LocaleData('pt', 'BR');

  @override
  I18nStrings getStrings(LocaleData locale) {
    final key = locale.code;
    return _translations[key] ??
        _translations[locale.languageCode] ??
        _translations['en_US']!;
  }

  @override
  LocaleData get currentLocale => _currentLocale;

  @override
  List<LocaleData> get supportedLocales => LocaleData.supportedLocales;

  /// Define o locale atual
  void setLocale(LocaleData locale) {
    _currentLocale = locale;
  }
}
