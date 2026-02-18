# Plano: API Key Middleware — Proteger Servidor de Clientes Não-Legítimos

## Contexto

Com a remoção do CORS (exclusivo de browsers), qualquer cliente HTTP pode chamar os endpoints do servidor. O JWT protege dados autenticados, mas endpoints públicos (login, registro) ficam expostos a scrapers e bots. A solução é adicionar uma **API Key compartilhada** entre app e servidor: o cliente envia a chave em todo request, o servidor rejeita requests sem a chave válida. A chave é obfuscada no binário do app via `envied` (`obfuscate: true`), elevando significativamente a barreira de entrada para robôs.

**Arquitetura:** Cada sistema (EMS, SMS) terá sua própria API Key. A chave é definida nos `.env` files (nunca commitados), lida via `envied` tanto no servidor (Dart/Shelf) quanto no app (Flutter).

---

## Arquivos a Criar

| Arquivo | Descrição |
|---------|-----------|
| `packages/core/core_server/lib/src/middleware/api_key_middleware.dart` | Middleware Shelf: valida `X-Api-Key` header |
| `packages/core/core_client/lib/src/interceptors/api_key_interceptor.dart` | Interceptor Dio: injeta `X-Api-Key` em todo request |

---

## Arquivos a Modificar

| Arquivo | Mudança |
|---------|---------|
| `packages/core/core_server/lib/core_server.dart` | Exportar `ApiKeyMiddleware` |
| `packages/core/core_client/lib/core_client.dart` | Exportar `ApiKeyInterceptor` |
| `servers/ems/server_v1/lib/config/env/env.dart` | Adicionar campo `apiKey` |
| `servers/sms/server_v1/lib/config/env/env.dart` | Adicionar campo `apiKey` |
| `servers/ems/server_v1/bin/server.dart` | Adicionar middleware ao pipeline |
| `servers/sms/server_v1/bin/server.dart` | Adicionar middleware ao pipeline |
| `apps/ems/app_v1/lib/config/env/env.dart` | Adicionar campo `apiKey` (obfuscado) |
| `apps/sms/app_v1/lib/config/env/env.dart` | Adicionar campo `apiKey` (obfuscado) |
| `apps/ems/app_v1/lib/config/di/injector.dart` | Adicionar `ApiKeyInterceptor` ao Dio |
| `apps/sms/app_v1/lib/config/di/injector.dart` | Adicionar `ApiKeyInterceptor` ao Dio |
| `servers/ems/server_v1/.env` | Adicionar `API_KEY=<valor>` |
| `servers/sms/server_v1/.env` | Adicionar `API_KEY=<valor>` |
| `apps/ems/app_v1/.env` | Adicionar `API_KEY=<valor>` (mesmo do server EMS) |
| `apps/sms/app_v1/.env` | Adicionar `API_KEY=<valor>` (mesmo do server SMS) |

---

## Implementação Detalhada

### 1. `ApiKeyMiddleware` (core_server)

Padrão idêntico ao `RateLimit` existente — classe com `Middleware get middleware`.

```dart
// packages/core/core_server/lib/src/middleware/api_key_middleware.dart
import 'package:shelf/shelf.dart';

class ApiKeyMiddleware {
  final String apiKey;
  static const _headerName = 'x-api-key';

  // Mensagem genérica e idêntica para qualquer falha (ausente OU inválida).
  // Não revela ao atacante qual condição falhou.
  static const _unauthorizedBody =
      '{"error": "Unauthorized", "message": "Acesso negado"}';

  const ApiKeyMiddleware({required this.apiKey});

  Middleware get middleware {
    return (Handler handler) {
      return (Request request) async {
        final key = request.headers[_headerName];
        if (key == null || key != apiKey) {
          return Response.unauthorized(
            _unauthorizedBody,
            headers: {'content-type': 'application/json'},
          );
        }
        return handler(request);
      };
    };
  }
}
```

### 2. `ApiKeyInterceptor` (core_client)

```dart
// packages/core/core_client/lib/src/interceptors/api_key_interceptor.dart
import 'package:dio/dio.dart';

class ApiKeyInterceptor extends Interceptor {
  final String apiKey;
  static const _headerName = 'x-api-key';

  const ApiKeyInterceptor({required this.apiKey});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[_headerName] = apiKey;
    super.onRequest(options, handler);
  }
}
```

