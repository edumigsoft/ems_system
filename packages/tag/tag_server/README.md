# tag_server

Server implementation for tag management feature.

## Descrição

Pacote Dart contendo a implementação server-side da feature Tag, incluindo tabela Drift para PostgreSQL e handlers Shelf para API REST.

## Responsabilidades

- Tabela Drift com DriftTableMixinPostgres
- Handlers Shelf para endpoints REST
- Lógica de persistência no PostgreSQL
- Validação server-side

## Estrutura

```
lib/src/
├── database/tables/    # Tabelas Drift
└── handlers/           # Handlers Shelf (REST API)
```

## Endpoints

```
POST   /tags           - Criar tag
GET    /tags           - Listar todas (query: active_only, search)
GET    /tags/:id       - Buscar por ID
PUT    /tags/:id       - Atualizar tag
DELETE /tags/:id       - Soft delete
POST   /tags/:id/restore - Restaurar tag deletada
```

## Tabela PostgreSQL

```sql
CREATE TABLE tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  name VARCHAR(50) NOT NULL,
  description VARCHAR(200),
  color VARCHAR(9),
  usage_count INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_tags_name ON tags(name);
CREATE INDEX idx_tags_active ON tags(is_active, is_deleted);
```

## Uso

```dart
import 'package:tag_server/tag_server.dart';

// Inicializar módulo no servidor
void configureServer(Router router, Database db) {
  InitTagModuleToServer(router, db);
}
```

## Dependências

- `tag_shared` - Domain entities e DTOs
- `core_server` - Base server utilities e DriftTableMixinPostgres
- `drift` - ORM para PostgreSQL
- `shelf` - HTTP server framework
