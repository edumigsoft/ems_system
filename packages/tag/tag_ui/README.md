# tag_ui

Flutter UI implementation for tag management feature.

## Descrição

Pacote Flutter contendo a interface do usuário para gerenciamento de tags, incluindo páginas, ViewModels e widgets reutilizáveis.

## Responsabilidades

- Páginas de gerenciamento (lista e formulário)
- ViewModels (MVVM pattern)
- Widgets reutilizáveis (TagCard, TagChip, TagSelector)
- Integração com Design System
- Navegação e rotas

## Estrutura

```
lib/
├── ui/
│   ├── pages/          # Páginas/Telas
│   ├── view_models/    # ViewModels
│   └── widgets/        # Widgets reutilizáveis
└── tag_module.dart     # AppModule para DI e rotas
```

## Uso

### Registrar Módulo

```dart
import 'package:tag_ui/tag_ui.dart';

// No app
final tagModule = TagModule(di: injector);
tagModule.registerDependencies(injector);
```

### Widgets Reutilizáveis

```dart
import 'package:tag_ui/tag_ui.dart';

// Tag Chip
TagChip(
  tag: myTag,
  onTap: () => print('Tag tapped'),
  onDelete: () => print('Tag deleted'),
)

// Tag Selector (multi-select)
TagSelector(
  selectedTags: currentTags,
  onChanged: (tags) => setState(() => currentTags = tags),
)
```

## Navegação

Rota principal: `/tags`

## Dependências

- `tag_shared` - Domain entities e DTOs
- `tag_client` - HTTP Repository
- `core_ui` - Base UI utilities e AppModule
- `design_system_ui` - Componentes visuais
- `localizations_ui` - Traduções
