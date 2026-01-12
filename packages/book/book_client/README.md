# book_client

Pacote client da feature **Book Management**. Implementação HTTP usando Dio/Retrofit.

## 📦 Responsabilidade

Este pacote contém:
- **Repository Implementations**: Implementações HTTP dos repositórios
- **API Services**: Serviços Retrofit para endpoints
- **Error Handling**: Tratamento de erros HTTP

## 🚀 Como Usar

```dart
import 'package:book_client/book_client.dart';

// Configurar Dio
final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));

// Criar repository
final repository = BookRepositoryClient(dio);

// Usar com use cases
final useCase = GetBooksUseCase(repository);
final result = await useCase.execute();
```

## 📚 Dependências

- `book_shared` - Interfaces e modelos
- `dio` - HTTP client
- `retrofit` - Type-safe HTTP client

### ⚠️ Dependências Críticas (dev_dependencies)

**Analyzer 8.4.1** é obrigatório para compatibilidade com `retrofit_generator 10.2.0`:

```yaml
dev_dependencies:
  build_runner: 2.10.4
  retrofit_generator: 10.2.0
  analyzer: 8.4.1  # ⚠️ CRÍTICO: sem esta versão, build_runner falha
```

**Motivo técnico**: `retrofit_generator 10.2.0` usa APIs do analyzer (`element3`, `MethodElement2`, etc.) que foram removidas no `analyzer 9.0.0`. Sem especificar `analyzer: 8.4.1`, o build_runner usa a versão mais recente e falha com erros como:
- `The getter 'element3' isn't defined for the type 'DartType'`
- `'MethodElement2' isn't a type`


## 🧪 Testes

```bash
flutter test
flutter test --coverage
```

## 📖 Referências

- [ADR-0002: DioErrorHandler](../../../docs/adr/0002-use-dio-error-handler-mixin.md)
- [ADR-0003: BaseRepository](../../../docs/adr/0003-use-base-repository-pattern.md)
