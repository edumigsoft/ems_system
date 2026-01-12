# {{FEATURE_TITLE}}

Descrição breve da feature {{FEATURE_NAME}} e seu propósito no sistema School Manager.

## 📦 Pacotes

Esta feature é composta por até 4 pacotes seguindo o padrão "Great Schism":

| Pacote | Responsabilidade | Localização |
|--------|------------------|-------------|
| **{{FEATURE_NAME}}_shared** | Entidades, DTOs, Use Cases, Validators | [{{FEATURE_NAME}}_shared](./{{FEATURE_NAME}}_shared/README.md) |
| **{{FEATURE_NAME}}_client** | Implementação HTTP (Dio/Retrofit) | [{{FEATURE_NAME}}_client](./{{FEATURE_NAME}}_client/README.md) |
| **{{FEATURE_NAME}}_server** | Database (Drift), Handlers (Shelf) | [{{FEATURE_NAME}}_server](./{{FEATURE_NAME}}_server/README.md) |
| **{{FEATURE_NAME}}_ui** | Pages, ViewModels, Widgets | [{{FEATURE_NAME}}_ui](./{{FEATURE_NAME}}_ui/README.md) |

> **Nota**: Nem toda feature precisa de todos os 4 pacotes.

## 🏗️ Arquitetura

```
packages/{{FEATURE_NAME}}/
├── {{FEATURE_NAME}}_shared/     # Domain & Business Logic
├── {{FEATURE_NAME}}_client/   # HTTP Client
├── {{FEATURE_NAME}}_server/   # Backend
└── {{FEATURE_NAME}}_ui/        # Flutter UI
```

### Fluxo de Dependências

```
{{FEATURE_NAME}}_ui → {{FEATURE_NAME}}_client → {{FEATURE_NAME}}_shared
                                                      ↑
{{FEATURE_NAME}}_server ──────────────────────────────┘
```

## 🚀 Como Usar

### Frontend

```dart
// Importe o módulo UI
import 'package:{{FEATURE_NAME}}_ui/{{FEATURE_NAME}}_ui.dart';

// Registre o módulo no app
final featureModule = {{FEATURE_TITLE}}Module();
featureModule.registerDependencies(di);
```

### Backend

```dart
// Importe o server package
import 'package:{{FEATURE_NAME}}_server/{{FEATURE_NAME}}_server.dart';

// Configure rotas
app.mount('/{{FEATURE_NAME}}', {{FEATURE_TITLE}}Routes(database));
```

## 🧪 Como Executar Testes

### Todos os pacotes

```bash
cd packages/{{FEATURE_NAME}}

# Testar shared
cd {{FEATURE_NAME}}_shared && flutter test

# Testar client  
cd {{FEATURE_NAME}}_client && flutter test

# Testar server
cd {{FEATURE_NAME}}_server && dart test

# Testar UI
cd {{FEATURE_NAME}}_ui && flutter test
```

## 📊 Cobertura de Testes

Execute para gerar relatório de cobertura:

```bash
# Shared (meta: 90%)
cd {{FEATURE_NAME}}_shared && flutter test --coverage

# Client (meta: 80%)
cd {{FEATURE_NAME}}_client && flutter test --coverage

# UI (meta: 50%)
cd {{FEATURE_NAME}}_ui && flutter test --coverage
```

## 🤝 Como Contribuir

Veja [CONTRIBUTING.md](./CONTRIBUTING.md) para diretrizes de contribuição específicas desta feature.

## 📝 Documentação Adicional

- [Arquitetura Geral]({{REL_PATH}}docs/v_0_2_0.md)
- [ADR-0005: Estrutura de Pacotes]({{REL_PATH}}docs/adr/0005-standard-package-structure.md)
- [Regras Flutter/Dart]({{REL_PATH}}docs/rules/flutter_dart_rules.md)

## 📜 Changelog

Veja [CHANGELOG.md](./CHANGELOG.md) para histórico de mudanças desta feature.
