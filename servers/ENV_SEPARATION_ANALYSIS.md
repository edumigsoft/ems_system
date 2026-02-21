# Análise: Separação de `.env` — Build × Runtime × VPS

> **Status:** Análise — base para refatoração futura
> **Criado em:** 2026-02-21
> **Contexto:** Entender quais dados de `.env` pertencem a qual fase do ciclo de vida do servidor, evitando misturar configuração de build com configuração de infraestrutura.

---

## O Problema

Existem **três contextos distintos** para variáveis de ambiente no servidor, mas eles estão parcialmente misturados nos `.env` atuais:

| Contexto | Quando é lido | Quem lê | Arquivo atual |
|---|---|---|---|
| **Build-time** | `dart pub run build_runner build` | `envied` (gerador de código) | `server_v1/.env` e `container/.env` |
| **Runtime Docker** | Ao subir o container | `docker-compose env_file` → `Platform.environment` | `container/.env` |
| **Runtime VPS-específico** | Ao subir o container na VPS | `docker-compose env_file` | `container/.env` (VPS) |

---

## Como o Servidor Usa os Valores (análise do código)

### Grupo A — Leitura em Runtime via `Platform.environment` (override correto ✅)

```dart
// servers/ems/server_v1/lib/config/injector.dart:39-45
final dbHost = Platform.environment['DB_HOST'] ?? 'localhost';
final dbPort = int.tryParse(Platform.environment['DB_PORT'] ?? EnvDatabase.dbPort) ?? 5432;
final dbUser = Platform.environment['DB_USER'] ?? EnvDatabase.dbUser;
final dbPass = Platform.environment['DB_PASS'] ?? EnvDatabase.dbPass;
final dbName = Platform.environment['DB_NAME'] ?? EnvDatabase.dbName;
```

O padrão `Platform.environment['X'] ?? EnvDatabase.x` permite que o `env_file` do docker-compose **sobrescreva** os valores baked pelo envied. Funciona corretamente — a VPS injeta suas credenciais via `container/.env` e o servidor as usa.

### Grupo B — Leitura apenas dos valores Envied (sem override de runtime ❌)

```dart
// injector.dart:60 — JWT key fixa no binário
JWTSecurityService(jwtKey: Env.jwtKey)

// injector.dart:109,118-119 — configs de auth fixas no binário
backendBaseApi: Env.backendPathApi,
accessTokenExpiresMinutes: Env.accessTokenExpiresMinutes,
refreshTokenExpiresDays: Env.refreshTokenExpiresDays,
verificationLinkBaseUrl: Env.verificationLinkBaseUrl,   // ← crítico!

// injector.dart:67 — email service fixo no binário
HttpEmailService(EmailConfig.fromEnv())   // lê Env.emailServiceApiKey
```

Esses valores são usados **diretamente do envied** — sem checar `Platform.environment`. Não importa o que o `container/.env` da VPS tenha nessas chaves: o binário ignora.

---

## O que está baked no binário publicado no GHCR hoje

Analisando o `env.g.dart` atual (gerado do dev `.env`):

```dart
// env.g.dart — valores compilados no binário
jwtKey = '2.+sF:sPN_<:aG:[s8v-7'

// Aponta para localhost — enviado em emails de verificação em produção!
verificationLinkBaseUrl = 'http://localhost:8181/api/v1/auth/verify'

emailServiceApiKey = 'your_api_key_here'   // placeholder de dev
emailServiceHost = 'smtp.example.com'       // placeholder de dev
apiKey = 'ca31ea6d...'                     // chave de dev
```

---

## Mapa Completo de Variáveis

### `servers/ems/server_v1/.env` — lido pelo build_runner (envied `path: '.env'`)

