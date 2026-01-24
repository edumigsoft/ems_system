# notebook_client

HTTP client implementation for the notebook management feature.

## Overview

This package provides HTTP client implementations for notebook and document reference operations using Retrofit and Dio. It follows the multi-variant architecture pattern of the EMS System, implementing the repository interfaces defined in `notebook_shared`.

## Features

- **HTTP Repository Implementations**: Type-safe HTTP operations using Retrofit
- **Result Pattern**: All operations return `Result<T>` for explicit error handling (ADR-0001)
- **Error Handling**: Comprehensive DioException handling with user-friendly error messages
- **Model Serialization**: Automatic JSON conversion using models from `notebook_shared`

## Architecture

This package is part of the 4-variant architecture:

```
packages/notebook/
├── notebook_shared/    ✅ Domain entities, DTOs, repositories, models
├── notebook_client/    ✅ HTTP implementation (THIS PACKAGE)
├── notebook_server/    ⏳ Database implementation
└── notebook_ui/        ⏳ Flutter widgets
```

### Responsibilities

**notebook_client** provides:
- `NotebookRepositoryImpl`: HTTP implementation of `NotebookRepository`
- `DocumentReferenceRepositoryImpl`: HTTP implementation of `DocumentReferenceRepository`
- `NotebookApiService`: Retrofit API service for notebook endpoints
- `DocumentReferenceApiService`: Retrofit API service for document endpoints

## Usage

### 1. Setup Dio Client

```dart
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 3),
));
```

### 2. Create API Services

```dart
import 'package:notebook_client/notebook_client.dart';

final notebookApi = NotebookApiService(dio);
final documentApi = DocumentReferenceApiService(dio);
```

### 3. Create Repository Instances

```dart
final notebookRepository = NotebookRepositoryImpl(notebookApi);
final documentRepository = DocumentReferenceRepositoryImpl(
  documentApi,
  notebookApi, // Required for getByNotebookId
);
```

### 4. Use Repositories

```dart
import 'package:notebook_shared/notebook_shared.dart';

// Create a notebook
final createDto = NotebookCreate(
  title: 'My First Notebook',
  content: 'This is a quick note',
  type: NotebookType.quick,
);

final result = await notebookRepository.create(createDto);
result.when(
  success: (notebook) => print('Created: ${notebook.title}'),
  failure: (error) => print('Error: ${error.message}'),
);

// Get all notebooks
final allResult = await notebookRepository.getAll(
  activeOnly: true,
  search: 'meeting',
  type: NotebookType.organized,
);

allResult.when(
  success: (notebooks) => print('Found ${notebooks.length} notebooks'),
  failure: (error) => print('Error: ${error.message}'),
);

// Create a document reference
final docCreate = DocumentReferenceCreate(
  name: 'Project Proposal.pdf',
  path: '/uploads/documents/proposal.pdf',
  storageType: DocumentStorageType.server,
  mimeType: 'application/pdf',
  sizeBytes: 1024000,
  notebookId: notebook.id,
);

final docResult = await documentRepository.create(docCreate);
```

## API Endpoints

### Notebook Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/notebooks` | Create new notebook |
| GET | `/notebooks` | List notebooks (with filters) |
| GET | `/notebooks/{id}` | Get notebook by ID |
| PUT | `/notebooks/{id}` | Update notebook |
| DELETE | `/notebooks/{id}` | Soft delete notebook |
| POST | `/notebooks/{id}/restore` | Restore deleted notebook |
| GET | `/notebooks/{id}/documents` | Get documents for notebook |

### Document Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/documents` | Create document reference |
| GET | `/documents/{id}` | Get document by ID |
| PUT | `/documents/{id}` | Update document reference |
| DELETE | `/documents/{id}` | Delete document permanently |

## Query Parameters

### GET /notebooks

- `active_only` (bool): Filter by active status (default: true)
- `search` (string): Search in title/content
- `project_id` (string): Filter by project
- `parent_id` (string): Filter by parent notebook
- `type` (string): Filter by type (quick, organized, reminder)
- `tags` (string): Comma-separated tag list
- `overdue_only` (bool): Show only overdue reminders

### GET /notebooks/{id}/documents

- `storage_type` (string): Filter by storage type (server, local, url)

## Error Handling

All repository methods return `Result<T>` with comprehensive error handling:

```dart
final result = await notebookRepository.getById(id);

result.when(
  success: (notebook) {
    // Handle success
  },
  failure: (exception) {
    // Handle specific errors
    if (exception.message.contains('não encontrado')) {
      // Not found
    } else if (exception.message.contains('conexão')) {
      // Network error
    }
  },
);
```

### Error Types

- **Connection Errors**: Timeout or network issues
- **400 Bad Request**: Invalid data
- **404 Not Found**: Notebook/document not found
- **409 Conflict**: Conflict error
- **500 Server Error**: Internal server error

## Dependencies

```yaml
dependencies:
  dio: ^5.0.0              # HTTP client
  retrofit: 4.9.1          # Type-safe HTTP client
  json_annotation: ^4.9.0  # JSON serialization annotations
  notebook_shared:         # Domain logic and models
  core_shared:             # Result pattern and base utilities
  core_client:             # Client-side utilities

dev_dependencies:
  build_runner: ^2.10.5           # Code generation
  retrofit_generator: 10.2.0      # Retrofit code generator
  json_serializable: ^6.9.2       # JSON serialization generator
```

## Code Generation

After modifying API services, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Testing

Run tests:

```bash
dart test
```

## Related Packages

- **notebook_shared**: Domain entities, DTOs, repositories, models
- **notebook_server**: Server-side database implementation
- **notebook_ui**: Flutter UI components
- **core_shared**: Shared utilities and Result pattern
- **core_client**: Client-side utilities

## Architecture Decisions

- **ADR-0001**: Result Pattern for error handling
- **ADR-0002**: Dio Error Handler Mixin
- **ADR-0005**: Standard Package Structure (4-variant pattern)

## License

Private package - not for public distribution.
