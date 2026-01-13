# Capability: User Management

Sistema de gestão de usuários para o EMS System.

## ADDED Requirements

### Requirement: User Profile

O sistema SHALL manter perfis de usuários com informações de identidade, separados de credenciais de autenticação.

#### Scenario: Criação de perfil de usuário
- **WHEN** um novo usuário é registrado via `POST /auth/register`
- **THEN** o sistema cria um registro na tabela `users`
- **AND** os campos obrigatórios (name, email, username) são validados
- **AND** o campo `role` padrão é `user`
- **AND** o campo `emailVerified` padrão é `false`

#### Scenario: Visualização de perfil próprio
- **WHEN** um usuário autenticado acessa `GET /users/me`
- **THEN** o sistema retorna os dados do perfil do usuário (exceto passwordHash)

#### Scenario: Atualização de perfil próprio
- **WHEN** um usuário autenticado atualiza seu perfil via `PUT /users/me`
- **THEN** o sistema atualiza os campos permitidos (name, avatarUrl, phone)
- **AND** campos protegidos (email, role) não são alterados

---

### Requirement: User Administration

O sistema SHALL permitir que administradores gerenciem usuários do sistema.

#### Scenario: Listagem de usuários (admin)
- **WHEN** um administrador acessa `GET /users`
- **THEN** o sistema retorna lista paginada de usuários
- **AND** suporta filtros por role, status e busca por nome/email

#### Scenario: Visualização de usuário específico (admin)
- **WHEN** um administrador acessa `GET /users/{id}`
- **THEN** o sistema retorna os dados completos do usuário

#### Scenario: Atualização de usuário (admin)
- **WHEN** um administrador atualiza um usuário via `PUT /users/{id}`
- **THEN** o sistema permite alteração de campos protegidos (role, emailVerified, isActive)

#### Scenario: Desativação de usuário (admin)
- **WHEN** um administrador desativa um usuário via `DELETE /users/{id}`
- **THEN** o sistema marca `isActive = false` (soft delete)
- **AND** invalida todos os tokens do usuário

---

### Requirement: Email Verification

O sistema SHALL suportar verificação de email para novos usuários quando email service estiver configurado.

#### Scenario: Envio de email de verificação
- **WHEN** um novo usuário é registrado
- **AND** email service está configurado (`EMAIL_SERVICE_*` env vars)
- **THEN** o sistema envia email com link de verificação
- **AND** o link contém token único que expira em 24 horas

#### Scenario: Verificação de email bem-sucedida
- **WHEN** um usuário acessa o link de verificação via `POST /users/verify-email`
- **AND** o token é válido e não expirado
- **THEN** o sistema marca `emailVerified = true`
- **AND** retorna status 200 OK

#### Scenario: Verificação sem email service
- **WHEN** um novo usuário é registrado
- **AND** email service NÃO está configurado
- **THEN** o sistema marca `emailVerified = true` automaticamente
- **AND** loga warning indicando verificação bypass

---

### Requirement: User Data Integrity

O sistema SHALL garantir integridade dos dados de usuário.

#### Scenario: Email único
- **WHEN** um registro ou atualização tenta usar email já existente
- **THEN** o sistema retorna erro 409 Conflict

#### Scenario: Username único
- **WHEN** um registro tenta usar username já existente
- **THEN** o sistema retorna erro 409 Conflict

#### Scenario: Validação de formato de email
- **WHEN** um email inválido é fornecido
- **THEN** o sistema retorna erro 400 Bad Request com detalhes da validação
