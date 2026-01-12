# book_shared

Pacote shared da feature **Book Management**. Contém a lógica de domínio e negócio.

## 📦 Responsabilidade

Este pacote contém:
- **Entidades de domínio**: Modelos de negócio puros
- **Interfaces de repositórios**: Contratos para acesso a dados
- **Use Cases**: Regras de negócio e casos de uso
- **Validators**: Validações com Zard
- **DTOs**: Modelos de transferência de dados

## 🏗️ Estrutura

```
lib/src/
  domain/              # Camada de domínio
    entities/          # Objetos de domínio
    repositories/      # Interfaces
    use_cases/         # Casos de uso
  data/                # Camada de dados
    models/            # DTOs
  validators/          # Validações (Zard)
  constants/           # Constantes
  extensions/          # Extensions
  enums/              # Enumerações
```

## 🚀 Como Usar

### Use Case

```dart
import 'package:book_shared/book_shared.dart';

// Injetar Use Case
final useCase = CreateBookUseCase(repository);

// Executar
final result = await useCase.execute(request);

result.when(
  success: (data) => print('Sucesso: $data'),
  failure: (error) => print('Erro: $error'),
);
```

### Validators

```dart
import 'package:book_shared/book_shared.dart';

// Validar com Zard
final validation = {{ENTITY_NAME_LOWER}}Schema.safeParse(data);

if (validation.success) {
  print('Dados válidos');
} else {
  print('Erros: ${validation.errors}');
}
```

## 📝 Principais Classes

### Entidades

- `Book` - Entidade principal

### Use Cases

- `CreateBookUseCase` - Criar novo registro
- `GetBooksUseCase` - Listar todos
- `GetBookByIdUseCase` - Buscar por ID
- `UpdateBookUseCase` - Atualizar registro
- `DeleteBookUseCase` - Deletar registro

### Repository Interface

- `BookRepository` - Interface para implementações

## 🧪 Testes

```bash
flutter test
flutter test --coverage
```

## 📚 Dependências

- `core_shared` - Utilitários compartilhados
- `zard` - Validações
- `open_api` - Anotações para OpenAPI

## 📖 Referências

- [ADR-0001: Padrão Result](../../../docs/adr/0001-use-result-pattern-for-error-handling.md)
- [ADR-0005: Estrutura de Pacotes](../../../docs/adr/0005-standard-package-structure.md)
