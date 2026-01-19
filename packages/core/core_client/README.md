# Core Client

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Dart SDK](https://img.shields.io/badge/dart-%5E3.10.7-blue.svg)
![Dio](https://img.shields.io/badge/dio-5.9.0-00D9FF.svg)

Cliente HTTP compartilhado para todos os pacotes client do sistema EMS, fornecendo infraestrutura padronizada para comunicação com APIs e tratamento de erros.

## 📋 Visão Geral

Este pacote fornece componentes relacionados à camada de cliente e comunicação externa, incluindo mixins para tratamento de erros HTTP, repositórios base e integração com o Result Pattern do `core_shared`.

## 🎯 Responsabilidades

- **Tratamento de Erros HTTP**: Converter erros `Dio` em falhas de domínio usando Result Pattern
- **Base Repository**: Fornecer estruturas base para implementação de repositórios
- **HTTP Client Configuration**: Configurações padronizadas do Dio

## 📁 Estrutura do Pacote

A organização interna é focada em facilitar a implementação de clients e repositórios:

```
lib/
├── ems_system_core_client.dart          # Barrel file (exports públicos)
└── src/
    ├── mixins/          # Mixins compartilhados (DioErrorHandler)
    └── repositories/    # Classes, interfaces e implementações base para repositórios
```

## ✨ Features Principais

### 🔥 DioErrorHandler Mixin

Mixin para tratamento padronizado de erros HTTP:

```dart
import 'package:dio/dio.dart';
import 'package:ems_system_core_client/ems_system_core_client.dart';
import 'package:ems_system_core_shared/ems_system_core_shared.dart';

class UserRepository with DioErrorHandler {
  final Dio _dio;
  
  UserRepository(this._dio);
  
  Future<Result<User>> getUser(String id) async {
    return handleDioError<User>(() async {
      final response = await _dio.get('/users/$id');
      return Success(User.fromJson(response.data));
    });
  }
}
```

**Erros tratados automaticamente:**
- ✅ Network errors (sem conexão)
- ✅ Timeout errors
- ✅ HTTP errors (401, 404, 500, etc.)
- ✅ Parse errors
- ✅ Cancelamento de requisições

### 🏗️ Base Repository

Estrutura base para repositórios:

```dart
import 'package:ems_system_core_client/ems_system_core_client.dart';
import 'package:ems_system_core_shared/ems_system_core_shared.dart';

abstract class BaseRepository<T> with DioErrorHandler {
  final Dio dio;
  
  BaseRepository(this.dio);
  
  Future<Result<List<T>>> findAll();
  Future<Result<T>> findById(String id);
  Future<Result<T>> create(T entity);
  Future<Result<T>> update(String id, T entity);
  Future<Result<void>> delete(String id);
}

// Implementação
class UserRepositoryImpl extends BaseRepository<User> {
  UserRepositoryImpl(Dio dio) : super(dio);
  
  @override
  Future<Result<List<User>>> findAll() async {
    return handleDioError(() async {
      final response = await dio.get('/users');
      final users = (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
      return Success(users);
    });
  }
  
  // ... outras implementações
}
```

## 📦 Dependências

| Pacote | Versão | Propósito |
|--------|--------|-----------|
| `dio` | ^5.9.0 | HTTP client poderoso e extensível |
| `meta` | 1.17.0 | Annotations |
| `ems_system_core_shared` | ^1.0.0 | Result Pattern, exceptions |

## 🚀 Instalação

Adicione ao `pubspec.yaml`:

```yaml
dependencies:
  ems_system_core_client: ^1.0.0
  ems_system_core_shared: ^1.0.0
```

> [!NOTE]
> Este pacote faz parte do workspace `ems_system_core`. A resolução de dependências é automática.

## 📖 Uso Básico

```dart
import 'package:dio/dio.dart';
import 'package:ems_system_core_client/ems_system_core_client.dart';

// 1. Configurar Dio
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 3),
));

// 2. Criar repositório com DioErrorHandler
class ProductRepository with DioErrorHandler {
  final Dio _dio;
  ProductRepository(this._dio);
  
  Future<Result<Product>> getProduct(String id) {
    return handleDioError(() async {
      final response = await _dio.get('/products/$id');
      return Success(Product.fromJson(response.data));
    });
  }
}

// 3. Usar o repositório
final repo = ProductRepository(dio);
final result = await repo.getProduct('123');

result.when(
  success: (product) => print('Produto: ${product.name}'),
  failure: (error) => print('Erro: ${error.message}'),
);
```

## 🔗 Integração com Core Shared

Este pacote depende fortemente do `core_shared` para:

- **Result Pattern**: Todo método retorna `Result<T>`
- **Exceptions**: Usa `AppException` e suas especializações
- **Logging**: Integração com o sistema de logging

## 🧪 Testes

Execute os testes com:

```bash
dart test
```

## 📚 Documentação Adicional

- [CHANGELOG](./CHANGELOG.md) - Histórico de mudanças
- [Core Feature - Visão Geral](../README.md)
