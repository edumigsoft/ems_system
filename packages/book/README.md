# Book Management

Descrição breve da feature book e seu propósito no sistema School Manager.

## 📦 Pacotes

Esta feature é composta por até 4 pacotes seguindo o padrão "Great Schism":

| Pacote | Responsabilidade | Localização |
|--------|------------------|-------------|
| **book_shared** | Entidades, DTOs, Use Cases, Validators | [book_shared](./book_shared/README.md) |
| **book_client** | Implementação HTTP (Dio/Retrofit) | [book_client](./book_client/README.md) |
| **book_server** | Database (Drift), Handlers (Shelf) | [book_server](./book_server/README.md) |
| **book_ui** | Pages, ViewModels, Widgets | [book_ui](./book_ui/README.md) |

> **Nota**: Nem toda feature precisa de todos os 4 pacotes.

## 🏗️ Arquitetura

```
packages/book/
├── book_shared/     # Domain & Business Logic
├── book_client/   # HTTP Client
├── book_server/   # Backend
└── book_ui/        # Flutter UI
```

### Fluxo de Dependências

```
book_ui → book_client → book_shared
                                                      ↑
book_server ──────────────────────────────┘
```

## 🚀 Como Usar

### Frontend

```dart
// Importe o módulo UI
import 'package:book_ui/book_ui.dart';

// Registre o módulo no app
final featureModule = Book ManagementModule();
featureModule.registerDependencies(di);
```

### Backend

```dart
// Importe o server package
import 'package:book_server/book_server.dart';

// Configure rotas
app.mount('/book', Book ManagementRoutes(database));
```

## 🧪 Como Executar Testes

### Todos os pacotes

```bash
cd packages/book

# Testar shared
cd book_shared && flutter test

# Testar client  
cd book_client && flutter test

# Testar server
cd book_server && dart test

# Testar UI
cd book_ui && flutter test
```

## 📊 Cobertura de Testes

Execute para gerar relatório de cobertura:

```bash
# Shared (meta: 90%)
cd book_shared && flutter test --coverage

# Client (meta: 80%)
cd book_client && flutter test --coverage

# UI (meta: 50%)
cd book_ui && flutter test --coverage
```

## 🤝 Como Contribuir

Veja [CONTRIBUTING.md](./CONTRIBUTING.md) para diretrizes de contribuição específicas desta feature.

## 📝 Documentação Adicional

- [Arquitetura Geral](../docs/v_0_2_0.md)
- [ADR-0005: Estrutura de Pacotes](../docs/adr/0005-standard-package-structure.md)
- [Regras Flutter/Dart](../docs/rules/flutter_dart_rules.md)

## 📜 Changelog

Veja [CHANGELOG.md](./CHANGELOG.md) para histórico de mudanças desta feature.
