# Core UI

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/flutter-%3E%3D3.0.0-blue.svg)
![Dart SDK](https://img.shields.io/badge/dart-%5E3.10.7-blue.svg)

Este pacote contém componentes de UI, widgets reutilizáveis, arquitetura MVVM base e utilitários de interface compartilhados entre diferentes módulos da aplicação EMS System.

## 📋 Visão Geral

O `core_ui` fornece a fundação para todas as interfaces do usuário no EMS System, incluindo:

- Arquitetura MVVM com `BaseViewModel`
- Widgets responsivos para diferentes tamanhos de tela
- Sistema de navegação modular
- Padrão Command para ações de UI
- Mixins de validação de formulários

## ✨ Funcionalidades

### 🏗️ Arquitetura MVVM

**BaseViewModel**: Classe base para todos os ViewModels do sistema

```dart
import 'package:ems_system_core_ui/ems_system_core_ui.dart';

class UserViewModel extends BaseViewModel {
  String _userName = '';
  String get userName => _userName;
  
  Future<void> loadUser() async {
    setBusy(true);
    try {
      final result = await userRepository.getCurrentUser();
      result.when(
        success: (user) {
          _userName = user.name;
          notifyListeners();
        },
        failure: (error) {
          setError(error.message);
        },
      );
    } finally {
      setBusy(false);
    }
  }
  
  @override
  void dispose() {
    // Cleanup
    super.dispose();
  }
}
```

### ⚡ Command Pattern

Execute ações assíncronas com feedback de estado:

```dart
import 'package:ems_system_core_ui/ems_system_core_ui.dart';

class LoginViewModel extends BaseViewModel {
  late final Command<void> loginCommand;
  
  LoginViewModel() {
    loginCommand = Command(
      action: _performLogin,
      onError: (error) => setError(error.toString()),
    );
  }
  
  Future<void> _performLogin() async {
    final result = await authService.login(email, password);
    result.when(
      success: (_) => navigateToHome(),
      failure: (error) => throw error,
    );
  }
}

// Na View
ElevatedButton(
  onPressed: viewModel.loginCommand.canExecute 
      ? () => viewModel.loginCommand.execute() 
      : null,
  child: viewModel.loginCommand.isExecuting
      ? CircularProgressIndicator()
      : Text('Login'),
)
```

### 📱 Responsive Layout

Widget para criar layouts adaptativos:

```dart
import 'package:ems_system_core_ui/ems_system_core_ui.dart';

ResponsiveLayout(
  mobile: (context) => MobileHomeScreen(),
  tablet: (context) => TabletHomeScreen(),
  desktop: (context) => DesktopHomeScreen(),
)

// Ou verificar o modo atual
if (ResponsiveLayout.isMobile(context)) {
  return MobileWidget();
}
```

**Breakpoints:**
- Mobile: < 600px
- Tablet: 600px - 1200px
- Desktop: > 1200px

### 🧭 Sistema de Navegação

Definição de itens e seções de navegação modular:

```dart
import 'package:ems_system_core_ui/ems_system_core_ui.dart';

final navigationItems = [
  AppNavigationItem(
    id: 'home',
    label: 'Home',
    icon: Icons.home,
    route: '/home',
  ),
  AppNavigationItem(
    id: 'users',
    label: 'Usuários',
    icon: Icons.people,
    route: '/users',
  ),
];

final navigationSections = [
  AppNavigationSection(
    title: 'Principal',
    items: navigationItems,
  ),
];
```

### ✅ Form Validation Mixin

Facilita validação de formulários:

```dart
import 'package:ems_system_core_ui/ems_system_core_ui.dart';

class SignUpViewModel extends BaseViewModel with FormValidationMixin {
  String email = '';
  String password = '';
  
  bool get isFormValid => 
      validateEmail(email) && 
      validatePassword(password);
  
  Future<void> submit() async {
    if (!isFormValid) {
      setError('Preencha todos os campos corretamente');
      return;
    }
    // Processar...
  }
}
```

## 📁 Estrutura do Pacote

```
lib/
├── ems_system_core_ui.dart              # Barrel file (exports públicos)
├── core/                                 # Arquitetura base (MVVM)
│   ├── commands/                         # Implementação de Commands
│   ├── commons/                          # Utilitários comuns de UI
│   ├── extensions/                       # Extensions para widgets
│   ├── mixins/                           # Mixins (FormValidation, etc.)
│   └── navigation/                       # Sistema de navegação
└── ui/
    ├── view_models/                      # ViewModels base
    └── widgets/                          # Widgets reutilizáveis
```

## 📦 Dependências Principais

| Pacote | Versão | Propósito |
|--------|--------|-----------|
| `flutter` | SDK | Framework UI |
| `logging` | ^1.3.0 | Logging |
| `path_provider` | ^2.1.5 | Acesso a diretórios do sistema |
| `zard` | ^0.0.25 | Utilitários funcionais |
| `ems_system_core_shared` | ^1.0.0 | Result Pattern, validators |

## 🚀 Instalação

Adicione ao `pubspec.yaml`:

```yaml
dependencies:
  ems_system_core_ui: ^1.0.0
  ems_system_core_shared: ^1.0.0
```

> [!NOTE]
> Este pacote faz parte do workspace `ems_system_core`. A resolução de dependências é automática.

## 📖 Uso Completo

```dart
import 'package:flutter/material.dart';
import 'package:ems_system_core_ui/ems_system_core_ui.dart';

// 1. ViewModel
class HomeViewModel extends BaseViewModel {
  int _counter = 0;
  int get counter => _counter;
  
  late final Command<void> incrementCommand;
  
  HomeViewModel() {
    incrementCommand = Command(action: _increment);
  }
  
  Future<void> _increment() async {
    await Future.delayed(Duration(milliseconds: 500));
    _counter++;
    notifyListeners();
  }
}

// 2. View
class HomeScreen extends StatelessWidget {
  final HomeViewModel viewModel;
  
  const HomeScreen({required this.viewModel});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: ResponsiveLayout(
        mobile: (context) => _buildMobileLayout(context),
        desktop: (context) => _buildDesktopLayout(context),
      ),
    );
  }
  
  Widget _buildMobileLayout(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Counter: ${viewModel.counter}'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: viewModel.incrementCommand.canExecute
                    ? () => viewModel.incrementCommand.execute()
                    : null,
                child: viewModel.incrementCommand.isExecuting
                    ? CircularProgressIndicator()
                    : Text('Increment'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDesktopLayout(BuildContext context) {
    // Layout diferente para desktop
    return _buildMobileLayout(context);
  }
}
```

## 🎨 Design Patterns

O `core_ui` implementa os seguintes design patterns:

- **MVVM**: Separação entre lógica e UI
- **Command**: Encapsulamento de ações com estado
- **Observer**: ChangeNotifier para reatividade
- **Dependency Injection**: Via GetIt do `core_shared`
- **Repository Pattern**: Integração com `core_client`

## 🧪 Testes

Execute os testes com:

```bash
flutter test
```

## 📚 Documentação Adicional

- [CHANGELOG](./CHANGELOG.md) - Histórico de mudanças
- [Core Feature - Visão Geral](../README.md)
