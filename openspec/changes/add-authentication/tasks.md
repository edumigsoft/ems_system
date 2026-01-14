# Tasks: Add Authentication

## 1. Core Shared - Domínio Base
- [x] 1.1 Criar `lib/src/domain/entity/user.dart` - Entity User
- [x] 1.2 Criar `lib/src/domain/enums/user_role.dart` - Enum UserRole
- [x] 1.3 Atualizar exports em `core_shared.dart`

## 2. Setup User - Estrutura de Pacotes
- [x] 2.1 Usar `create_feature_wizard.sh` para criar estrutura `packages/user/` com 4 variantes
- [x] 2.2 Configurar exports e dependências entre variantes

> **Nota:** Scripts individuais em `generators/` (ex: `01_generate_entities.sh`) podem ser usados para adicionar componentes extras posteriormente.

## 3. User Shared - Models
- [x] 3.1 Criar `UserDetails` implementando `BaseDetails`
- [x] 3.2 Criar `UserCreate` DTO
- [x] 3.3 Criar `UserUpdate` DTO
- [x] 3.4 Criar `UserDetailsModel` com serialização JSON
- [ ] 3.5 Criar validators com Zard para todos os models

## 4. User Server - Database e Rotas
- [x] 4.1 Criar tabela `users` com `@UseRowClass(UserDetails)`
- [x] 4.2 Criar `UserRepository` com CRUD básico
- [ ] 4.3 Criar `UserService` com lógica de negócio
- [x] 4.4 Criar `UserRoutes` com endpoints `/users/me`, `/users`, `/users/{id}`
- [x] 4.5 Criar `InitUserModuleToServer` para registro no injector

## 5. Setup Auth - Estrutura de Pacotes
- [x] 5.1 Usar `create_feature_wizard.sh` para criar estrutura `packages/auth/` com 4 variantes
- [x] 5.2 Adicionar dependência `flutter_secure_storage` em `auth_client`
- [x] 5.3 Configurar exports e dependências entre variantes

> **Nota:** Para entities adicionais (ex: `SessionToken`), use scripts individuais como `generators/01_generate_entities.sh`.

## 6. Auth Shared - Models
- [x] 6.1 Criar `AuthRequest` (email, password)
- [x] 6.2 Criar `AuthResponse` (accessToken, refreshToken, expiresIn)
- [x] 6.3 Criar `TokenPair` value object
- [x] 6.4 Criar `UserCredentials` para registro
- [x] 6.5 Criar `PasswordResetRequest` e `PasswordResetConfirm`
- [x] 6.6 Criar `ResourcePermission` enum (read, write, delete, manage)
- [x] 6.7 Criar `AuthContext` (userId, globalRole)
- [ ] 6.8 Criar validators com Zard para todos os models

## 7. Auth Server - Database
- [x] 7.1 Criar tabela `user_credentials` (userId FK, passwordHash, lastLoginAt)
- [x] 7.2 Criar tabela `refresh_tokens` (userId FK, token, expiresAt, revokedAt)
- [x] 7.3 Criar tabela `resource_members` (userId FK, resourceType, resourceId, permission)
- [x] 7.4 Criar `AuthRepository`
- [x] 7.5 Criar `ResourcePermissionRepository`

## 8. Auth Server - Services e Middlewares
- [x] 8.1 Criar `AuthService` (login, register, refresh, logout, resetPassword)
- [x] 8.2 Criar `ResourcePermissionService` (grant, revoke, check, list)
- [x] 8.3 Criar `AuthMiddleware` (verifyJWT, populateAuthContext)
- [x] 8.4 Criar `RoleMiddleware` (requireRole, requireAnyRole)
- [x] 8.5 Criar `ResourcePermissionMiddleware` (requireResourcePermission)

## 9. Auth Server - Routes
- [x] 9.1 Criar `AuthRoutes` com injeção de `SecurityService`
- [x] 9.2 Implementar rota `login()`
- [x] 9.3 Implementar rota `register()`
- [x] 9.4 Implementar rota `refresh()`
- [x] 9.5 Implementar rota `logout()`
- [x] 9.6 Implementar rota `forgotPassword()`
- [x] 9.7 Implementar rota `resetPassword()`
- [x] 9.8 Criar `InitAuthModuleToServer` para registro no injector

## 10. Core Server - Email Service
- [x] 10.1 Criar `email/email_config.dart` - Leitura de env vars
- [x] 10.2 Criar `email/email_service.dart` - Interface e implementação
- [x] 10.3 Criar `email/email_template.dart` - Templates (verificação, reset)
- [x] 10.4 Registrar `EmailService` no injector

## 11. Testes e Validação
- [x] 11.1 Testes Unitários `AuthService`


## 11. Auth Client - Serviços
- [x] 11.1 Criar `AuthService` interface
- [x] 11.2 Implementar `AuthServiceImpl` com Dio
- [x] 11.3 Criar `TokenStorage` com `FlutterSecureStorage`
- [x] 11.4 Implementar interceptor Dio para refresh automático

## 12. Auth UI - Telas
- [x] 12.1 Criar `LoginPage` com form validation
- [x] 12.2 Criar `RegisterPage`
- [x] 12.3 Criar `ForgotPasswordPage`
- [x] 12.4 Criar `ResetPasswordPage`
- [x] 12.5 Criar `AuthViewModel` base

## 13. User Client/UI (Opcional - Fase 2)
- [x] 13.1 Criar `UserClient` para chamadas HTTP
- [x] 13.2 Criar `UserProfilePage`
- [x] 13.3 Criar `UserProfileViewModel`

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
- [x] 16.1 README.md para cada variante (user + auth)
- [ ] 16.2 Exemplos de uso no README principal

