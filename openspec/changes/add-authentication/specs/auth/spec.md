# Capability: Authentication

Sistema de autenticação para o EMS System.

## ADDED Requirements

### Requirement: User Login

O sistema SHALL permitir que usuários façam login com email e senha, retornando tokens JWT para autenticação subsequente. Os tempos de expiração MUST ser configuráveis via variáveis de ambiente.

#### Scenario: Login com credenciais válidas
- **WHEN** um usuário fornece email e senha válidos via `POST /auth/login`
- **THEN** o sistema retorna um access token JWT e um refresh token
- **AND** o access token expira conforme `ACCESS_TOKEN_EXPIRES_MINUTES` (padrão: 15 min)
- **AND** o refresh token expira conforme `REFRESH_TOKEN_EXPIRES_DAYS` (padrão: 7 dias)

#### Scenario: Login com credenciais inválidas
- **WHEN** um usuário fornece credenciais inválidas
- **THEN** o sistema retorna erro 401 Unauthorized
- **AND** a mensagem não revela se o email existe ou não

#### Scenario: Login com email não verificado
- **WHEN** um usuário tenta login com email não verificado
- **THEN** o sistema retorna erro 403 Forbidden
- **AND** sugere verificar o email

---

### Requirement: User Registration

O sistema SHALL permitir o registro de novos usuários com validação de dados e envio de email de verificação.

#### Scenario: Registro com dados válidos
- **WHEN** um usuário envia dados de registro válidos via `POST /auth/register`
- **THEN** o sistema cria uma nova conta
- **AND** envia email de verificação (se email service configurado)
- **AND** retorna status 201 Created

#### Scenario: Registro com email duplicado
- **WHEN** um usuário tenta registrar com email já existente
- **THEN** o sistema retorna erro 409 Conflict

#### Scenario: Registro com dados inválidos
- **WHEN** um usuário envia dados de registro inválidos
- **THEN** o sistema retorna erro 400 Bad Request
- **AND** lista os campos com erros de validação

---

### Requirement: Token Refresh

O sistema SHALL permitir renovação de access tokens usando refresh token, implementando rotation para segurança onde o token anterior é invalidado automaticamente.

#### Scenario: Refresh com token válido
- **WHEN** um cliente envia refresh token válido via `POST /auth/refresh`
- **THEN** o sistema retorna novo access token
- **AND** retorna novo refresh token (rotation)
- **AND** invalida o refresh token anterior automaticamente

#### Scenario: Refresh com token expirado
- **WHEN** um cliente envia refresh token expirado
- **THEN** o sistema retorna erro 401 Unauthorized
- **AND** o cliente deve fazer novo login

#### Scenario: Refresh com token já usado (rotation violation)
- **WHEN** um cliente envia refresh token já utilizado em rotation anterior
- **THEN** o sistema retorna erro 401 Unauthorized
- **AND** invalida todos os tokens da sessão (indicativo de replay attack)

---

### Requirement: User Logout

O sistema SHALL permitir que usuários façam logout, invalidando seus tokens de refresh.

#### Scenario: Logout bem-sucedido
- **WHEN** um usuário autenticado envia `POST /auth/logout`
- **THEN** o sistema invalida o refresh token atual
- **AND** retorna status 200 OK

---

### Requirement: Password Reset

O sistema SHALL permitir reset de senha via email com token temporário de uso único. O email service MUST ser configurável via variáveis de ambiente.

#### Scenario: Solicitação de reset de senha
- **WHEN** um usuário solicita reset via `POST /auth/forgot-password` com email válido
- **AND** email service está configurado (`EMAIL_SERVICE_*` env vars)
- **THEN** o sistema envia email com link de reset
- **AND** o link expira em 1 hora
- **AND** retorna status 200 OK (mesmo se email não existir, para evitar enumeração)

#### Scenario: Solicitação sem email service configurado
- **WHEN** um usuário solicita reset de senha
- **AND** email service não está configurado
- **THEN** o sistema retorna erro 503 Service Unavailable
- **AND** loga warning indicando configuração ausente

#### Scenario: Reset de senha com token válido
- **WHEN** um usuário envia nova senha via `POST /auth/reset-password` com token válido
- **THEN** o sistema atualiza a senha
- **AND** invalida todos os refresh tokens do usuário
- **AND** retorna status 200 OK

#### Scenario: Reset de senha com token inválido
- **WHEN** um usuário tenta reset com token expirado ou inválido
- **THEN** o sistema retorna erro 400 Bad Request

---

### Requirement: Rate Limiting

O sistema SHALL implementar rate limiting configurável via env para prevenir ataques de força bruta em endpoints de autenticação.

#### Scenario: Rate limiting por IP
- **WHEN** mais de `MAX_LOGIN_ATTEMPTS_PER_IP` (padrão: 10) tentativas de login de um mesmo IP em 1 minuto
- **THEN** o sistema bloqueia novas tentativas daquele IP por `IP_BLOCK_MINUTES` (padrão: 15 min)
- **AND** retorna erro 429 Too Many Requests

#### Scenario: Rate limiting por conta
- **WHEN** mais de `MAX_LOGIN_ATTEMPTS_PER_ACCOUNT` (padrão: 5) tentativas falhas para uma mesma conta em 5 minutos
- **THEN** o sistema bloqueia a conta temporariamente por `ACCOUNT_LOCKOUT_MINUTES` (padrão: 30 min)
- **AND** notifica o dono da conta por email (se email service configurado)

