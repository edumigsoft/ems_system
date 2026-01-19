# Core Server

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Dart SDK](https://img.shields.io/badge/dart-%5E3.10.7-blue.svg)
![Shelf](https://img.shields.io/badge/shelf-1.4.2-green.svg)
![Drift](https://img.shields.io/badge/drift-2.30.1-purple.svg)
![Postgres](https://img.shields.io/badge/postgres-3.5.9-blue.svg)

O `core_server` é o pacote de infraestrutura backend para o EMS System, fornecendo implementações base para servidores HTTP Shelf, conexões com banco de dados (Drift/PostgreSQL), segurança (JWT, Bcrypt) e utilitários server-side.

> **Nota**: Este pacote segue uma estrutura de **Platform/Infrastructure** e por isso não adere estritamente à divisão `domain/data` dos pacotes de feature.

## 📋 Visão Geral

O `core_server` abstrai a complexidade da infraestrutura backend, oferecendo componentes prontos e configuráveis para:

- Setup de servidores HTTP com Shelf
- Gerenciamento de banco de dados com Drift ORM
- Autenticação e autorização com JWT
- Middlewares (CORS, Rate Limiting, Auth)
- Segurança (Bcrypt, tokens)

## ✨ Funcionalidades

- **Server Foundation**: Classes base para setup de servidores Shelf (`src/servers`)
- **Database**: Configuração do Drift e mixins para tabelas PostgreSQL (`src/database`)
- **Security**: Implementação de JWT, Bcrypt e middlewares de autorização (`src/security`)
- **Middleware**: CORS, Rate Limiting, Logging (`src/middleware`)
- **Routes Helpers**: Utilitários para definição de rotas e Health Checks (`src/routes`)
- **Email**: Infraestrutura para envio de emails (`src/email`)

## 📁 Estrutura

```
lib/
├── ems_system_core_server.dart           # Barrel file (exports públicos)
└── src/
    ├── commons/       # Utilitários comuns e inicialização
    ├── database/      # Configuração Drift, Mixins de Tabela e Migrations
    ├── email/         # Serviços de envio de email
    ├── middleware/    # Middlewares Shelf (Auth, CORS, RateLimit, Logging)
    ├── routes/        # Rotas base e health checks
    ├── security/      # Serviços de Criptografia e Tokens (JWT, Bcrypt)
    ├── servers/       # Base para servidor Shelf e configurações
    └── utils/         # Helpers HTTP e utilitários server-side
```

## 🔑 Features Principais

### 🗄️ Database com Drift + PostgreSQL

Use o `DriftTableMixinPostgres` para tabelas com campos de auditoria automáticos:

```dart
import 'package:drift/drift.dart';
import 'package:ems_system_core_server/ems_system_core_server.dart';

class Users extends Table with DriftTableMixinPostgres {
  @override
  String get tableName => 'users';
  
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  
  // id, createdAt, updatedAt, isDeleted automáticos via mixin
}

// Geração do código Drift
// $ dart run build_runner build
```

### 🔐 Segurança com JWT

Gestão de tokens para autenticação:

```dart
import 'package:ems_system_core_server/ems_system_core_server.dart';

// 1. Configurar serviço de segurança
final security = JWTSecurityService(
  jwtKey: 'your-secret-key',
  accessTokenDuration: Duration(hours: 1),
  refreshTokenDuration: Duration(days: 7),
);

// 2. Gerar tokens
final claims = {'userId': '123', 'role': 'admin'};
final tokenResult = await security.generateToken(claims, 'api-audience');

tokenResult.when(
  success: (token) => print('Access Token: $token'),
  failure: (error) => print('Erro: ${error.message}'),
);

// 3. Validar tokens
final validationResult = await security.validateToken(accessToken, 'api-audience');
```

### 🔒 Hashing de Senhas com Bcrypt

```dart
import 'package:ems_system_core_server/ems_system_core_server.dart';

// Hash
final hashedPassword = BcryptHelper.hashPassword('user-password');

// Verificação
final isValid = BcryptHelper.verifyPassword('user-password', hashedPassword);
print('Senha válida: $isValid');
```

### 🛣️ Middleware de Autenticação

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:ems_system_core_server/ems_system_core_server.dart';

final router = Router();

// Rotas protegidas com middleware de autenticação
final authMiddleware = createAuthMiddleware(
  jwtService: jwtSecurityService,
  audience: 'api',
);

router.get('/protected', authMiddleware((Request request) {
  final userId = request.context['userId'];
  return Response.ok('Authenticated user: $userId');
}));
```

### 🌐 CORS Middleware

```dart
import 'package:shelf/shelf.dart';
import 'package:ems_system_core_server/ems_system_core_server.dart';

final handler = Pipeline()
    .addMiddleware(corsMiddleware(
      allowedOrigins: ['https://app.example.com'],
      allowedMethods: ['GET', 'POST', 'PUT', 'DELETE'],
    ))
    .addHandler(router);
```

### 🏥 Health Check Endpoint

```dart
import 'package:shelf_router/shelf_router.dart';
import 'package:ems_system_core_server/ems_system_core_server.dart';

final router = Router();

router.get('/health', healthCheckHandler);
// GET /health -> {"status": "ok", "timestamp": "..."}
```

### 🚀 Servidor Base

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:ems_system_core_server/ems_system_core_server.dart';

Future<void> main() async {
  // Configurar handler com middlewares
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(router);
  
  // Iniciar servidor
  final server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}
```

## 📦 Dependências Principais

| Pacote | Versão | Propósito |
|--------|--------|-----------|
| `shelf` | ^1.4.2 | Framework HTTP server |
| `shelf_router` | ^1.1.4 | Sistema de rotas |
| `drift` | ^2.30.1 | ORM type-safe |
| `drift_postgres` | ^1.3.1 | Driver PostgreSQL para Drift |
| `postgres` | ^3.5.9 | Cliente PostgreSQL |
| `dart_jsonwebtoken` | ^3.3.1 | Manipulação de JWT |
| `bcrypt` | ^1.2.0 | Hashing de senhas |
| `pointycastle` | ^4.0.0 | Criptografia |

## 🚀 Instalação

Adicione ao `pubspec.yaml`:

```yaml
dependencies:
  ems_system_core_server: ^1.0.0
  ems_system_core_shared: ^1.0.0

dev_dependencies:
  build_runner: ^2.10.5  # Para geração de código Drift
```

> [!NOTE]
> Este pacote faz parte do workspace `ems_system_core`. A resolução de dependências é automática.

## 🔧 Configuração do Banco de Dados

```dart
import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart';

// Configurar conexão
final connection = await Connection.open(
  Endpoint(
    host: 'localhost',
    database: 'ems_db',
    username: 'user',
    password: 'password',
  ),
);

final database = PgDatabase(connection);
```

## 🧪 Testes

Execute os testes com:

```bash
dart test
```

## 📚 Documentação Adicional

- [CHANGELOG](./CHANGELOG.md) - Histórico de mudanças
- [Core Feature - Visão Geral](../README.md)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Shelf Documentation](https://pub.dev/packages/shelf)
