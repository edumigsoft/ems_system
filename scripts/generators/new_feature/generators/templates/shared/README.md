# {{FEATURE_NAME}}_shared

Pacote shared da feature **{{FEATURE_TITLE}}**. Contém a lógica de domínio e negócio.

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
import 'package:{{FEATURE_NAME}}_shared/{{FEATURE_NAME}}_shared.dart';

// Injetar Use Case
final useCase = Create{{ENTITY_NAME}}UseCase(repository);

// Executar
final result = await useCase.execute(request);

result.when(
  success: (data) => print('Sucesso: $data'),
  failure: (error) => print('Erro: $error'),
);
```

### Validators

```dart
import 'package:{{FEATURE_NAME}}_shared/{{FEATURE_NAME}}_shared.dart';

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

- `{{ENTITY_NAME}}` - Entidade principal

### Use Cases

- `Create{{ENTITY_NAME}}UseCase` - Criar novo registro
- `Get{{ENTITY_NAME}}sUseCase` - Listar todos
- `Get{{ENTITY_NAME}}ByIdUseCase` - Buscar por ID
- `Update{{ENTITY_NAME}}UseCase` - Atualizar registro
- `Delete{{ENTITY_NAME}}UseCase` - Deletar registro

### Repository Interface

- `{{ENTITY_NAME}}Repository` - Interface para implementações

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
