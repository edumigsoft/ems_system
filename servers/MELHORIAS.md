# Melhorias Técnicas dos Servidores

Este documento registra problemas identificados na infraestrutura dos servidores EMS e SMS, com a análise de causa raiz e o plano de correção para cada um.

---

## 1. Dependência Circular: `core_server` ↔ `auth_server`

### Problema

Existe uma **dependência circular real entre pacotes** declarada nos `pubspec.yaml`:

```
core_server/pubspec.yaml  → dependencies: auth_server
auth_server/pubspec.yaml  → dependencies: core_server
```

Isso viola o princípio arquitetural do projeto (ADR-0005) que define `core_server` como infraestrutura base — não deve conhecer pacotes de features.

### Causa Raiz

A circular é causada por **um único ponto de acoplamento** em `core_server`:

**Arquivo:** `packages/core/core_server/lib/src/routes/file_routes.dart`

```dart
// PROBLEMA: infraestrutura importando feature
import 'package:auth_server/auth_server.dart' show AuthMiddleware;

class FileRoutes extends Routes {
  final AuthMiddleware _authMiddleware;   // ← tipo de auth_server

  @override
  Router get router {
    router.get(
      '/<year>/<month>/<filename>',
      Pipeline()
          .addMiddleware(_authMiddleware.verifyJwt)   // ← único uso
          .addHandler(_downloadFile),
    );
  }
}
```

`FileRoutes` usa **apenas** `_authMiddleware.verifyJwt`, cujo retorno é `shelf.Middleware` — um tipo que `core_server` já possui via sua dependência em `shelf`.

### Diagrama da Dependência Circular

```
┌───────────────────────────────────┐
│          auth_server              │
│                                   │
│  AuthMiddleware                   │
│  AuthService                      │
│  AuthRoutes                       │
│  AuthDatabase                     │
│  InitAuthModuleToServer           │
└──────────┬────────────────────────┘
           │  7 arquivos, 11 símbolos
           │  (LEGÍTIMO: feature usa infra)
           ▼
┌───────────────────────────────────┐
│          core_server              │
│                                   │
│  FileRoutes  ──── verifyJwt ────► │ ──► auth_server  (PROBLEMA)
│  Routes                           │
│  HttpResponseHelper               │
│  SecurityService                  │
│  DatabaseProvider                 │
│  Conversores Drift                │
└───────────────────────────────────┘
```

### Impactos

| Impacto | Descrição |
|---------|-----------|
| **Acoplamento bidirecional** | `core_server` não pode ser compilado sem `auth_server` |
| **Reusabilidade** | Impossível usar `core_server` em um serviço sem autenticação |
| **Separação de responsabilidades** | Infraestrutura conhece detalhes de uma feature específica |
| **Violação do ADR-0005** | Camada de infraestrutura depende de camada de feature |

### Plano de Correção

A correção é **mínima** — 3 arquivos, sem mudança de comportamento.

#### Passo 1 — `packages/core/core_server/lib/src/routes/file_routes.dart`

Substituir o tipo `AuthMiddleware` pelo tipo `Middleware` do `shelf`, que já é dependência de `core_server`.

```dart
// ANTES
import 'package:auth_server/auth_server.dart' show AuthMiddleware;
import 'package:shelf/shelf.dart';

class FileRoutes extends Routes {
  final AuthMiddleware _authMiddleware;

  FileRoutes(
    this._storageService,
    this._authMiddleware,                    // AuthMiddleware
    {required String backendBaseApi}
  ) : ...

  Router get router {
    router.get('...', Pipeline()
        .addMiddleware(_authMiddleware.verifyJwt)   // .verifyJwt necessário
        .addHandler(_downloadFile));
  }
}
```

```dart
// DEPOIS
// import de auth_server REMOVIDO
import 'package:shelf/shelf.dart';          // Middleware já está aqui

class FileRoutes extends Routes {
  final Middleware _authGuard;              // tipo de shelf, não de auth_server

  FileRoutes(
    this._storageService,
    this._authGuard,                        // Middleware diretamente
    {required String backendBaseApi}
  ) : ...

  Router get router {
    router.get('...', Pipeline()
        .addMiddleware(_authGuard)          // sem .verifyJwt
        .addHandler(_downloadFile));
  }
}
```

#### Passo 2 — `packages/core/core_server/pubspec.yaml`

