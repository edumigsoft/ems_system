# notebook_shared

Core domain logic and entities for notebook management.

## Descrição

Pacote Pure Dart contendo toda a lógica de negócio e definições de domínio para a feature Notebook. Este pacote é agnóstico de plataforma e pode ser usado tanto no cliente (Flutter) quanto no servidor (Dart/Shelf).

## Responsabilidades

- Definir entidades de domínio (Notebook, DocumentReference)
- Definir EntityDetails (NotebookDetails, DocumentReferenceDetails)
- Definir DTOs de operação (NotebookCreate, NotebookUpdate, DocumentReferenceCreate, DocumentReferenceUpdate)
- Definir enums (NotebookType, DocumentStorageType)
- Fornecer lógica de negócio através de getters e métodos

## Estrutura

```
lib/src/domain/
├── entities/              # Entidades de domínio puras
│   ├── notebook.dart                       # Entity: Notebook
│   ├── notebook_details.dart               # Details: NotebookDetails
│   ├── document_reference.dart             # Entity: DocumentReference
│   └── document_reference_details.dart     # Details: DocumentReferenceDetails
├── dtos/                  # Data Transfer Objects
│   ├── notebook_create.dart                # DTO para criação
│   ├── notebook_update.dart                # DTO para atualização
│   ├── document_reference_create.dart      # DTO para criação
│   └── document_reference_update.dart      # DTO para atualização
└── enums/                 # Enumerações
    ├── notebook_type.dart                  # quick, organized, reminder
    └── document_storage_type.dart          # server, local, url
```

## Uso

### Criar um Notebook

```dart
import 'package:notebook_shared/notebook_shared.dart';

// Criar notebook
final create = NotebookCreate(
  title: 'Meu Caderno de Estudos',
  content: '# Anotações importantes\n\nConteúdo em **Markdown**',
  type: NotebookType.organized,
  tags: ['estudos', 'programação'],
);

// Validar
if (create.isValid) {
  // Processar criação...
}
```

### Criar Lembrete

```dart
final reminder = NotebookCreate(
  title: 'Reunião com cliente',
  content: 'Discutir próximos passos do projeto',
  type: NotebookType.reminder,
  reminderDate: DateTime.now().add(Duration(days: 1)),
  notifyOnReminder: true,
);
```

### Anexar Documento

```dart
final docCreate = DocumentReferenceCreate(
  name: 'Contrato.pdf',
  path: '/uploads/documents/contrato_123.pdf',
  storageType: DocumentStorageType.server,
  mimeType: 'application/pdf',
  sizeBytes: 1024000, // ~1MB
  notebookId: notebookId,
);

if (docCreate.isValid) {
  // Processar anexo...
}
```

### Atualizar Notebook

```dart
final update = NotebookUpdate(
  id: notebookId,
  title: 'Título atualizado',
  content: 'Novo conteúdo',
);

if (update.hasChanges) {
  // Processar atualização...
}
```

### Soft Delete

```dart
final softDelete = NotebookUpdate(
  id: notebookId,
  isDeleted: true,
);
```

## Entidades

### Notebook (Entity)

Entidade de domínio pura representando um caderno/anotação:
- **Campos obrigatórios**: `title`, `content`
- **Campos opcionais**: `projectId`, `parentId`, `tags`, `type`, `reminderDate`, `notifyOnReminder`
- **Lógica de negócio**: `isQuickNote`, `isReminder`, `isOrganized`, `hasChildren`, `hasProject`, `hasTags`, `isReminderOverdue`

### NotebookDetails (EntityDetails)

Agregação completa com metadados de persistência:
- Implementa `BaseDetails` (`id`, `createdAt`, `updatedAt`, `isDeleted`, `isActive`)
- Compõe `Notebook` via campo `data`
- Campo adicional: `documentIds` (lista de IDs de documentos anexados)

### DocumentReference (Entity)

Entidade de domínio pura representando referência a documento:
- **Campos obrigatórios**: `name`, `path`, `storageType`
- **Campos opcionais**: `mimeType`, `sizeBytes`
- **Lógica de negócio**: `isPdf`, `isImage`, `isDocument`, `isOnServer`, `isLocal`, `isExternalUrl`, `formattedSize`, `isLargeFile`

### DocumentReferenceDetails (EntityDetails)

Agregação completa com metadados:
- Implementa `BaseDetails`
- Compõe `DocumentReference` via campo `data`
- Campo adicional: `notebookId` (relacionamento)
- Getter `uploadedAt` (alias para `createdAt`)

## Tipos de Notebook

- **quick**: Nota rápida, informal
- **organized**: Nota organizada, estruturada
- **reminder**: Lembrete com data/hora

## Tipos de Armazenamento de Documento

- **server**: Arquivo armazenado no servidor
- **local**: Caminho local do usuário (file://)
- **url**: URL externa (https://)

## Dependências

- `core_shared` - Interfaces base (BaseDetails)
- `meta` - Anotações Dart

## Padrões Arquiteturais

Este pacote segue rigorosamente os padrões definidos em:

- [Entity Patterns](../../../docs/architecture/entity_patterns.md)
- [Architecture Patterns](../../../docs/architecture/architecture_patterns.md)
- [ADR-0005: Standard Package Structure](../../../docs/adr/0005-standard-package-structure.md)
- [ADR-0006: Sincronização BaseDetails](../../../docs/adr/0006-base-details-sync.md)

### Princípios Seguidos

✅ **Entity pura**: Sem `id`, sem metadados de persistência
✅ **EntityDetails**: Implementa `BaseDetails`, compõe Entity via `data`
✅ **DTOs**: Create sem `id`, Update com `id` required e campos opcionais
✅ **Timestamps non-nullable**: `createdAt` e `updatedAt` são `DateTime` (não `DateTime?`)
✅ **Soft Delete**: Update inclui `isDeleted` e `isActive`
✅ **Sem serialização**: Entities e Details não têm `toJson`/`fromJson`

## Versionamento

Ver [CHANGELOG.md](./CHANGELOG.md) para histórico de versões.
