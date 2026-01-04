// import 'package:design_system_shared/design_system_shared.dart';
// import 'package:design_system_ui/theme/ds_theme.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.dark);

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: _themeMode,
//       builder: (context, value, child) {
//         return MaterialApp(
//           title: 'App Design Draft',
//           theme: DSTheme.fromConfig(
//             config: AppThemeConfig.greenTheme,
//             brightness: Brightness.light,
//           ),
//           darkTheme: DSTheme.fromConfig(
//             config: AppThemeConfig.tealTheme,
//             brightness: Brightness.dark,
//           ),
//           themeMode: value,
//           home: const MyHomePage(),
//         );
//       },
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text('App Design Draft'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: .center,
//           children: [
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             const SizedBox(height: 56),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _themeMode.value = _themeMode.value == ThemeMode.dark
//                       ? ThemeMode.light
//                       : ThemeMode.dark;
//                 });
//               },
//               child: const Text('ThemeMode'),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

import 'package:design_system_ui/theme/ds_theme.dart';
import 'package:design_system_ui/theme/ds_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:design_system_ui/design_system_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String _selectedTheme = 'default';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Design System Demo',
      debugShowCheckedModeBanner: false,

      // Temas personalizados
      theme: _getTheme(Brightness.light),
      darkTheme: _getTheme(Brightness.dark),
      themeMode: _themeMode,

      home: HomePage(
        onThemeChange: _handleThemeChange,
        onThemeModeChange: _handleThemeModeChange,
        currentTheme: _selectedTheme,
        currentThemeMode: _themeMode,
      ),
    );
  }

  ThemeData _getTheme(Brightness brightness) {
    switch (_selectedTheme) {
      case 'blue':
        return DSTheme.custom(
          seedColor: const Color(0xFF1976D2),
          brightness: brightness,
          cardBackground: brightness == Brightness.light
              ? const Color(0xFFE3F2FD)
              : const Color(0xFF1E1E2E),
          cardBorder: brightness == Brightness.light
              ? const Color(0xFFBBDEFB)
              : const Color(0xFF2C3E50),
        );

      case 'green':
        return DSTheme.custom(
          seedColor: const Color(0xFF388E3C),
          brightness: brightness,
          cardBackground: brightness == Brightness.light
              ? const Color(0xFFE8F5E9)
              : const Color(0xFF1E2E1E),
          cardBorder: brightness == Brightness.light
              ? const Color(0xFFC8E6C9)
              : const Color(0xFF2C4A2C),
        );

      case 'purple':
        return DSTheme.custom(
          seedColor: const Color(0xFF9C27B0),
          brightness: brightness,
          cardBackground: brightness == Brightness.light
              ? const Color(0xFFF3E5F5)
              : const Color(0xFF2E1E2E),
          cardBorder: brightness == Brightness.light
              ? const Color(0xFFE1BEE7)
              : const Color(0xFF4A2C4A),
        );

      default:
        return brightness == Brightness.light
            ? DSTheme.light()
            : DSTheme.dark();
    }
  }

  void _handleThemeChange(String theme) {
    setState(() {
      _selectedTheme = theme;
    });
  }

  void _handleThemeModeChange(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }
}

class HomePage extends StatelessWidget {
  final Function(String) onThemeChange;
  final Function(ThemeMode) onThemeModeChange;
  final String currentTheme;
  final ThemeMode currentThemeMode;

