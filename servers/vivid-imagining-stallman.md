# Plano: Pacote Base Compartilhado para Servidores EMS/SMS

## Contexto

Os servidores EMS (`servers/ems/server_v1/`) e SMS (`servers/sms/server_v1/`) são
estruturalmente quase idênticos. Toda a infraestrutura comum (banco de dados, segurança,
rotas base, middleware de auth) está duplicada verbatim. A única diferença real é o
conjunto de módulos de feature que cada servidor registra. Isso causa problemas de
manutenção: qualquer mudança na infraestrutura precisa ser aplicada nos dois lugares,
e bugs surgem por descuido (ex: o SMS atualmente loga `'EMS SERVER V1'`).

O objetivo é extrair a infra comum para um pacote `server_base`, deixando cada servidor
apenas com suas dependências de feature e configurações específicas.

---

## Análise de Duplicação

| Arquivo | EMS | SMS | Status |
|---------|-----|-----|--------|
| `lib/middleware/auth_required.dart` | ✓ | ✓ | 100% idêntico → mover para base |
| `lib/config/env/env.dart` | ✓ | ✓ | 100% idêntico em estrutura, mas **não pode ser compartilhado** (paths relativos `@Envied`) |
| `build.yaml` | ✓ | ✓ | 100% idêntico, mas **deve ficar por servidor** (reflectable gera `bin/server.reflectable.dart` localmente) |
| `lib/config/injector.dart` | ✓ | ✓ | ~90% idêntico → refatorar, manter apenas modules específicos |
| `bin/server.dart` | ✓ | ✓ | ~95% idêntico → corrigir SMS (versão hardcoded) |

**Bugs encontrados no SMS:**
- `injector.dart`: `LogService.getLogger('EMS SERVER V1')` → deve ser `'SMS SERVER V1'`
- `bin/server.dart`: `version: '1.0.0'` hardcoded → deve usar `String.fromEnvironment()`

---

## Abordagem: Pacote `server_base`

Criar `servers/shared/server_base/` — pacote Dart puro (sem geração de código, sem `.env`).
Cada servidor constrói um `ServerBaseConfig` com seus valores de `Env` locais e passa para
funções compartilhadas.

**Por que não compartilhar `env.dart`?**
O `@Envied(path: '../container/.env')` usa paths relativos ao pacote onde é compilado.
Mover para um pacote compartilhado quebraria a resolução do `.env` de cada servidor.

**Por que `bin/server.dart` permanece por servidor?**
O `build.yaml` de cada servidor configura `reflectable_builder` para gerar
`bin/server.reflectable.dart` a partir de `bin/server.dart`. A anotação `@api`/`@ApiInfo`
deve estar no arquivo que o reflectable processa — não pode estar em um pacote externo.

---

## Estrutura do Novo Pacote

```
servers/
  shared/
    server_base/
      pubspec.yaml
      analysis_options.yaml
      lib/
        server_base.dart                              # barrel export
        src/
          config/
            server_base_config.dart                   # value object com config por servidor
          middleware/
            auth_required_impl.dart                   # movido de ambos os servidores
          infrastructure/
            registry_base_infrastructure.dart         # DB + segurança + rotas base
            registry_common_modules.dart              # módulos User + Auth (comuns)
```

---

## Arquivos a Criar

### `servers/shared/server_base/pubspec.yaml`
```yaml
name: server_base
description: Shared server infrastructure for EMS System services
publish_to: none
version: 1.0.0
resolution: workspace
environment:
  sdk: ^3.10.7
dependencies:
  dart_jsonwebtoken: ^3.3.1
  core_shared: ^1.1.0
  core_server: ^1.1.0
  open_api_server: ^1.1.0
  auth_server: ^1.1.0
  user_server: ^1.1.0
dev_dependencies:
  lints: ^6.0.0
  test: ^1.26.0
```
> Sem `envied`, `reflectable`, `build_runner` — este pacote não tem código gerado.

### `servers/shared/server_base/analysis_options.yaml`
```yaml
include: ../../../analysis_options_dart.yaml
```

### `lib/src/config/server_base_config.dart`
Value object que encapsula todos os valores de `Env` necessários pela infra base:
```dart
class ServerBaseConfig {
  final String dbHost, dbName, dbUser, dbPass;
  final int dbPort;
  final bool dbUseSsl;
  final String jwtKey, backendPathApi, apiKey;
  final int accessTokenExpiresMinutes, refreshTokenExpiresDays;
  final String verificationLinkBaseUrl;
  final String? appVersion, environment;
  const ServerBaseConfig({...});
}
```

### `lib/src/infrastructure/registry_base_infrastructure.dart`
Extrai as fases 1–4a dos `injector.dart` atuais (idênticas em ambos):
```dart
Future<DependencyInjector> registryBaseInfrastructure(
  ServerBaseConfig config, {
  String loggerName = 'SERVER',
}) async {
  // Fase 1: DatabaseProvider + connect()
  // Fase 2: CryptService, SecurityService<JWT>, SecurityService<dynamic>, EmailService
  // Fase 3: AddRoutes, HealthRoutes, OpenApiRoutes
  // Fase 4a: AuthMiddleware (pré-registro para resolver circular Auth ↔ User)
  return di;
}
```

### `lib/src/infrastructure/registry_common_modules.dart`
Extrai User + Auth, presentes em ambos os servidores:
```dart
Future<void> registryCommonModules(
  DependencyInjector di,
  ServerBaseConfig config,
) async {
  await InitUserModuleToServer.init(di: di, backendBaseApi: config.backendPathApi);
  await InitAuthModuleToServer.init(
    di: di,
    backendBaseApi: config.backendPathApi,
    security: false,
    accessTokenExpiresMinutes: config.accessTokenExpiresMinutes,
    refreshTokenExpiresDays: config.refreshTokenExpiresDays,
    verificationLinkBaseUrl: config.verificationLinkBaseUrl,
  );
}
```

