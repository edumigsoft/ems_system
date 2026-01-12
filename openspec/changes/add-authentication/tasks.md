# Tasks: Add Authentication

## 1. Setup - Estrutura de Pacotes
- [ ] 1.1 Usar `create_feature_wizard.sh` para criar estrutura `packages/auth/` com 4 variantes
- [ ] 1.2 Adicionar dependência `flutter_secure_storage` em `auth_client`
- [ ] 1.3 Configurar exports e dependências entre variantes

## 2. Auth Shared - Models
- [ ] 2.1 Criar `AuthRequest` (email, password)
- [ ] 2.2 Criar `AuthResponse` (accessToken, refreshToken, expiresIn)
- [ ] 2.3 Criar `TokenPair` value object
- [ ] 2.4 Criar `UserCredentials` para registro
- [ ] 2.5 Criar `PasswordResetRequest` e `PasswordResetConfirm`
- [ ] 2.6 Criar validators com Zard para todos os models

## 3. Auth Server - Routes
- [ ] 3.1 Criar `AuthRoutes` com injeção de `SecurityService`
- [ ] 3.2 Implementar rota `login()`
- [ ] 3.3 Implementar rota `register()`
- [ ] 3.4 Implementar rota `refresh()`
- [ ] 3.5 Implementar rota `logout()`
- [ ] 3.6 Implementar rota `forgotPassword()`
- [ ] 3.7 Implementar rota `resetPassword()`
- [ ] 3.8 Criar `InitAuthModuleToServer` para registro no injector

## 4. Auth Client - Serviços
- [ ] 4.1 Criar `AuthService` interface
- [ ] 4.2 Implementar `AuthServiceImpl` com Dio
- [ ] 4.3 Criar `TokenStorage` com `FlutterSecureStorage`
- [ ] 4.4 Implementar interceptor Dio para refresh automático

## 5. Auth UI - Telas
- [ ] 5.1 Criar `LoginPage` com form validation
- [ ] 5.2 Criar `RegisterPage` 
- [ ] 5.3 Criar `ForgotPasswordPage`
- [ ] 5.4 Criar `ResetPasswordPage`
- [ ] 5.5 Criar `AuthViewModel` base

## 6. Integração
- [ ] 6.1 Adicionar variáveis de ambiente:
  - `ACCESS_TOKEN_EXPIRES_MINUTES` (padrão: 15)
  - `REFRESH_TOKEN_EXPIRES_DAYS` (padrão: 7)
  - `EMAIL_SERVICE_HOST`, `EMAIL_SERVICE_PORT`, `EMAIL_SERVICE_API_KEY`
  - `MAX_LOGIN_ATTEMPTS_PER_ACCOUNT` (padrão: 5)
  - `MAX_LOGIN_ATTEMPTS_PER_IP` (padrão: 10)
  - `ACCOUNT_LOCKOUT_MINUTES` (padrão: 30)
- [ ] 6.2 Registrar `InitAuthModuleToServer` em `server_v1/lib/config/injector.dart`
- [ ] 6.3 Configurar GetIt com serviços de auth no client

## 7. Testes
- [ ] 7.1 Testes unitários para validators
- [ ] 7.2 Testes unitários para routes
- [ ] 7.3 Testes de integração para fluxo completo

## 8. Documentação
- [ ] 8.1 README.md para cada variante
- [ ] 8.2 Exemplos de uso no README principal