  const HomePage({
    super.key,
    required this.onThemeChange,
    required this.onThemeModeChange,
    required this.currentTheme,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Demo'),
        actions: [
          IconButton(
            icon: Icon(
              currentThemeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              onThemeModeChange(
                currentThemeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Selector
          _buildThemeSelector(context),

          const SizedBox(height: 24),

          // Dashboard Section
          _buildSectionTitle(context, 'Dashboard - DSInfoCard'),
          _buildDashboard(context),

          const SizedBox(height: 24),

          // Actions Section
          _buildSectionTitle(context, 'Ações Rápidas - DSActionCard'),
          _buildQuickActions(context),

          const SizedBox(height: 24),

          // Standard Cards Section
          _buildSectionTitle(context, 'Cards Padrão - DSCard'),
          _buildStandardCards(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showBottomSheet(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Ação'),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final themes = {
      'default': 'Padrão',
      'blue': 'Azul',
      'green': 'Verde',
      'purple': 'Roxo',
    };

    return DSCard(
      title: 'Tema Atual',
      subtitle: 'Selecione um tema personalizado',
      leading: Icon(Icons.palette, color: context.dsColors.primary),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: themes.entries.map((entry) {
          final isSelected = currentTheme == entry.key;
          return ChoiceChip(
            label: Text(entry.value),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                onThemeChange(entry.key);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: context.dsTextStyles.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DSInfoCard(
                icon: Icons.people,
                title: 'Usuários',
                value: '1,234',
                onTap: () => _showSnackBar(context, 'Usuários clicado'),
                footer: '↑ +12% este mês',
                trendIcon: Icons.trending_up,
                trendColor: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DSInfoCard(
                icon: Icons.attach_money,
                title: 'Receita',
                value: 'R\$ 45.2K',
                iconColor: Colors.orange,
                onTap: () => _showSnackBar(context, 'Receita clicado'),
                footer: '↓ -5% este mês',
                trendIcon: Icons.trending_down,
                trendColor: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DSInfoCard(
                icon: Icons.shopping_cart,
                title: 'Pedidos',
                value: '892',
                iconColor: Colors.purple,
                onTap: () => _showSnackBar(context, 'Pedidos clicado'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DSInfoCard(
                icon: Icons.star,
                title: 'Avaliação',
                value: '4.8',
                iconColor: Colors.amber,
                onTap: () => _showSnackBar(context, 'Avaliação clicado'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        DSActionCard(
          icon: Icons.settings,
          title: 'Configurações',
          description: 'Gerencie as configurações do sistema',
          onTap: () => _showSnackBar(context, 'Configurações'),
        ),
        DSActionCard(
          icon: Icons.notifications,
          title: 'Notificações',
          description: 'Ver todas as notificações pendentes',
          onTap: () => _showSnackBar(context, 'Notificações'),
          accentColor: Colors.orange,
        ),
        DSActionCard(
          icon: Icons.mail,
          title: 'Mensagens',
          description: 'Acessar caixa de entrada',
          onTap: () => _showSnackBar(context, 'Mensagens'),
          accentColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStandardCards(BuildContext context) {
    return Column(
      children: [
        DSCard(
          title: 'Card com Actions',
          subtitle: 'Exemplo com botões de ação',
          leading: Icon(Icons.calendar_today, color: context.dsColors.primary),
          actions: [
            TextButton(
              onPressed: () => _showSnackBar(context, 'Cancelar'),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => _showSnackBar(context, 'Confirmar'),
              child: const Text('Confirmar'),
            ),
          ],
          child: const Text(
            'Cards podem ter botões de ação no rodapé. '
            'Os eventos são isolados para não conflitar com o onClick do card.',
          ),
        ),
        DSCard(
          title: 'Card Interativo',
          subtitle: 'Clique para ver o efeito',
          leading: const Icon(Icons.favorite, color: Colors.pink),
          trailing: const Icon(Icons.star, color: Colors.amber),
          onTap: () => _showSnackBar(context, 'Card Interativo clicado'),
          child: const Text('Este card tem hover effect e é clicável.'),
        ),
        DSCard(
          title: 'Card Desabilitado',
          subtitle: 'Não é clicável',
          isDisabled: true,
          leading: const Icon(Icons.lock),
          onTap: () => _showSnackBar(context, 'Não deveria aparecer'),
          child: const Text(
            'Este card está desabilitado e não responde a cliques.',
          ),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nova Ação', style: context.dsTextStyles.titleLarge),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Título',
                hintText: 'Digite o título',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Descrição',
                hintText: 'Digite a descrição',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar(context, 'Ação criada com sucesso!');
                  },
                  child: const Text('Criar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
