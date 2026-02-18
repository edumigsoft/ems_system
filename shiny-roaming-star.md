# Plano: Remover Suporte à Plataforma Web

## Contexto

O sistema EMS/SMS foi inicialmente desenvolvido com suporte à plataforma web do Flutter, o que gerou código específico para web espalhado por apps, pacotes compartilhados e servidores. A decisão foi tomada de direcionar o sistema **exclusivamente para Desktop (Linux/Windows) e Mobile**, tornando todo esse código desnecessário e uma fonte de ruído e complexidade.

O objetivo é remover:
- Diretórios `web/` dos apps Flutter
- Todas as referências `kIsWeb` no código Dart
- Middleware CORS nos servidores (CORS é um mecanismo exclusivo de browsers)
- Configurações web em `pubspec.yaml` (icons_launcher, names_launcher)

---

## Fase 1 — Deletar Diretórios Web

| Diretório | Ação |
|-----------|------|
| `apps/ems/app_v1/web/` | Deletar |
| `apps/ems/app_design_draft/web/` | Deletar |
| `apps/sms/app_v1/web/` | Deletar |
| `apps/ems/app_v1/build/web/` | Deletar (artefato de build) |

---

## Fase 2 — Código Dart do App EMS (`apps/ems/app_v1/lib/`)

### `lib/main.dart`
- Remover: `import 'package:flutter/foundation.dart' show kIsWeb;`
- Substituir bloco Alice condicional (linhas 11-24) pela forma direta:
  ```dart
  final alice = Alice(
    configuration: AliceConfiguration(
      showNotification: false,
      showInspectorOnShake: true,
    ),
  );
  ```
- Remover `(kIsWeb: $kIsWeb)` do debug print (linha 74)

### `lib/app_layout.dart`
- Remover: `import 'package:flutter/foundation.dart' show kIsWeb;`
- Remover comentário sobre "hot reload em web" (linha 106)
- Remover `(kIsWeb: $kIsWeb)` do debug print (linha 112)
- Linha 187: `navigatorKey: kIsWeb ? null : alice.getNavigatorKey()` → `navigatorKey: alice.getNavigatorKey()`

### `lib/config/di/injector.dart`
- ⚠️ Manter `import 'package:flutter/foundation.dart';` (usado por `kReleaseMode`)
- Linha 98: `'Platform: ${kIsWeb ? "WEB" : "NATIVE"}'` → `'Platform: NATIVE'`
- Linhas 101-105: Simplificar effectiveServerType:
  ```dart
  // ANTES:
  final effectiveServerType = (kReleaseMode && !kIsWeb) ? 'remote' : settings.serverType;
  // DEPOIS:
  final effectiveServerType = kReleaseMode ? 'remote' : settings.serverType;
  ```
- Linhas 178-198: Remover `if (!kIsWeb) { ... } else { ... }`, manter apenas o bloco nativo (sempre adiciona Alice adapter)

### `lib/main_development.dart` / `lib/main_staging.dart` / `lib/main_production.dart`
Mesma mudança em todos os 3 arquivos:
- Remover: `import 'package:flutter/foundation.dart' show kIsWeb;`
- `writeToFile: !kIsWeb` → `writeToFile: true`
- Remover `(web: $kIsWeb)` da mensagem de log

---

## Fase 3 — Código Dart dos Pacotes Compartilhados

### `packages/auth/auth_ui/lib/pages/login_page.dart`
- ⚠️ Manter `import 'package:flutter/foundation.dart';` (usado por `kDebugMode`)
- Linha 346: `if ((kDebugMode || kIsWeb) && ...)` → `if (kDebugMode && ...)`
- Remover comentários sobre web (linhas 344-345)

### `packages/user/user_ui/lib/pages/settings_page.dart`
- ⚠️ Manter `import 'package:flutter/foundation.dart';` (usado por `kDebugMode`)
- Linha 122: `if (kDebugMode || kIsWeb) ...[` → `if (kDebugMode) ...[`
- Remover comentários sobre web (linhas 119-121)

### `packages/notebook/notebook_ui/lib/widgets/document_upload_widget.dart`
- Remover: `import 'package:flutter/foundation.dart' show kIsWeb;` (única referência nesse arquivo)
- Linha 52: `withData: kIsWeb` → `withData: false`

