import 'package:ems_app_design_draft/my_app.dart';
import 'package:design_system_shared/design_system_shared.dart';
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Design Draft',
      debugShowCheckedModeBanner: false,
      // Temas personalizados
      theme: DSTheme.forPreset(DSThemeEnum.acqua, Brightness.light),
      darkTheme: DSTheme.forPreset(DSThemeEnum.acqua, Brightness.dark),
      themeMode: ThemeMode.dark,
      home: MyApp(),
    );
  }
}
