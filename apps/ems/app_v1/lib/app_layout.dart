import 'dart:ui';

import 'package:auth_ui/auth_ui.dart' show AuthViewModel;
import 'package:ems_app_v1/main.dart';
import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart';
import 'package:user_ui/view_models/settings_view_model.dart';

import 'pages/app_page.dart';
import 'view_models/app_view_model.dart';

/// Widget raiz que define o layout principal do aplicativo.
///
/// ## Visão Geral
/// O [AppLayout] é o widget raiz que gerencia a estrutura visual do aplicativo,
/// incluindo temas, internacionalização e roteamento básico.
///
/// ## Responsabilidades
/// - Gerenciar o tema claro/escuro
/// - Configurar suporte a múltiplos idiomas
/// - Fornecer a estrutura base de navegação
/// - Inicializar controladores e ViewModels
/// - Gerenciar o estado de autenticação
///
/// ## Estrutura do Layout
/// ```plaintext
/// AppLayout
/// ├── MaterialApp
///     ├── Theme
///     └── Localizations
/// ```
///
/// ## Testes
/// - Cobertura atual: 0% (arquivo não testado)
/// - Plano de testes: Implementar testes de widget
///
/// ## Exemplo de Uso
/// ```dart
/// final appLayout = AppLayout(
///   di: dependencyInjector,
///   viewModel: appViewModel,
///   systemViewModel: systemViewModel,
/// );
/// runApp(appLayout);
/// ```
///
/// ## Parâmetros
/// - [key]: Chave opcional para o widget
/// - [di]: Gerenciador de injeção de dependências
/// - [viewModel]: ViewModel principal do aplicativo
/// - [settingsViewModel]: ViewModel responsável pelas configurações do sistema
///
/// ## Melhorias Futuras
/// - Adicionar suporte a temas personalizados
/// - Implementar transições de tela personalizadas
/// - Adicionar suporte a múltiplos esquemas de cores
class AppLayout extends StatefulWidget {
  final AppViewModel viewModel;
  final AuthViewModel authViewModel;
  final SettingsViewModel settingsViewModel;

  const AppLayout({
    super.key,
    required this.viewModel,
    required this.authViewModel,
    required this.settingsViewModel,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

/// Estado do widget [AppLayout].
///
/// Gerencia o ciclo de vida do layout principal, incluindo:
/// - Inicialização de serviços
/// - Configuração de temas
/// - Gerenciamento de estado global
///
/// ## Ciclo de Vida
/// 1. [initState]: Inicialização de recursos
/// 2. [didChangeDependencies]: Configuração pós-inicialização
/// 3. [build]: Construção da árvore de widgets
/// 4. [dispose]: Limpeza de recursos
///
/// ## Gestão de Estado
/// - Utiliza [ChangeNotifier] para notificação de mudanças
/// - Gerencia o estado de autenticação
/// - Controla o tema e localização
class _AppLayoutState extends State<AppLayout> {
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    if (_isInitialized) {
      debugPrint('⚠️ App já inicializado, ignorando nova inicialização');
      return;
    }

    try {
      debugPrint('🚀 Iniciando app...');

      // Inicialização assíncrona de recursos
      debugPrint('📦 Inicializando viewModel...');
      await widget.viewModel.init();

      // Inicializar AuthViewModel para verificar sessão persistida
      debugPrint('🔐 Inicializando authViewModel...');
      await widget.authViewModel.initialize();

      debugPrint('⚙️ Carregando settings...');
      await widget.settingsViewModel.loadSettings();

      _isInitialized = true;
      debugPrint('✅ App inicializado com sucesso!');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao inicializar app: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _initError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se houver erro de inicialização, mostra tela de erro
    if (_initError != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'Erro ao Inicializar',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _initError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initError = null;
                        _isInitialized = false;
                      });
                      _initializeApp();
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.viewModel, // Para mudanças no estado do aplicativo
        widget.settingsViewModel,
      ]),
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: alice.getNavigatorKey(),
          title: 'EMS System',
          home: AppPage(
            viewModel: widget.viewModel,
            authViewModel: widget.authViewModel,
            settingsViewModel: widget.settingsViewModel,
          ),
          debugShowCheckedModeBanner: false,
          // Themes
          theme: widget.settingsViewModel.themeDataLight,
          darkTheme: widget.settingsViewModel.themeDataDark,
          themeMode: widget.settingsViewModel.themeMode,
          // Configuração de internacionalização
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: widget.settingsViewModel.locale,
          // Configuração do comportamento de rolagem para suportar
          // diferentes dispositivos de entrada
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse, // Mouse
              PointerDeviceKind.touch, // Toque na tela
              PointerDeviceKind.stylus, // Caneta stylus
              PointerDeviceKind.unknown, // Dispositivos desconhecidos
              PointerDeviceKind.trackpad, // Trackpad
            },
          ),
        );
      },
    );
  }
}
