# {{FEATURE_NAME}}_server

Pacote server da feature **{{FEATURE_TITLE}}**. Implementação backend usando Drift + Shelf.

## 📦 Responsabilidade

Este pacote contém:
- **Drift Tables**: Definições de tabelas e migrations
- **Shelf Handlers**: Endpoints RESTful com OpenAPI
- **Database Access**: Queries e operações de banco de dados

## 🚀 Como Usar

```dart
import 'package:{{FEATURE_NAME}}_server/{{FEATURE_NAME}}_server.dart';

// Configurar database
final db = AppDatabase();

// Criar handler
final handler = {{ENTITY_NAME}}Handler(db);

// Usar com Shelf router
final app = shelf_router.Router()
  ..mount('/{{feature_name_plural}}', handler.router);
```

## 📚 Dependências

- `{{FEATURE_NAME}}_shared` - Interfaces e modelos
- `drift` - Type-safe database layer
- `shelf` - HTTP server framework
- `shelf_router` - Routing

## 🗄️ Migrations

```bash
# Gerar migration
dart run drift_dev schema dump lib/database/database.dart lib/database/migrations/

# Aplicar migration
dart run drift_dev schema steps lib/database/migrations/ lib/database/
```

## 🧪 Testes

```bash
flutter test
flutter test --coverage
```

## 📖 Referências

- [ADR-0005: Feature-First DDD](../../../docs/adr/0005-feature-first-ddd-structure.md)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Shelf Documentation](https://pub.dev/packages/shelf)