Remover `auth_server` das dependências:

```yaml
# REMOVER esta linha de dependencies:
auth_server: ^1.1.0
```

#### Passo 3 — `servers/ems/server_v1/lib/config/injector.dart`

O chamador resolve o `Middleware` concreto antes de injetar:

```dart
// ANTES
di.registerLazySingleton<FileRoutes>(
  () => FileRoutes(
    di.get<StorageService>(),
    di.get<AuthMiddleware>(),              // passa o objeto AuthMiddleware
    backendBaseApi: Env.backendPathApi,
  ),
);
```

```dart
// DEPOIS
di.registerLazySingleton<FileRoutes>(
  () => FileRoutes(
    di.get<StorageService>(),
    di.get<AuthMiddleware>().verifyJwt,   // passa o Middleware já resolvido
    backendBaseApi: Env.backendPathApi,
  ),
);
```

> O SMS não usa `FileRoutes` — nenhuma mudança necessária em `servers/sms/`.

### Verificação Pós-Correção

```bash
# 1. core_server não deve mais listar auth_server como dependência
cd packages/core/core_server && dart pub deps | grep auth_server
# Resultado esperado: nenhuma saída

# 2. Análise estática sem erros
dart analyze packages/core/core_server
dart analyze packages/auth/auth_server
dart analyze servers/ems/server_v1

# 3. Compilação do servidor EMS
cd servers/ems/server_v1
dart compile exe bin/server.dart -o bin/server
```

---

## 2. Dockerfile — Versão do SDK Dart não fixada

### Problema

Ambos os Dockerfiles usam `FROM dart:stable` na imagem de build:

```dockerfile
# servers/ems/container/Dockerfile (linha 2)
# servers/sms/container/Dockerfile (linha 2)
FROM dart:stable AS build
```

`dart:stable` é uma tag móvel — aponta para a versão mais recente estável do Dart SDK no momento do pull. Isso cria **builds não reproduzíveis**: o mesmo `docker build` pode gerar binários diferentes dependendo de quando é executado.

### Impactos

| Impacto | Descrição |
|---------|-----------|
| **Build não reproduzível** | Mesmo commit → binários diferentes em datas distintas |
| **Inconsistência CI/CD** | Build local ≠ build em staging ≠ build em produção |
| **Risco de regressão silenciosa** | Uma atualização do SDK pode quebrar a build sem aviso |
| **Rastreabilidade** | Impossível saber qual versão do SDK gerou um binário em produção |

### Inconsistência com pubspec.yaml

Os `pubspec.yaml` de todos os pacotes e servidores declaram:

```yaml
environment:
  sdk: ^3.10.7
```

Isso significa que o código exige Dart `>= 3.10.7`. Usar `dart:stable` no Dockerfile ignora essa restrição — se a versão estável regredir ou avançar para uma major incompatível, o build falha de forma imprevisível.

### Plano de Correção

Fixar a versão do SDK na imagem Docker para corresponder à versão mínima declarada nos pubspecs.

#### `servers/ems/container/Dockerfile`

```dockerfile
# ANTES
FROM dart:stable AS build

# DEPOIS
FROM dart:3.10.7 AS build
```

#### `servers/sms/container/Dockerfile`

```dockerfile
# ANTES
FROM dart:stable AS build

# DEPOIS
FROM dart:3.10.7 AS build
```

> **Critério de escolha da versão:** `3.10.7` é a versão mínima declarada em todos os `pubspec.yaml` do projeto (`sdk: ^3.10.7`), tornando a escolha auto-documentada e consistente com o restante do codebase.

### Processo de Atualização do SDK

Quando uma nova versão do Dart for adotada no projeto:

1. Atualizar `environment.sdk` nos `pubspec.yaml` dos pacotes afetados
2. Atualizar a tag Docker nos dois `Dockerfile`s na mesma PR
3. Validar o build Docker localmente antes do merge

### Verificação Pós-Correção

```bash
# Confirmar que a imagem usa a versão correta
docker build -f servers/ems/container/Dockerfile . --target build -t ems-build-test
docker run --rm ems-build-test dart --version
# Resultado esperado: Dart SDK version: 3.10.7 ...

docker build -f servers/sms/container/Dockerfile . --target build -t sms-build-test
docker run --rm sms-build-test dart --version
# Resultado esperado: Dart SDK version: 3.10.7 ...
```
