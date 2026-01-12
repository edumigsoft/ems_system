# {{FEATURE_NAME}}_ui

Pacote UI da feature **{{FEATURE_TITLE}}**. Telas e widgets Flutter.

## 📦 Responsabilidade

- **Pages**: T

elas com ResponsiveLayout
- **ViewModels**: Lógica de apresentação (MVVM)
- **Widgets**: Componentes reutilizáveis

## 🚀 Como Usar

```dart
import 'package:{{FEATURE_NAME}}_ui/{{FEATURE_NAME}}_ui.dart';

// Registrar módulo
{{FEATURE_TITLE}}Module().registerDependencies(di);

// Navegar
context.goNamed('{{feature_name_plural}}');
```

## 📚 Dependências

- `{{FEATURE_NAME}}_client` (dev)
- `{{FEATURE_NAME}}_core`
- `design_system`
- `core_ui`

## 🧪 Testes

```bash
flutter test
flutter test --coverage
```
