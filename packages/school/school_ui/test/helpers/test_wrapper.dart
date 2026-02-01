import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localizations_ui/localizations_ui.dart';
import 'package:core_shared/core_shared.dart';

Future<void> initTestServices() async {
  await LogService.init(LogLevel.error);
}

Widget wrapWithMaterial(Widget widget) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('pt', 'BR'),
      Locale('en', 'US'),
    ],
    locale: const Locale('pt', 'BR'),
    home: Scaffold(body: widget),
  );
}
