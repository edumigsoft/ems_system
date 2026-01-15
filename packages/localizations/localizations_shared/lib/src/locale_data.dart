class LocaleData {
  final String languageCode;
  final String? countryCode;
  final String label;

  const LocaleData(this.languageCode, [this.countryCode, this.label = '']);

  String get code =>
      countryCode != null ? '${languageCode}_$countryCode' : languageCode;

  static const List<LocaleData> supportedLocales = [
    LocaleData('pt', 'BR', 'Português (Brasil)'),
    LocaleData('en', 'US', 'English (US)'),
    LocaleData('es', 'ES', 'Español'),
  ];
}
