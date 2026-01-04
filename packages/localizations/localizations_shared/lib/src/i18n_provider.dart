import 'i18n_strings.dart';
import 'locale_data.dart';

abstract class I18nProvider {
  I18nStrings getStrings(LocaleData locale);
  LocaleData get currentLocale;
  List<LocaleData> get supportedLocales;
}
