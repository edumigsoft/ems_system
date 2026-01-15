# Design: Sistema de Autenticação

## Context

O EMS System é um monorepo Flutter/Dart que precisa de autenticação robusta para proteger recursos. A infraestrutura base já existe em `core_server` (`SecurityService`, `JWTSecurityService`), mas não há um módulo dedicado para fluxos de autenticação.

**Stakeholders**: Todos os módulos (Users, Aura, Projects, Finance) dependem de autenticação.

**Constraints**:
- Seguir ADR-0005 (4 variantes)
- Seguir ADR-0001 (Result Pattern)
- Zero Flutter em `*_shared`
- Compatível com multi-tenancy futuro
- Usar padrão Routes existente (não Handlers)
- Configurações via variáveis de ambiente
- **Dependência unidirecional**: `auth_server → user_server` (SEM circularidade)

## Goals / Non-Goals

### Goals
- Fluxo completo de login/registro/logout
- Renovação automática de tokens
- Persistência segura de tokens no client via `FlutterSecureStorage`
- Rate limiting em endpoints sensíveis
- Suporte a reset de senha
- Configurações flexíveis via env (tempos de expiração, limites)

### Non-Goals
- OAuth/Social login (será proposta separada)
- 2FA/MFA (será proposta separada)
- Gestão de sessões múltiplas
- SSO (Single Sign-On)
- Email como capability separada (usará `core_server`)

## Decisions

### 1. Token Strategy: Access + Refresh Token

**Decisão**: Usar par de tokens (access curto, refresh longo) com tempos configuráveis via env.

**Configuração**:
```env
ACCESS_TOKEN_EXPIRES_MINUTES=15
REFRESH_TOKEN_EXPIRES_DAYS=7
```

**Rationale**:
- Access Token curto: Minimiza janela de exposição se comprometido
- Refresh Token longo: UX suave sem re-login frequente
- Configurável: Permite ajuste por ambiente (dev/prod)

**Alternativas consideradas**:
- Token único longo: Rejeitado por risco de segurança
- Session-based: Rejeitado por complexidade de estado no servidor

### 2. Password Hashing: bcrypt

**Decisão**: Usar bcrypt com cost factor 12.

**Rationale**:
- Já é dependência do projeto (`BCryptService`)
- Resistente a ataques de força bruta
- Amplamente auditado

### 3. Arquitetura de Routes

**Decisão**: Usar padrão Routes existente com `InitAuthModuleToServer`.

```dart
class AuthRoutes {
  final SecurityService security;
  final UserRepository users;
  
  Router get router => Router()
    ..post('/login', _login)
    ..post('/register', _register)
    ..post('/refresh', _refresh)
    ..post('/logout', _logout);
}

void InitAuthModuleToServer({
  required DependencyInjector di,
  required String backendBaseApi,
  bool security = true,
}) {
  di.registerLazySingleton<AuthRoutes>(() => AuthRoutes(...));
  addRoutes(di, di.get<AuthRoutes>(), security: security);
}
```

**Rationale**:
- Segue padrão existente do projeto (ver `injector.dart`)
- Consistente com outros módulos (Health, OpenApi)
- Facilita registro via `addRoutes()`

### 4. Separação User vs Auth

**Decisão**: Criar dois pacotes distintos: `packages/user/` e `packages/auth/`.

```
core_shared (Entity User, UserRole)
     │
     ├─────────┬─────────┤
     ↓         ↓         ↓
user_shared auth_shared other_shared
     │         │
     ↓         ↓
user_server ← auth_server (FK)
```

**Rationale**:
- **Separação de responsabilidades**: Perfil ≠ Credenciais
- **Reuso**: `User` referenciado por todos os módulos
- **Segurança**: `passwordHash` isolado em tabela separada
- **Não-circularidade**: `user_server` NÃO importa `auth_server`

**Alternativas rejeitadas**:
- Tudo em `auth/`: Mistura responsabilidades, aumenta acoplamento

### 5. Token Storage no Client

**Decisão**: Usar `FlutterSecureStorage` para persistência segura.

```dart
class TokenStorageImpl implements TokenStorage {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  Future<void> saveTokens(TokenPair tokens) async {
    await _storage.write(key: 'access_token', value: tokens.accessToken);
    await _storage.write(key: 'refresh_token', value: tokens.refreshToken);
  }
}
```

