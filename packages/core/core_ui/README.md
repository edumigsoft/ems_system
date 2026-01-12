# Core UI

Este pacote contém componentes de UI, widgets reutilizáveis e utilitários de interface compartilhados entre diferentes módulos da aplicação EMS System.

## Funcionalidades

O `core_ui` fornece as seguintes funcionalidades principais:

- **Widgets Responsivos:**
    - `ResponsiveLayout`: Widget para criar layouts que se adaptam a diferentes tamanhos de tela.
    - `ResponsiveLayoutMode`: Enumeração para definir os modos de layout (mobile, tablet, desktop).

- **Arquitetura Base:**
    - `BaseViewModel`: Classe base para ViewModels seguindo o padrão MVVM.
    - `AppModule`: Utilitários para injeção de dependência e módulos da aplicação.
    - `Command`: Padrão Command para executar ações na UI.

- **Navegação:**
    - `AppNavigationItem`: Definição de itens de navegação.
    - `AppNavigationSection`: Seções de navegação.

- **Mixins:**
    - `FormValidationMixin`: Mixin para facilitar a validação de formulários.

## Instalação

Adicione a dependência ao seu `pubspec.yaml`:

```yaml
dependencies:
  core_ui:
    path: ../core/core_ui
```

## Uso

Importe os componentes necessários em seu código:

```dart
import 'package:core_ui/core_ui.dart';

// Exemplo de uso do ResponsiveLayout
ResponsiveLayout(
  mobile: MobileWidget(),
  tablet: TabletWidget(),
  desktop: DesktopWidget(),
);
```