---

### Requirement: Secure Token Storage (Client)

O cliente SHALL armazenar tokens de forma segura usando `FlutterSecureStorage` para persistência criptografada.

#### Scenario: Persistência de tokens
- **WHEN** o cliente recebe tokens após login
- **THEN** os tokens são armazenados via `FlutterSecureStorage` (Keychain/Keystore)

#### Scenario: Limpeza de tokens no logout
- **WHEN** o usuário faz logout
- **THEN** todos os tokens são removidos do storage local via `FlutterSecureStorage.deleteAll()`

#### Scenario: Auto-refresh de tokens
- **WHEN** o access token está prestes a expirar (< 1 minuto)
- **THEN** o cliente automaticamente solicita novo token usando refresh token
- **AND** atualiza o storage com novos tokens

---

### Requirement: Environment Configuration

O sistema SHALL suportar configuração de autenticação via variáveis de ambiente.

#### Scenario: Configuração de tempos de expiração
- **WHEN** o servidor inicia com variáveis `ACCESS_TOKEN_EXPIRES_MINUTES` e `REFRESH_TOKEN_EXPIRES_DAYS`
- **THEN** os tokens são gerados com os tempos especificados

#### Scenario: Configuração de rate limiting
- **WHEN** o servidor inicia com variáveis `MAX_LOGIN_ATTEMPTS_*` e `*_LOCKOUT_MINUTES`
- **THEN** os limites de rate limiting usam os valores especificados

#### Scenario: Valores padrão
- **WHEN** variáveis de ambiente não são definidas
- **THEN** o sistema usa valores padrão seguros (15 min access, 7 dias refresh, 5/10 tentativas, 30/15 min lockout)

---

### Requirement: JWT Authentication Middleware

O sistema SHALL fornecer middleware reutilizável para validar tokens JWT e popular o contexto de autenticação.

#### Scenario: Request com token válido
- **WHEN** uma requisição possui header `Authorization: Bearer <token>` com token JWT válido
- **THEN** o middleware extrai as claims e popula `AuthContext` no request
- **AND** a requisição prossegue para o handler

#### Scenario: Request sem token
- **WHEN** uma requisição protegida não possui header Authorization
- **THEN** o middleware retorna erro 401 Unauthorized

#### Scenario: Request com token expirado
- **WHEN** uma requisição possui token JWT expirado
- **THEN** o middleware retorna erro 401 Unauthorized
- **AND** a mensagem indica que o token expirou

---

### Requirement: Role-Based Access Control

O sistema SHALL suportar controle de acesso baseado em roles globais do usuário.

#### Scenario: Verificação de role única
- **WHEN** um endpoint requer role específica (ex: `admin`)
- **AND** o usuário autenticado possui a role exigida
- **THEN** a requisição prossegue normalmente

#### Scenario: Verificação de role única - acesso negado
- **WHEN** um endpoint requer role `admin`
- **AND** o usuário autenticado possui role `user`
- **THEN** o sistema retorna erro 403 Forbidden

#### Scenario: Verificação de múltiplas roles
- **WHEN** um endpoint aceita qualquer role de um conjunto (ex: `admin` OU `moderator`)
- **AND** o usuário possui uma das roles aceitas
- **THEN** a requisição prossegue normalmente

---

### Requirement: Generic Resource Permission System

O sistema SHALL fornecer um modelo genérico de permissões por recurso, reutilizável por qualquer módulo (projects, documents, teams, etc.).

#### Scenario: Hierarquia de permissões
- **WHEN** um usuário possui permissão `manage` em um recurso
- **THEN** as permissões `read`, `write` e `delete` estão implicitamente concedidas
- **AND** a hierarquia é: `read < write < delete < manage`

#### Scenario: Verificar permissão em recurso
- **WHEN** o sistema verifica se usuário tem permissão `write` em `project/abc123`
- **AND** o usuário possui permissão `manage` para este recurso
- **THEN** a verificação retorna sucesso (manage inclui write)

#### Scenario: Conceder permissão a usuário
- **WHEN** um usuário com permissão `manage` concede `read` a outro usuário
- **THEN** o sistema cria registro em `resource_members`
- **AND** o novo usuário pode acessar o recurso

#### Scenario: Revogar permissão
- **WHEN** um usuário com permissão `manage` revoga acesso de outro usuário
- **THEN** o registro é removido de `resource_members`
- **AND** o usuário revogado não pode mais acessar o recurso

#### Scenario: Listar permissões de um recurso
- **WHEN** o sistema lista membros de `project/abc123`
- **THEN** retorna todos os usuários com suas respectivas permissões

---

### Requirement: Authentication Data Persistence

O sistema SHALL manter tabelas de suporte para autenticação e autorização.

#### Scenario: Tabela user_credentials
- **WHEN** um usuário é registrado
- **THEN** suas credenciais são armazenadas em tabela separada de `users`
- **AND** contém: `userId` (FK), `passwordHash`, `lastLoginAt`

#### Scenario: Tabela refresh_tokens
- **WHEN** um refresh token é emitido
- **THEN** é registrado com: `userId` (FK), `token`, `expiresAt`, `revokedAt`
- **AND** permite invalidação e auditoria

#### Scenario: Tabela resource_members
- **WHEN** permissão é concedida a um usuário em um recurso
- **THEN** é registrado com: `userId` (FK), `resourceType`, `resourceId`, `permission`
- **AND** suporta qualquer tipo de recurso (project, document, team, etc.)

