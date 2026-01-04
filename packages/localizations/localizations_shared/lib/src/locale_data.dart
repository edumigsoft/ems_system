class LocaleData {
  final String languageCode;
  final String? countryCode;

  const LocaleData(this.languageCode, [this.countryCode]);

  String get code =>
      countryCode != null ? '${languageCode}_$countryCode' : languageCode;
}