### `lib/src/middleware/auth_required_impl.dart`
Cópia do `auth_required.dart` de qualquer um dos servidores (são idênticos).

### `lib/server_base.dart`
```dart
export 'src/config/server_base_config.dart';
export 'src/middleware/auth_required_impl.dart';
export 'src/infrastructure/registry_base_infrastructure.dart';
export 'src/infrastructure/registry_common_modules.dart';
```

---

## Arquivos a Modificar

### `pubspec.yaml` (raiz do workspace)
Adicionar `servers/shared/server_base` à lista de membros do workspace.

### `servers/ems/server_v1/pubspec.yaml`
Adicionar dependência: `server_base: ^1.0.0`

### `servers/sms/server_v1/pubspec.yaml`
Adicionar dependência: `server_base: ^1.0.0`

### `servers/ems/server_v1/lib/config/injector.dart`
Substituir ~80 linhas de boilerplate por:
```dart
Future<DependencyInjector> registryInjectors() async {
  final config = ServerBaseConfig(
    dbHost: Platform.environment['DB_HOST'] ?? 'localhost',
    dbPort: int.tryParse(Platform.environment['DB_PORT'] ?? EnvDatabase.dbPort) ?? 5432,
    // ... demais campos do Env local
  );

  final di = await registryBaseInfrastructure(config, loggerName: 'EMS SERVER V1');
  await registryCommonModules(di, config);

  // Módulos específicos do EMS
  await InitTagModuleToServer.init(di: di, backendBaseApi: Env.backendPathApi, security: false);
  await InitNotebookModuleToServer.init(di: di, backendBaseApi: Env.backendPathApi, security: false);

  // FileRoutes (EMS-específico)
  di.registerLazySingleton<FileRoutes>(
    () => FileRoutes(di.get<StorageService>(), di.get<AuthMiddleware>(), backendBaseApi: Env.backendPathApi),
  );
  addRoutes(di, di.get<FileRoutes>(), security: false);

  return di;
}
```

### `servers/sms/server_v1/lib/config/injector.dart`
Idem ao EMS, mantendo apenas `InitSchoolModuleToServer` + **corrigindo o bug** do logger:
```dart
final di = await registryBaseInfrastructure(config, loggerName: 'SMS SERVER V1'); // bug fix
await registryCommonModules(di, config);
await InitSchoolModuleToServer.init(di: di, backendBaseApi: Env.backendPathApi, security: false);
```

### `servers/sms/server_v1/bin/server.dart`
Corrigir versão hardcoded para usar `String.fromEnvironment()`:
```dart
// ANTES:
@ApiInfo(title: 'SMS System API', version: '1.0.0', ...)

// DEPOIS:
const version = String.fromEnvironment('APP_VERSION', defaultValue: 'unknown');
@ApiInfo(title: 'SMS System API', version: version, ...)
```

---

## Arquivos a Deletar

| Arquivo | Motivo |
|---------|--------|
| `servers/ems/server_v1/lib/middleware/auth_required.dart` | Movido para `server_base` |
| `servers/sms/server_v1/lib/middleware/auth_required.dart` | Movido para `server_base` |

---

## Arquivos Inalterados (com justificativa)

| Arquivo | Motivo |
|---------|--------|
| `lib/config/env/env.dart` (ambos) | `@Envied` usa paths relativos ao pacote |
| `build.yaml` (ambos) | `reflectable_builder` deve apontar para `bin/server.dart` local |
| `bin/server.dart` do EMS | Já está correto (`String.fromEnvironment`) |

---

## Ordem de Implementação

1. Criar estrutura de diretórios `servers/shared/server_base/`
2. Escrever `pubspec.yaml` e `analysis_options.yaml` do `server_base`
3. Criar `ServerBaseConfig` (sem dependências externas)
4. Criar `auth_required_impl.dart` (cópia de qualquer um dos servidores)
5. Criar `registry_base_infrastructure.dart`
6. Criar `registry_common_modules.dart`
7. Criar `server_base.dart` (barrel)
8. Adicionar `server_base` ao `pubspec.yaml` raiz
9. Rodar `dart pub get` na raiz → validar resolução
10. Rodar `dart analyze servers/shared/server_base` → 0 issues
11. Modificar EMS: `pubspec.yaml` + `injector.dart` + deletar `auth_required.dart`
12. Rodar `dart analyze servers/ems/server_v1` → 0 issues
13. Modificar SMS: `pubspec.yaml` + `injector.dart` + `bin/server.dart` + deletar `auth_required.dart`
14. Rodar `dart analyze servers/sms/server_v1` → 0 issues

---

## Verificação

```bash
# Validar o novo pacote base
dart analyze servers/shared/server_base

# Validar cada servidor após refatoração
dart analyze servers/ems/server_v1
dart analyze servers/sms/server_v1

# Testar inicialização (com .env configurado)
cd servers/ems/server_v1 && dart run bin/server.dart
cd servers/sms/server_v1 && dart run bin/server.dart
```

Pontos de atenção durante os testes:
- Log de startup deve mostrar `EMS SERVER V1` e `SMS SERVER V1` respectivamente (bug fix)
- Swagger em `/api/v1/docs` deve exibir título correto de cada servidor
- Versão do SMS deve exibir `unknown` (ou o valor de `--define=APP_VERSION=X.Y.Z`)
- Endpoints de health check devem responder em ambos os servidores