---

## Fase 4 — Arquivos de Configuração

### `apps/ems/app_v1/pubspec.yaml`
- Remover seção `web:` de `icons_launcher.platforms` (linhas 63-65)
- Remover seção `web:` de `names_launcher.platforms` (linhas 86-88)

### `servers/ems/server_v1/pubspec.yaml` e `servers/sms/server_v1/pubspec.yaml`
- Remover: `shelf_cors_headers: ^0.1.5`

### `servers/ems/server_v1/lib/config/env/env.dart` e `servers/sms/server_v1/lib/config/env/env.dart`
- Remover o campo `allowedOrigins` (linhas 44-48):
  ```dart
  @EnviedField(defaultValue: 'http://localhost:${_Env.serverPort}')
  static const String allowedOrigins = '${_Env.allowedOrigins}:${_Env.serverPort}';
  ```

### `servers/ems/server_v1/bin/server.dart` e `servers/sms/server_v1/bin/server.dart`
- Remover: `import 'package:shelf_cors_headers/shelf_cors_headers.dart';`
- Remover a variável `allowedOrigins` e o `.addMiddleware(corsHeaders(...))` do pipeline:
  ```dart
  // Pipeline resultante (sem CORS):
  final handler = Pipeline()
      .addMiddleware(rateLimit.middleware)
      .addMiddleware(logRequests())
      .addHandler(addRouters.call);
  ```

---

## Fase 5 — Regeneração de Código (após Fase 4)

Os arquivos `env.g.dart` de ambos os servidores estão desatualizados após remover `allowedOrigins` de `env.dart`. Executar:

```bash
cd servers/ems/server_v1
dart run build_runner build --delete-conflicting-outputs

cd servers/sms/server_v1
dart run build_runner build --delete-conflicting-outputs
```

---

## Verificação

Executar análise em todos os pacotes/apps modificados:

```bash
# Apps Flutter
cd apps/ems/app_v1 && dart analyze
cd apps/sms/app_v1 && dart analyze
cd apps/ems/app_design_draft && dart analyze

# Pacotes compartilhados
cd packages/auth/auth_ui && dart analyze
cd packages/user/user_ui && dart analyze
cd packages/notebook/notebook_ui && dart analyze

# Servidores
cd servers/ems/server_v1 && dart analyze
cd servers/sms/server_v1 && dart analyze
```

Resultado esperado: zero erros relacionados a `kIsWeb`, `corsHeaders` ou `allowedOrigins` em qualquer pacote.

---

## Arquivos Críticos a Modificar

| Arquivo | Mudança Principal |
|---------|-------------------|
| `apps/ems/app_v1/lib/main.dart` | Remove kIsWeb, simplifica Alice |
| `apps/ems/app_v1/lib/app_layout.dart` | Remove kIsWeb, simplifica navigatorKey |
| `apps/ems/app_v1/lib/config/di/injector.dart` | Remove kIsWeb da lógica de plataforma e interceptors |
| `apps/ems/app_v1/lib/main_{dev,staging,prod}.dart` | Remove kIsWeb, habilita writeToFile sempre |
| `packages/auth/auth_ui/lib/pages/login_page.dart` | Remove `\|\| kIsWeb` da condição |
| `packages/user/user_ui/lib/pages/settings_page.dart` | Remove `\|\| kIsWeb` da condição |
| `packages/notebook/notebook_ui/lib/widgets/document_upload_widget.dart` | Remove import kIsWeb, fixa withData: false |
| `apps/ems/app_v1/pubspec.yaml` | Remove seções web de icons/names_launcher |
| `servers/ems/server_v1/bin/server.dart` | Remove CORS middleware |
| `servers/sms/server_v1/bin/server.dart` | Remove CORS middleware |
| `servers/ems/server_v1/lib/config/env/env.dart` | Remove allowedOrigins |
| `servers/sms/server_v1/lib/config/env/env.dart` | Remove allowedOrigins |
| `servers/ems/server_v1/pubspec.yaml` | Remove shelf_cors_headers |
| `servers/sms/server_v1/pubspec.yaml` | Remove shelf_cors_headers |
