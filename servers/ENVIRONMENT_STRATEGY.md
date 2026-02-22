# Estratégia de Variáveis de Ambiente

## Regra Fundamental

| Tipo | Fonte | Comportamento |
|------|-------|---------------|
| Defaults não-sensíveis | `.env.defaults` (build-time via `envied`) | Fallback via `Env.*` |
| Secrets e credenciais | `Platform.environment` (runtime) | **Hard fail** se ausente |

**Regra de Ouro:** nenhum secret ou credencial entra no binário. Qualquer variável que confira acesso a dados ou emita tokens deve ser obrigatoriamente injetada em runtime, sem fallback.

---

## Classificação das Variáveis

### Build-time — `envied` + `.env.defaults` (rastreado pelo Git)

Contém apenas parâmetros operacionais genéricos e não-sensíveis:

```
SERVER_PORT, BACKEND_PATH_API, ENABLE_DOCS
ACCESS_TOKEN_EXPIRES_MINUTES, REFRESH_TOKEN_EXPIRES_DAYS
MAX_LOGIN_ATTEMPTS_PER_ACCOUNT, MAX_LOGIN_ATTEMPTS_PER_IP
ACCOUNT_LOCKOUT_MINUTES, IP_BLOCK_MINUTES
```

Uso no código: `Env.serverPort`, `Env.backendPathApi`, etc.

### Runtime — `Platform.environment` (hard fail)

Toda variável abaixo causa `StateError` imediato se ausente — a aplicação não sobe:

```
JWT_KEY                    # Chave de assinatura JWT
VERIFICATION_LINK_BASE_URL # URL base para e-mails de verificação
DB_HOST, DB_PORT           # Conexão com banco de dados
DB_USER, DB_PASS, DB_NAME  # Credenciais do banco de dados
```

---

## Padrão de Implementação (`injector.dart`)

```dart
// Hard fail — secrets e credenciais
final jwtKey = Platform.environment['JWT_KEY'] ??
    (throw StateError('JWT_KEY is required but not set in environment'));

final dbPass = Platform.environment['DB_PASS'] ??
    (throw StateError('DB_PASS is required but not set in environment'));

// Fallback permitido — defaults operacionais apenas
final port = int.tryParse(Platform.environment['SERVER_PORT'] ?? '') ?? Env.serverPort;
final backendPath = Platform.environment['BACKEND_PATH_API'] ?? Env.backendPathApi;
```

---

## Arquivos de Ambiente

| Arquivo | Git | Propósito |
|---------|-----|-----------|
| `server_v1/.env.defaults` | Rastreado | Fonte do `envied` — defaults não-sensíveis |
| `server_v1/.env` | Ignorado | Runtime local (bare-metal) — secrets de desenvolvimento |
| `container/.env` | Ignorado | Runtime Docker — secrets para orquestração de containers |