| Variável | Grupo | Lida em runtime? | Impacto se errada |
|---|---|---|---|
| `SERVER_PORT` | Runtime | Sim (via `PORT` env) | Baixo |
| `JWT_KEY` | **Build** | **Não** | **Alto — segurança** |
| `API_KEY` | **Build** | **Não** | **Alto — segurança** |
| `ENABLE_DOCS` | **Build** | **Não** | Médio |
| `BACKEND_PATH_API` | **Build** | **Não** | Médio — rotas erradas |
| `ACCESS_TOKEN_EXPIRES_MINUTES` | **Build** | **Não** | Médio |
| `REFRESH_TOKEN_EXPIRES_DAYS` | **Build** | **Não** | Médio |
| `MAX_LOGIN_ATTEMPTS_*` | **Build** | **Não** | Médio |
| `ACCOUNT_LOCKOUT_MINUTES` | **Build** | **Não** | Médio |
| `IP_BLOCK_MINUTES` | **Build** | **Não** | Médio |
| `VERIFICATION_LINK_BASE_URL` | **Build** | **Não** | **Alto — emails com localhost** |
| `EMAIL_SERVICE_HOST` | **Build** | **Não** | **Alto — emails não enviados** |
| `EMAIL_SERVICE_PORT` | **Build** | **Não** | Alto |
| `EMAIL_SERVICE_API_KEY` | **Build** | **Não** | **Alto — placeholder em prod** |

### `servers/ems/container/.env` — lido pelo docker-compose (envied `path: '../container/.env'`)

| Variável | Grupo | Lida em runtime? | Impacto se errada |
|---|---|---|---|
| `DB_HOST` | Runtime | **Sim** (`Platform.environment`) | Resolvido ✅ |
| `DB_PORT` | Runtime | **Sim** (`Platform.environment`) | Resolvido ✅ |
| `DB_USER` | Runtime | **Sim** (`Platform.environment`) | Resolvido ✅ |
| `DB_PASS` | Runtime | **Sim** (`Platform.environment`) | Resolvido ✅ |
| `DB_NAME` | Runtime | **Sim** (`Platform.environment`) | Resolvido ✅ |
| `SERVER_PORT` | Infra | Sim (docker-compose) | Resolvido ✅ |
| `UPLOADS_HOST_PATH` | **Infra VPS** | Não (só docker-compose volumes) | N/A para build |
| `LOGS_HOST_PATH` | **Infra VPS** | Não (só docker-compose volumes) | N/A para build |

---

## Separação Necessária

### Situação atual (problemática)

```
publish.sh                      dev.sh / build_runner
    │                                │
    ▼                                ▼
Dockerfile (dart compile)      build_runner build
    │                                │
    └── usa env.g.dart atual ←── gerado com dev .env
              │
              ▼
       valores de DEV baked
       no binário de PRODUÇÃO
```

### Situação desejada

```
┌──────────────────────────────────────────────────────┐
│  server_v1/.env.build.prod                          │
│  (valores de produção para build_runner)            │
│  - JWT_KEY=chave_producao                           │
│  - VERIFICATION_LINK_BASE_URL=https://api.ems.*     │
│  - EMAIL_SERVICE_API_KEY=chave_email_real           │
│  NÃO versionado, NÃO commitado                      │
└──────────────────┬───────────────────────────────────┘
                   │  build_runner --define antes de publish.sh
                   ▼
              env.g.dart (com valores de prod)
                   │
                   ▼
              publish.sh → GHCR (imagem correta)

┌──────────────────────────────────────────────────────┐
│  container/.env (VPS)                                │
│  (valores de runtime/infraestrutura)                 │
│  - DB_HOST, DB_PASS, DB_NAME (já em Platform.env)   │
│  - UPLOADS_HOST_PATH (só para volumes docker)        │
│  - SERVER_PORT                                       │
│  NÃO versionado, chmod 600                          │
└──────────────────────────────────────────────────────┘
```

---

## Abordagem Recomendada — `path:` do envied como mecanismo de separação

O parâmetro `path:` do `@Envied` permite apontar para arquivos distintos por propósito. Isso possibilita uma separação limpa sem eliminar o envied completamente — apenas redefinindo seu papel.

### O novo papel do envied

> **Envied = documentação de defaults não-sensíveis baked no binário.**
> **`Platform.environment` = tudo que é segredo ou específico do ambiente.**

### Estrutura de arquivos proposta

```
servers/ems/server_v1/
├── .env                 # gitignored — runtime local (dart run + dev docker)
│                        # contém TODOS os valores incluindo secrets de dev
├── .env.example         # gittracked — documentação (já existe)
│                        # valores de exemplo/placeholder
└── .env.defaults        # gittracked — NOVO, input do build_runner (envied)
                         # APENAS defaults não-sensíveis e agnósticos de ambiente

servers/ems/container/
├── .env                 # gitignored — runtime docker (dev e VPS)
│                        # injeta via env_file: DB, paths, porta
└── .env_example         # gittracked — documentação (já existe)
```

