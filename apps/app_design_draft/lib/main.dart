import 'package:design_system_shared/design_system_shared.dart';
import 'package:design_system_ui/theme/ds_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.dark);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _themeMode,
      builder: (context, value, child) {
        return MaterialApp(
          title: 'App Design Draft',
          theme: DSTheme.fromConfig(
            config: AppThemeConfig.greenTheme,
            brightness: Brightness.light,
          ),
          darkTheme: DSTheme.fromConfig(
            config: AppThemeConfig.tealTheme,
            brightness: Brightness.dark,
          ),
          themeMode: value,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('App Design Draft'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 56),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _themeMode.value = _themeMode.value == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                });
              },
              child: const Text('ThemeMode'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
