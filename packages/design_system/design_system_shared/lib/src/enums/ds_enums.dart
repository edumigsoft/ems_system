enum DSThemeEnum {
  system,
  lolo,
  teal,
  blueGray,
  acqua,
}

extension DSThemeEnumLabel on DSThemeEnum {
  String get label {
    return switch (this) {
      DSThemeEnum.system => 'Padrão do Sistema',
      DSThemeEnum.acqua => 'Acqua',
      DSThemeEnum.blueGray => 'Blue Gray',
      DSThemeEnum.teal => 'Teal',
      DSThemeEnum.lolo => 'Lolo',
    };
  }
}
