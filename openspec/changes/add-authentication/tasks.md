# Tasks: Add Authentication

## 1. Core Shared - Domínio Base
- [ ] 1.1 Criar `lib/src/domain/entity/user.dart` - Entity User
- [ ] 1.2 Criar `lib/src/domain/enums/user_role.dart` - Enum UserRole
- [ ] 1.3 Atualizar exports em `core_shared.dart`

## 2. Setup User - Estrutura de Pacotes
- [ ] 2.1 Usar `create_feature_wizard.sh` para criar estrutura `packages/user/` com 4 variantes
- [ ] 2.2 Configurar exports e dependências entre variantes

> **Nota:** Scripts individuais em `generators/` (ex: `01_generate_entities.sh`) podem ser usados para adicionar componentes extras posteriormente.

## 3. User Shared - Models
- [ ] 3.1 Criar `UserDetails` implementando `BaseDetails`
- [ ] 3.2 Criar `UserCreate` DTO
- [ ] 3.3 Criar `UserUpdate` DTO
- [ ] 3.4 Criar `UserDetailsModel` com serialização JSON
- [ ] 3.5 Criar validators com Zard para todos os models

## 4. User Server - Database e Rotas
- [ ] 4.1 Criar tabela `users` com `@UseRowClass(UserDetails)`
- [ ] 4.2 Criar `UserRepository` com CRUD básico
- [ ] 4.3 Criar `UserService` com lógica de negócio
- [ ] 4.4 Criar `UserRoutes` com endpoints `/users/me`, `/users`, `/users/{id}`
- [ ] 4.5 Criar `InitUserModuleToServer` para registro no injector

## 5. Setup Auth - Estrutura de Pacotes
- [ ] 5.1 Usar `create_feature_wizard.sh` para criar estrutura `packages/auth/` com 4 variantes
- [ ] 5.2 Adicionar dependência `flutter_secure_storage` em `auth_client`
- [ ] 5.3 Configurar exports e dependências entre variantes

> **Nota:** Para entities adicionais (ex: `SessionToken`), use scripts individuais como `generators/01_generate_entities.sh`.

## 6. Auth Shared - Models
- [ ] 6.1 Criar `AuthRequest` (email, password)
- [ ] 6.2 Criar `AuthResponse` (accessToken, refreshToken, expiresIn)
- [ ] 6.3 Criar `TokenPair` value object
- [ ] 6.4 Criar `UserCredentials` para registro
- [ ] 6.5 Criar `PasswordResetRequest` e `PasswordResetConfirm`
- [ ] 6.6 Criar `ResourcePermission` enum (read, write, delete, manage)
- [ ] 6.7 Criar `AuthContext` (userId, globalRole)
- [ ] 6.8 Criar validators com Zard para todos os models

## 7. Auth Server - Database
- [ ] 7.1 Criar tabela `user_credentials` (userId FK, passwordHash, lastLoginAt)
- [ ] 7.2 Criar tabela `refresh_tokens` (userId FK, token, expiresAt, revokedAt)
- [ ] 7.3 Criar tabela `resource_members` (userId FK, resourceType, resourceId, permission)
- [ ] 7.4 Criar `AuthRepository`
- [ ] 7.5 Criar `ResourcePermissionRepository`

## 8. Auth Server - Services e Middlewares
- [ ] 8.1 Criar `AuthService` (login, register, refresh, logout, resetPassword)
- [ ] 8.2 Criar `ResourcePermissionService` (grant, revoke, check, list)
- [ ] 8.3 Criar `AuthMiddleware` (verifyJWT, populateAuthContext)
- [ ] 8.4 Criar `RoleMiddleware` (requireRole, requireAnyRole)
- [ ] 8.5 Criar `ResourcePermissionMiddleware` (requireResourcePermission)

## 9. Auth Server - Routes
- [ ] 9.1 Criar `AuthRoutes` com injeção de `SecurityService`
- [ ] 9.2 Implementar rota `login()`
- [ ] 9.3 Implementar rota `register()`
- [ ] 9.4 Implementar rota `refresh()`
- [ ] 9.5 Implementar rota `logout()`
- [ ] 9.6 Implementar rota `forgotPassword()`
- [ ] 9.7 Implementar rota `resetPassword()`
- [ ] 9.8 Criar `InitAuthModuleToServer` para registro no injector

## 10. Core Server - Email Service
- [ ] 10.1 Criar `email/email_config.dart` - Leitura de env vars
- [ ] 10.2 Criar `email/email_service.dart` - Interface e implementação
- [ ] 10.3 Criar `email/email_template.dart` - Templates (verificação, reset)
- [ ] 10.4 Registrar `EmailService` no injector

## 11. Auth Client - Serviços
- [ ] 11.1 Criar `AuthService` interface
- [ ] 11.2 Implementar `AuthServiceImpl` com Dio
- [ ] 11.3 Criar `TokenStorage` com `FlutterSecureStorage`
- [ ] 11.4 Implementar interceptor Dio para refresh automático

## 12. Auth UI - Telas
- [ ] 12.1 Criar `LoginPage` com form validation
- [ ] 12.2 Criar `RegisterPage`
- [ ] 12.3 Criar `ForgotPasswordPage`
- [ ] 12.4 Criar `ResetPasswordPage`
- [ ] 12.5 Criar `AuthViewModel` base

## 13. User Client/UI (Opcional - Fase 2)
- [ ] 13.1 Criar `UserClient` para chamadas HTTP
- [ ] 13.2 Criar `UserProfilePage`
- [ ] 13.3 Criar `UserProfileViewModel`

## 14. Integração
- [ ] 14.1 Adicionar variáveis de ambiente em `.env.example`:
  - `ACCESS_TOKEN_EXPIRES_MINUTES` (padrão: 15)
  - `REFRESH_TOKEN_EXPIRES_DAYS` (padrão: 7)
  - `EMAIL_SERVICE_HOST`, `EMAIL_SERVICE_PORT`, `EMAIL_SERVICE_API_KEY`
  - `MAX_LOGIN_ATTEMPTS_PER_ACCOUNT` (padrão: 5)
  - `MAX_LOGIN_ATTEMPTS_PER_IP` (padrão: 10)
  - `ACCOUNT_LOCKOUT_MINUTES` (padrão: 30)
  - `IP_BLOCK_MINUTES` (padrão: 15)
- [ ] 14.2 Registrar `InitUserModuleToServer` em `server_v1`
- [ ] 14.3 Registrar `InitAuthModuleToServer` em `server_v1`
- [ ] 14.4 Configurar GetIt com serviços de auth/user no client

## 15. Testes
- [ ] 15.1 Testes unitários para validators (user + auth)
- [ ] 15.2 Testes unitários para services
- [ ] 15.3 Testes unitários para routes
- [ ] 15.4 Testes de integração para fluxo completo de auth

## 16. Documentação
- [ ] 16.1 README.md para cada variante (user + auth)
- [ ] 16.2 Exemplos de uso no README principal