### 3. Exports em core_server.dart e core_client.dart

```dart
// core_server.dart — adicionar linha:
export 'src/middleware/api_key_middleware.dart';

// core_client.dart — adicionar linha:
export 'src/interceptors/api_key_interceptor.dart';
```

### 4. Env dos servidores

```dart
// Em AMBOS os servers/*/server_v1/lib/config/env/env.dart
// Adicionar campo após backendPathApi:
@EnviedField()
static const String apiKey = _Env.apiKey;
```

### 5. Pipeline dos servidores

```dart
// Em AMBOS os servers/*/server_v1/bin/server.dart
// Adicionar import:
import 'package:core_server/core_server.dart' show ..., ApiKeyMiddleware;

// Pipeline:
final apiKeyMiddleware = ApiKeyMiddleware(apiKey: Env.apiKey);
final handler = Pipeline()
    .addMiddleware(rateLimit.middleware)        // 1º: protege contra DoS
    .addMiddleware(apiKeyMiddleware.middleware) // 2º: rejeita clientes não-legítimos
    .addMiddleware(logRequests())
    .addHandler(addRouters.call);
```

> **Ordem:** Rate limit ANTES do API key — evita que um atacante consuma rate limit antes mesmo de ser validado (DoS barato).

### 6. Env dos apps (obfuscado)

```dart
// Em AMBOS os apps/*/app_v1/lib/config/env/env.dart
// Adicionar campo (obfuscate: true protege o valor no binário compilado):
@EnviedField(varName: 'API_KEY', obfuscate: true)
static const String apiKey = _Env.apiKey;
```

### 7. Injector dos apps

```dart
// apps/ems/app_v1/lib/config/di/injector.dart
// Em _setupDioInterceptors, adicionar ApiKeyInterceptor ANTES de AuthInterceptor:
dio.interceptors.addAll([
  ApiKeyInterceptor(apiKey: Env.apiKey), // Injeta X-Api-Key em todo request
  di.get<AuthInterceptor>(),
  SafeLogInterceptor(),
  aliceDioAdapter,
]);
```

> **Nota:** O `SafeLogInterceptor` já filtra `api_key` dos logs — nenhuma mudança necessária lá.

### 8. Valores nos `.env` (feito automaticamente durante implementação)

⚠️ O `envied` lê o `.env` em **tempo de build** — as chaves devem existir **antes** do `build_runner`.

Durante a implementação, será gerado automaticamente via `openssl rand -hex 32`:
- Um valor para EMS → adicionado em `servers/ems/server_v1/.env` e `apps/ems/app_v1/.env`
- Um valor para SMS → adicionado em `servers/sms/server_v1/.env` e `apps/sms/app_v1/.env`

Os `.env` não são commitados ao git, portanto editar esses arquivos é seguro.

---

## Fase de Regeneração

Após inserir `API_KEY` nos `.env` e `apiKey` nos `env.dart`, executar `build_runner` em 4 projetos:

```bash
# Servidores
dart run build_runner build --delete-conflicting-outputs  # em servers/ems/server_v1
dart run build_runner build --delete-conflicting-outputs  # em servers/sms/server_v1

# Apps
dart run build_runner build --delete-conflicting-outputs  # em apps/ems/app_v1
dart run build_runner build --delete-conflicting-outputs  # em apps/sms/app_v1
```

---

## Verificação

```bash
# Análise estática
dart analyze lib/ bin/   # em cada server
dart analyze lib/        # em apps e packages modificados

# Teste manual (deve retornar 401 com mensagem genérica):
curl -X GET http://localhost:8181/api/v1/health
# {"error": "Unauthorized", "message": "Acesso negado"}
# Mesma resposta se a chave estiver ausente OU incorreta (sem dicas ao atacante)

# Teste com chave correta (deve passar):
curl -X GET http://localhost:8181/api/v1/health -H "x-api-key: <sua-chave>"
```

---

## Limitações conhecidas

- A chave pode ser extraída do binário com ferramentas de engenharia reversa (mais difícil com `obfuscate: true`, mas não impossível)
- Para ambientes de produção de alto risco, considerar mTLS (próximo passo)
- A chave é estática — rotação requer novo build do app
