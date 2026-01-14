import 'dart:ui';

import 'package:auth_ui/auth_ui.dart' show AuthViewModel;
import 'package:core_shared/core_shared.dart' show DependencyInjector;
import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart';

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
/// - [systemViewModel]: ViewModel responsável pelas configurações do sistema
///
/// ## Melhorias Futuras
/// - Adicionar suporte a temas personalizados
/// - Implementar transições de tela personalizadas
/// - Adicionar suporte a múltiplos esquemas de cores
class AppLayout extends StatefulWidget {
  final DependencyInjector di;
  final AppViewModel viewModel;
  // final SystemViewModel systemViewModel;

  const AppLayout({
    super.key,
    required this.di,
    required this.viewModel,
    // required this.systemViewModel,
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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Inicialização assíncrona de recursos
    // await widget.systemViewModel.init();
    // Configurações adicionais podem ser adicionadas aqui
    await widget.viewModel.init();

    // Inicializar AuthViewModel para verificar sessão persistida
    final authViewModel = widget.di.get<AuthViewModel>();
    await authViewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        // widget.systemViewModel, // Para mudanças de tema/localização
        widget.viewModel, // Para mudanças no estado do aplicativo
      ]),
      builder: (context, child) {
        return MaterialApp(
          title: 'EMS System',
          // Configuração de temas
          // theme: widget.systemViewModel.themeDataLight,
          // darkTheme: widget.systemViewModel.themeDataDark,
          // themeMode: widget.systemViewModel.themeMode,
          home: AppPage(
            viewModel: widget.viewModel,
            authViewModel: widget.di.get<AuthViewModel>(),
          ),
          debugShowCheckedModeBanner: false,
          // Configuração de internacionalização
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // locale: systemLocaleState.value,  // Descomente para forçar um idioma específico
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
