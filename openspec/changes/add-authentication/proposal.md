# Change: Adicionar Sistema de Autenticação

## Why

O EMS System precisa de um sistema completo de autenticação para gerenciar acesso de usuários. Atualmente a infraestrutura de segurança (`SecurityService`, `JWTSecurityService`) existe em `core_server`, mas não há um módulo Auth dedicado com login, registro, refresh token e logout.

## What Changes

### Novo Pacote: `packages/auth/`
Seguindo o Multi-Variant Package Pattern (ADR-0005):

- **auth_shared**: Models puros (AuthRequest, AuthResponse, TokenPair, UserCredentials)
- **auth_client**: Serviço de autenticação para apps Flutter
- **auth_server**: Routes de autenticação para Shelf, tratamento de rotas (endpoints)
- **auth_ui**: Telas de Login, Registro, Forgot Password

### Endpoints de API
- `POST /auth/login` - Autenticação com email/senha
- `POST /auth/register` - Registro de novo usuário
- `POST /auth/refresh` - Renovação de access token
- `POST /auth/logout` - Invalidação de tokens
- `POST /auth/forgot-password` - Solicitação de reset de senha
- `POST /auth/reset-password` - Reset de senha com token

### Segurança
- Access Token (JWT) com expiração configurável via `ACCESS_TOKEN_EXPIRES_MINUTES` (padrão: 15 min)
- Refresh Token com expiração configurável via `REFRESH_TOKEN_EXPIRES_DAYS` (padrão: 7 dias)
- Password hashing com bcrypt
- Rate limiting em endpoints sensíveis (5 tentativas por conta, 10 por IP)
- Email service configurável via `EMAIL_SERVICE_*` env vars

### Geração de Código
Utilizar scripts existentes para scaffold inicial:
- `scripts/generators/new_feature/create_feature_wizard.sh` para geração completa
- `scripts/generators/new_feature/scaffold_feature.sh` para estrutura base

## Impact

- **Affected specs**: nova capability `auth`
- **Affected code**:
  - `packages/auth/` (novo)
  - `packages/core/core_server/` (utiliza SecurityService existente)
  - `servers/server_v1/` (registra a classe `AuthServerModule` via `InitAuthModuleToServer`)
- **Dependências existentes aproveitadas**: `dart_jsonwebtoken`, `bcrypt`, `zard`, `flutter_secure_storage`