### O que vai em cada arquivo

**`server_v1/.env.defaults`** — gittracked, lido pelo build_runner via `path: '.env.defaults'`

```env
# Defaults não-sensíveis, agnósticos de ambiente
# Todos sobrescrevíveis via Platform.environment em runtime

BACKEND_PATH_API=/api/v1
SERVER_PORT=8181
ENABLE_DOCS=false

# Rate limiting (raramente diferem por ambiente)
ACCESS_TOKEN_EXPIRES_MINUTES=15
REFRESH_TOKEN_EXPIRES_DAYS=7
MAX_LOGIN_ATTEMPTS_PER_ACCOUNT=5
MAX_LOGIN_ATTEMPTS_PER_IP=10
ACCOUNT_LOCKOUT_MINUTES=30
IP_BLOCK_MINUTES=15

# DB defaults para docker (dev e prod usam o mesmo nome de container)
DB_HOST=postgres_ems_system
DB_PORT=5432
```

**`server_v1/.env`** — gitignored, runtime local (não lido pelo build_runner após refatoração)

```env
# Secrets e valores específicos do ambiente de DEV
JWT_KEY=dev_jwt_key_local_apenas
API_KEY=dev_api_key
DB_NAME=ems_development
DB_USER=ems_dev_user
DB_PASS=dev_password
VERIFICATION_LINK_BASE_URL=https://api.ems.local/api/v1/auth/verify
EMAIL_SERVICE_HOST=localhost      # mailpit/mailhog local
EMAIL_SERVICE_PORT=1025
EMAIL_SERVICE_API_KEY=not-needed-dev
```

**`container/.env`** — gitignored, injetado via `env_file:` no docker-compose

```env
# Infraestrutura Docker — dev ou VPS
DB_NAME=ems_production            # (ou ems_development no dev)
DB_USER=ems_user
DB_PASS=senha_forte
SERVER_PORT=8181
UPLOADS_HOST_PATH=/opt/ems_system/data/uploads/ems
LOGS_HOST_PATH=/opt/ems_system/logs/ems
# Secrets de produção (injeta e sobrescreve os defaults do binário)
JWT_KEY=chave_jwt_producao
API_KEY=chave_api_producao
VERIFICATION_LINK_BASE_URL=https://api.ems.edumigsoft.com.br/api/v1/auth/verify
EMAIL_SERVICE_HOST=smtp.producao.com
EMAIL_SERVICE_API_KEY=chave_email_producao
```

### Mudança no `env.dart`

```dart
// ANTES — path aponta para .env (segredos de dev baked no binário)
@Envied(path: '.env', name: 'Env', ...)

// DEPOIS — path aponta para .env.defaults (apenas non-sensitive defaults)
@Envied(path: '.env.defaults', name: 'Env', ...)
```

### Mudança no padrão de leitura (`injector.dart`)

Dividir em dois padrões conforme a sensibilidade:

**Secrets — obrigatório via `Platform.environment`, sem fallback de envied:**
```dart
// Falha na inicialização se não configurado — correto para produção
final jwtKey = Platform.environment['JWT_KEY']
    ?? (throw StateError('JWT_KEY is required'));

final apiKey = Platform.environment['API_KEY']
    ?? (throw StateError('API_KEY is required'));

final verificationUrl = Platform.environment['VERIFICATION_LINK_BASE_URL']
    ?? (throw StateError('VERIFICATION_LINK_BASE_URL is required'));

final emailApiKey = Platform.environment['EMAIL_SERVICE_API_KEY']
    ?? (throw StateError('EMAIL_SERVICE_API_KEY is required'));
```

**Defaults não-sensíveis — `Platform.environment` com fallback envied:**
```dart
// Usa valor baked do .env.defaults se não injetado
final backendPath = Platform.environment['BACKEND_PATH_API'] ?? Env.backendPathApi;
final port = int.tryParse(Platform.environment['SERVER_PORT'] ?? '') ?? Env.serverPort;
final maxAttempts = int.tryParse(Platform.environment['MAX_LOGIN_ATTEMPTS_PER_ACCOUNT'] ?? '')
    ?? Env.maxLoginAttemptsPerAccount;
```

