# Tag Feature

Sistema de gerenciamento de tags globais para o EMS System.

## Visão Geral

A feature Tag fornece um sistema completo de gerenciamento de tags que podem ser usadas em diferentes módulos do sistema (projetos, tarefas, notebooks). Tags são globais e compartilhadas, permitindo organização e categorização consistente em toda a aplicação.

## Arquitetura

Esta feature segue a arquitetura multi-variant do EMS System, dividida em 4 pacotes:

### 📦 Pacotes

- **[tag_shared](./tag_shared/)** - Domínio e lógica de negócio (Pure Dart)
  - Entidades de domínio (Tag, TagDetails)
  - DTOs (TagCreate, TagUpdate)
  - Interfaces de repositórios
  - Use Cases
  - Validadores (Zard)

- **[tag_client](./tag_client/)** - Cliente HTTP
  - Implementação de repositório via Retrofit/Dio
  - API Service com Result Pattern

- **[tag_server](./tag_server/)** - Backend
  - Tabela Drift com PostgreSQL
  - Handlers Shelf (REST API)

- **[tag_ui](./tag_ui/)** - Interface Flutter
  - Páginas de gerenciamento
  - Widgets reutilizáveis (TagChip, TagSelector)
  - ViewModels (MVVM)

## Funcionalidades

- ✅ CRUD completo de tags
- ✅ Tags globais compartilhadas entre módulos
- ✅ Suporte a cores customizadas (UI)
- ✅ Contador de uso (analytics)
- ✅ Soft delete
- ✅ Busca e filtros

## Modelo de Dados

```dart
Tag:
  - name: String
  - description: String?
  - color: String? (hex)

TagDetails (persistência):
  - id: String
  - isDeleted: bool
  - isActive: bool
  - createdAt: DateTime
  - updatedAt: DateTime
  - data: Tag
  - usageCount: int
```

## API Endpoints

```
POST   /tags           - Criar tag
GET    /tags           - Listar todas
GET    /tags/:id       - Buscar por ID
PUT    /tags/:id       - Atualizar tag
DELETE /tags/:id       - Soft delete
```

## Uso

### Importar no Flutter App

```yaml
dependencies:
  tag_ui:
    path: ../packages/project/tag/tag_ui
```

```dart
import 'package:tag_ui/tag_ui.dart';

// Registrar módulo
final tagModule = TagModule(di: injector);
tagModule.registerDependencies(injector);
```

### Widgets Reutilizáveis

```dart
// Chip visual
TagChip(tag: myTag)

// Seletor de tags
TagSelector(
  selectedTags: currentTags,
  onChanged: (tags) => updateTags(tags),
)
```

## Como Executar Testes

```bash
# Todos os pacotes
cd packages/project/tag
for dir in tag_*/; do
  cd "$dir"
  dart test  # ou flutter test para tag_ui
  cd ..
done

# Pacote específico
cd packages/project/tag/tag_shared
dart test
```

## Documentação Adicional

- [CONTRIBUTING.md](./CONTRIBUTING.md) - Guia de contribuição
- [CHANGELOG.md](./CHANGELOG.md) - Histórico de mudanças
- [Architecture Patterns](../../docs/architecture/architecture_patterns.md) - Padrões arquiteturais do sistema

## Licença

Proprietary - EduMigSoft System
