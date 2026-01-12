# book_ui

Pacote UI da feature **Book Management**. Telas e widgets Flutter.

## 📦 Responsabilidade

- **Pages**: T

elas com ResponsiveLayout
- **ViewModels**: Lógica de apresentação (MVVM)
- **Widgets**: Componentes reutilizáveis

## 🚀 Como Usar

```dart
import 'package:book_ui/book_ui.dart';

// Registrar módulo
Book ManagementModule().registerDependencies(di);

// Navegar
context.goNamed('{{feature_name_plural}}');
```

## 📚 Dependências

- `book_client` (dev)
- `book_shared`
- `design_system`
- `core_ui`

## 🧪 Testes

```bash
flutter test
flutter test --coverage
```
