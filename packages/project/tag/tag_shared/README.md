# tag_shared

Core domain logic and entities for tag management.

## Descrição

Pacote Pure Dart contendo toda a lógica de negócio e definições de domínio para a feature Tag. Este pacote é agnóstico de plataforma e pode ser usado tanto no cliente (Flutter) quanto no servidor (Dart/Shelf).

## Responsabilidades

- Definir entidades de domínio (Tag, TagDetails)
- Definir DTOs de operação (TagCreate, TagUpdate)
- Definir interfaces de repositórios
- Implementar casos de uso (Use Cases)
- Validadores de dados (Zard)
- Modelos de serialização

## Estrutura

```
lib/src/
├── domain/
│   ├── entities/          # Entidades de domínio
│   ├── dtos/              # Data Transfer Objects
│   ├── repositories/      # Interfaces de repositórios
│   └── use_cases/         # Casos de uso
├── data/models/           # Modelos de serialização
├── validators/            # Validadores Zard
└── constants/             # Constantes
```

## Uso

```dart
import 'package:tag_shared/tag_shared.dart';

// Criar tag
final create = TagCreate(
  name: 'Backend',
  description: 'Backend development tasks',
  color: '#FF5722',
);

// Validar
final validator = TagCreateValidator();
final result = validator.validate(create);
if (result.isValid) {
  // Processar...
}
```

## Dependências

- `core_shared` - Interfaces base (BaseDetails, Result)
- `meta` - Anotações Dart

## Padrões

Este pacote segue os padrões definidos em:
- [Entity Patterns](../../../docs/architecture/entity_patterns.md)
- [Architecture Patterns](../../../docs/architecture/architecture_patterns.md)
- [ADR-0005: Standard Package Structure](../../../docs/adr/0005-standard-package-structure.md)
