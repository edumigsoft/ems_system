# Open API Shared

Pacote compartilhado contendo anotações e utilitários para integração e geração de especificações Open API (Swagger) no EMS System.

Este pacote é parte da feature `open_api` e serve como base para definição de contratos de API através de anotações em código Dart.

## Instalação

Adicione a dependência ao seu `pubspec.yaml`:

```yaml
dependencies:
  open_api_shared:
    path: ../open_api_shared
```

## Funcionalidades

*   **Anotações de API**: `ApiInfo`, `Tags`
*   **Anotações de Rota**: `Route`, `Get`, `Post`, `Put`, `Delete`
*   **Anotações de Schema**: Para definição de modelos de dados
*   **Geradores**: Utilitários base para geração de documentação

## Como Usar

Utilize as anotações para decorar seus controllers ou handlers:

```dart
import 'package:open_api_shared/open_api_shared.dart';

@ApiInfo(title: 'User API', version: '1.0.0')
class UserController {

  @Get(
    path: '/users',
    summary: 'List users',
    description: 'Retrieves a list of all system users'
  )
  Future<List<User>> getUsers() async {
    // ...
  }
}
```

## Estrutura do Pacote

Este pacote segue a arquitetura do monorepo:

*   `lib/annotations/`: Definições das anotações
*   `lib/generators/`: Lógica compartilhada de geração
