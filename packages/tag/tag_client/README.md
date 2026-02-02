# tag_client

HTTP client implementation for tag management feature.

## Descrição

Pacote Dart puro contendo a implementação do repositório Tag usando Retrofit e Dio para comunicação HTTP com a API backend.

## Responsabilidades

- Implementação de `TagRepository` via HTTP
- API Service com Retrofit
- Conversão de Models para DTOs
- Tratamento de erros HTTP com Result Pattern

## Uso

```dart
import 'package:dio/dio.dart';
import 'package:tag_client/tag_client.dart';

// Configurar Dio
final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));

// Criar API Service
final apiService = TagApiService(dio);

// Criar Repository
final repository = TagRepositoryImpl(apiService);

// Usar via Use Cases
final createUseCase = CreateTagUseCase(repository);
final result = await createUseCase(TagCreate(name: 'Flutter'));

result.when(
  success: (tag) => print('Tag created: ${tag.name}'),
  failure: (error) => print('Error: $error'),
);
```

## Build

Executar code generation para Retrofit:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Dependências

- `tag_shared` - Domain entities e DTOs
- `core_shared` - Result Pattern
- `core_client` - Base client utilities
- `dio` - HTTP client
- `retrofit` - Type-safe REST client generator