### Resultado do `env.g.dart` após refatoração

```dart
// Gerado de .env.defaults — seguro para commitar, sem segredos
final class _Env {
  static const String backendPathApi = '/api/v1';
  static const int serverPort = 8181;
  static const bool enableDocs = false;
  static const int accessTokenExpiresMinutes = 15;
  static const int refreshTokenExpiresDays = 7;
  // ... apenas rate limits e defaults técnicos
  // JWT_KEY, API_KEY, EMAIL_* → removidos daqui
}
```

### Fluxo por contexto

```
DEV (dart run ou docker dev)
─────────────────────────────
build_runner lê .env.defaults  →  env.g.dart com defaults seguros
dart run (carrega .env local)  →  Platform.environment tem JWT, email etc.
                               →  server inicia com tudo configurado ✅

PUBLISH (publish.sh → GHCR)
─────────────────────────────
build_runner já rodou com .env.defaults  →  env.g.dart sem segredos
docker build + dart compile              →  binário com apenas defaults
push para GHCR                          →  imagem agnóstica de ambiente ✅

PRODUÇÃO (VPS)
─────────────────────────────
docker compose -f docker-compose.prod.yml up
  env_file: container/.env              →  Platform.environment com TUDO
  (JWT_KEY, DB_PASS, VERIFICATION_URL, etc.)
server inicia:
  Platform.environment['JWT_KEY'] ✅    →  usa valor da VPS
  Platform.environment['DB_HOST'] ✅    →  usa valor da VPS
  Env.backendPathApi (fallback) ✅       →  usa default do binário se não injetado
```

---

## Separação Final das Responsabilidades

| Arquivo | Versionado | Lido por | Contém |
|---|---|---|---|
| `server_v1/.env.defaults` | ✅ Sim | build_runner (envied) | defaults não-sensíveis |
| `server_v1/.env.example` | ✅ Sim | humanos | documentação de todas as vars |
| `server_v1/.env` | ❌ Não | dart run (local) | secrets de dev + todas as vars |
| `container/.env_example` | ✅ Sim | humanos | documentação de vars docker |
| `container/.env` (dev) | ❌ Não | docker-compose.dev.yml | infra local + secrets dev |
| `container/.env` (VPS) | ❌ Não | docker-compose.prod.yml | infra VPS + secrets prod |

---

## Impacto nos Documentos de Planejamento

- `VPS_STRUCTURE_PROPOSAL.md` — o `container/.env` da VPS passa a ser a fonte autoritativa de TODOS os secrets de produção, incluindo os que antes eram ignorados (JWT, email, etc.)
- `DEV_LOCAL_SETUP.md` — o `server_v1/.env` local tem os secrets de dev; o `container/.env` de dev tem infra docker. Ambos carregam via docker-compose ou dart run.

---

## Checklist de Implementação

### `env.dart` (EMS e SMS)
- [ ] Mudar `@Envied(path: '.env', ...)` para `@Envied(path: '.env.defaults', ...)`
- [ ] Remover os campos de secrets (`jwtKey`, `apiKey`, `emailServiceApiKey`, etc.) da classe `Env`
- [ ] Manter apenas os defaults não-sensíveis na classe `Env`
- [ ] Remover `EnvDatabase` completamente (DB já é via `Platform.environment`)

### `injector.dart` (EMS e SMS)
- [ ] Campos de secrets: usar `Platform.environment['X'] ?? (throw StateError(...))`
- [ ] Campos de defaults: manter `Platform.environment['X'] ?? Env.x`
- [ ] Verificar `EmailConfig.fromEnv()` — refatorar para ler de `Platform.environment`

### Novos arquivos
- [ ] Criar `server_v1/.env.defaults` (EMS e SMS) — gittracked, apenas defaults
- [ ] Atualizar `server_v1/.env.example` (EMS e SMS) — documentar separação de responsabilidades

### `.gitignore`
- [ ] Garantir que `server_v1/.env` está ignorado (já deve estar)
- [ ] Garantir que `server_v1/.env.defaults` NÃO está ignorado (novo, deve ser versionado)

### `build_runner`
- [ ] Rodar `dart run build_runner build --delete-conflicting-outputs` após mudança de path
- [ ] Verificar `env.g.dart` gerado — não deve conter JWT, API keys ou URLs de ambiente
