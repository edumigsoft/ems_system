# Core Shared

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Pure Dart](https://img.shields.io/badge/pure-dart-00D2B8.svg)
![Dart SDK](https://img.shields.io/badge/dart-%5E3.10.7-blue.svg)

Este pacote contém componentes base, utilitários e lógicas compartilhadas essenciais para o funcionamento do sistema EMS. Ele serve como um "kernel" reutilizável seguindo princípios de **Domain-Driven Design (DDD)** e **Pure Dart**.

## 🎯 Princípios

- **Pure Dart**: Sem dependências do Flutter ou plataformas específicas
- **Domain-First**: Lógica de domínio isolada e independente de frameworks
- **Result Pattern**: Tratamento de erros explícito e funcional
- **Immutability**: Estruturas de dados imutáveis por padrão
- **Type Safety**: Tipagem forte e  sem uso de `dynamic`

## 📁 Estrutura do Pacote

A estrutura interna reflete as funcionalidades utilitárias e transversais fornecidas:

```
lib/
├── ems_system_core_shared.dart           # Barrel file (exports públicos)
└── src/
    ├── commons/              # Classes e constantes comuns (Page, Pagination)
    ├── converters/           # Conversores de dados (JSON, Data, tipos customizados)
    ├── dependency_injector/  # Configuração e interfaces para Dependency Injection (GetIt)
    ├── domain/               # Entidades de domínio puras
    ├── exceptions/           # Exceções base do sistema (AppException, ValidationException)
    ├── messages/             # Centralização de mensagens (i18n ou constantes)
    ├── result/               # Implementação do Result Pattern para tratamento de erros
    ├── service/              # Interfaces e classes base para serviços
    ├── utils/                # Funções utilitárias gerais (date, string, file helpers)
    └── validators/           # Lógicas e mixins de validação (email, CPF, CNPJ, etc.)
```

## ✨ Features Principais

### 🎯 Result Pattern

Tratamento de erros robusto e explícito sem exceções:

```dart
import 'package:ems_system_core_shared/ems_system_core_shared.dart';

Result<User> fetchUser(String id) {
  try {
    final user = repository.find(id);
    return Success(user);
  } catch (e) {
    return Failure(AppException('User not found'));
  }
}

// Uso
final result = fetchUser('123');
result.when(
  success: (user) => print('Found: ${user.name}'),
  failure: (error) => print('Error: ${error.message}'),
);
```

### 🔍 Validators

Validadores prontos para uso comum:

```dart
import 'package:ems_system_core_shared/ems_system_core_shared.dart';

// Exemplo com mixin de validação
class SignUpForm with ValidationMixin {
  String email = '';
  String cpf = '';
  
  bool validate() {
    return validateEmail(email) && validateCPF(cpf);
  }
}
```

### 💉 Dependency Injection

Configuração centralizada do GetIt:

```dart
import 'package:ems_system_core_shared/ems_system_core_shared.dart';

void setupDependencies() {
  final di = DependencyInjector.instance;
  
  di.registerSingleton<UserRepository>(UserRepositoryImpl());
  di.registerFactory<UserService>(() => UserService(di.get()));
}
```

### 📄 Pagination

Classes para paginação padronizada:

```dart
import 'package:ems_system_core_shared/ems_system_core_shared.dart';

Page<User> getUsersPage(int pageNumber, int pageSize) {
  final users = repository.findAll(skip: pageNumber * pageSize, limit: pageSize);
  final total = repository.count();
  
  return Page(
    items: users,
    page: pageNumber,
    pageSize: pageSize,
    totalItems: total,
  );
}
```

## 📦 Dependências Principais

| Pacote | Versão | Propósito |
|--------|--------|-----------|
| `meta` | ^1.17.0 | Annotations (@immutable, @protected) |
| `logging` | ^1.3.0 | Logging estruturado e configurável |
| `zard` | ^0.0.25 | Validação funcional e Result types |
| `get_it` | ^9.2.0 | Service locator / Dependency Injection |
| `path` | ^1.9.1 | Manipulação de paths multiplataforma |

## 🚀 Instalação

Adicione ao `pubspec.yaml`:

```yaml
dependencies:
  ems_system_core_shared: ^1.0.0
```

> [!NOTE]
> Este pacote faz parte do workspace `ems_system_core`. A resolução de dependências é automática.

## 📖 Uso Básico

```dart
import 'package:ems_system_core_shared/ems_system_core_shared.dart';

// 1. Usar Result Pattern
Result<int> divide(int a, int b) {
  if (b == 0) return Failure(AppException('Division by zero'));
  return Success(a ~/ b);
}

// 2. Validações
if (EmailValidator.isValid('user@example.com')) {
  print('Email válido!');
}

// 3. Logging
final logger = Logger('MyService');
logger.info('Operação concluída com sucesso');

// 4. Dependency Injection
final service = DependencyInjector.instance.get<MyService>();
```

## 🧪 Testes

Execute os testes com:

```bash
dart test
```

## 📚 Documentação Adicional

- [CHANGELOG](./CHANGELOG.md) - Histórico de mudanças
- [Core Feature - Visão Geral](../README.md)