**Rationale**:
- Criptografia nativa em iOS (Keychain) e Android (Keystore)
- Dependência madura e auditada
- Recomendação do usuário

### 6. Email Service em core_server

**Decisão**: Implementar como utilitário em `core_server/email/`, não capability separada.

```
core_server/lib/src/
├── email/
│   ├── email_config.dart       # Leitura de env vars
│   ├── email_service.dart       # Interface + implementação
│   └── email_template.dart      # Templates (verificação, reset)
```

**Configuração via env**:
```env
EMAIL_SERVICE_HOST=smtp.example.com
EMAIL_SERVICE_PORT=587
EMAIL_SERVICE_API_KEY=your-api-key
EMAIL_SERVICE_FROM=noreply@example.com
```

**Rationale**:
- Email é infraestrutura transversal, não domínio de negócio
- Não requer UI própria nem client separado
- Flexibilidade para providers (SendGrid, Mailgun, SMTP)

### 7. Refresh Token Blacklist

**Decisão**: NÃO implementar blacklist inicial. Usar refresh token rotation.

**Análise Custo/Benefício**:
| Aspecto | Blacklist | Rotation Only |
|---------|-----------|---------------|
| Complexidade | Alta (storage, lookup, cleanup) | Baixa |
| Performance | Overhead em cada request | Zero overhead |
| Segurança | Revogação imediata | Revogação no próximo uso |
| Storage | Cresce com tokens ativos | Nenhum extra |

**Rationale**:
- Rotation já oferece boa segurança: token antigo invalida ao usar
- Blacklist adiciona complexidade de infraestrutura (Redis/DB)
- Para v1, rotation é suficiente
- Pode ser adicionado posteriormente se necessário

### 8. Rate Limiting e Lockout

**Decisão**: Adotar melhor prática OWASP para rate limiting.

**Configuração via env**:
```env
MAX_LOGIN_ATTEMPTS_PER_ACCOUNT=5
MAX_LOGIN_ATTEMPTS_PER_IP=10
ACCOUNT_LOCKOUT_MINUTES=30
IP_BLOCK_MINUTES=15
```

**Implementação**:
- **Por conta**: 5 tentativas falhas em 5 min → lockout 30 min
- **Por IP**: 10 tentativas em 1 min → bloqueio 15 min
- **Notificação**: Email ao dono da conta em lockout

**Rationale**:
- Valores baseados em OWASP Cheat Sheet
- Configurável para ajuste fino
- Balanceia segurança vs UX

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Refresh token comprometido | Rotation + invalidação em logout |
| Rate limiting bypass (IPs distribuídos) | Limite por conta como segunda camada |
| Email service não configurado | Graceful degradation: log warning, feature desabilitada |

## Migration Plan

1. **Fase 1**: Adicionar `User` entity e `UserRole` enum em `core_shared`
2. **Fase 2**: Usar `create_feature_wizard.sh` para scaffold `packages/user/`
3. **Fase 3**: Implementar tabela `users`, repository e routes de user
4. **Fase 4**: Usar `create_feature_wizard.sh` para scaffold `packages/auth/`
5. **Fase 5**: Implementar tabelas de auth, services e middlewares
6. **Fase 6**: Adicionar `EmailService` em `core_server`
7. **Fase 7**: Registrar módulos em `server_v1`
8. **Fase 8**: Integrar em app cliente
9. **Rollback**: Comentar registro no injector, rotas são independentes

> [!TIP]
> **Scripts de Geração Disponíveis:**
> - `create_feature_wizard.sh` / `scaffold_feature.sh` - Para criar feature completa (4 pacotes)
> - `generators/01_generate_entities.sh` ... `16_generate_ui_widgets.sh` - Para criar componentes individuais
> 
> Use os scripts individuais quando precisar adicionar entities extras a uma feature existente ou regenerar um componente específico. Consulte `generators/README.md` para detalhes.

## Open Questions

- [x] ~~Qual email service usar para reset de senha?~~ → Configurável via env, em `core_server`
- [x] ~~Implementar refresh token blacklist?~~ → Não inicialmente, usar rotation
- [x] ~~Limite de tentativas de login?~~ → 5 por conta, 10 por IP (OWASP)
- [x] ~~Separar User de Auth?~~ → Sim, dois pacotes distintos
- [x] ~~Email como capability?~~ → Não, utilitário em core_server
