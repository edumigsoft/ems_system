# EMS System (EduMigSoft System)

[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/edumigsoft/ems_system/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.md)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2.svg?logo=dart&logoColor=white)](https://dart.dev)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

Sistema de Gestão de features para o EduMigSoft.

## 📊 Status do Projeto

| Módulo | Status | Versão | Descrição |
|--------|--------|--------|-----------|
| Core Shared | 🟢 Ativo | 0.1.0 | Funcionalidades compartilhadas |
| Core Server | 🟢 Ativo | 0.1.0 | Núcleo do servidor |
| Core Client | 🟢 Ativo | 0.1.0 | Núcleo do cliente |
| Auth Module | 🟢 Ativo | 0.1.0 | Autenticação e Segurança |
| User Module | 🟢 Ativo | 0.1.0 | Gestão de Usuários |
| UI Components | 🟡 Em desenvolvimento | 0.1.0 | Componentes de interface |
| Design System | 🟡 Em desenvolvimento | 0.1.0 | Sistema de design |
| App Flutter | 🟡 Em desenvolvimento | 0.1.0 | Aplicativo mobile |
| Server Dart/Shelf | 🟡 Em desenvolvimento | 0.1.0 | Backend API |

**Legenda:** 🟢 Ativo | 🟡 Em desenvolvimento | 🔴 Planejado

## ✨ Features

Features da ideia inicial:
- App em Flutter
- Server em Dart/Shelf
- Gestão de Users
- Gestão de Aura (Tarefas)
- Gestão de Projects (com tarefas e financeiro do projeto, não utilizará a features de financeiro)
- Gestão de Finance (com receita e despesas)

## 🔐 Autenticação e Usuários

O sistema possui um fluxo completo de autenticação e gestão de usuários, dividido em microsserviços e pacotes modularizados.

### Visão Geral

- **Auth Server/Client**: Responsável por login, registro, refresh token (com rotação), e recuperação de senha. Utiliza JWT (JSON Web Tokens).
- **User Server/Client**: Responsável pela gestão de dados do usuário (perfil, atualizações).

### Integração no Cliente (Flutter)

O acesso às funcionalidades é feito através do `AuthService` e `UserClient` configurados via injeção de dependência via GetIt.

#### Exemplo: Autenticação

```dart
// 1. Login
final result = await authService.login(LoginRequest(
  email: 'user@example.com',
  password: 'password123',
));

if (result case Success(value: final user)) {
  print('Bem-vindo, ${user.name}!');
} else if (result case Failure(error: final e)) {
  print('Erro ao logar: $e');
}

// 2. Verificar Sessão (Automático na inicialização)
// O AuthService tenta usar o refresh token armazenado para restaurar a sessão
final isAuthenticated = await authService.isAuthenticated();

// 3. Logout
await authService.logout();
```

#### Exemplo: Perfil do Usuário

```dart
// Buscar dados atualizados do usuário logado
final result = await userClient.getMe();

if (result case Success(value: final userDetails)) {
  print('Email: ${userDetails.email}');
  print('Role: ${userDetails.role}');
}
```

### API Endpoints

Abaixo estão os principais endpoints disponíveis na API:

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| `POST` | `/auth/login` | Realiza login e retorna tokens | ❌ Não |
| `POST` | `/auth/register` | Cria uma nova conta de usuário | ❌ Não |
| `POST` | `/auth/refresh` | Renova o Access Token usando Refresh Token | ❌ Não |
| `POST` | `/auth/forgot-password` | Solicita envio de email de reset | ❌ Não |
| `POST` | `/auth/reset-password` | Redefine senha com token de email | ❌ Não |
| `POST` | `/auth/change-password` | Altera senha (exige senha atual) | ✅ Sim |
| `GET`  | `/users/me` | Retorna perfil do usuário logado | ✅ Sim |
| `PUT`  | `/users/me` | Atualiza dados do usuário logado | ✅ Sim |
| `GET`  | `/users` | Lista usuários (Admin apenas) | ✅ Admin |
| `GET`  | `/users/{id}` | Busca usuário por ID (Admin apenas) | ✅ Admin |

### Permissões e Roles

O sistema implementa **RBAC (Role-Based Access Control)**.
- **Roles**: `admin`, `user` (padrão), `guest`.
- **Proteção**: Rotas protegidas exigem um header `Authorization: Bearer <token>`.
- O `AuthMiddleware` no servidor valida o token e popula o `AuthContext` para uso nos handlers.

## Estrutura do Projeto

```bash
ems_system/
├── apps/
│   └── app/
│       ├── config/
│       │    ├── di/ #dependence injection
│       │    ├── dio/ # config Dio
│       │    └── env/ # config environment  
│       │
│       ├── data/
│       │    ├── local/
│       │    └── services/
│       │
│       └── ui/
│           ├── pages/
│           ├── view_models/
│           └── app_layout.dart
│
├── servers/
│   └── server/
│       ├── bin/
│       └── lib/
│           ├── config/
│           │    ├── di/
│           │    └── env/
│           └── middlewares/
│
├── packages/
│   ├── core/
│   │   ├── README.md
│   │   ├── CHANGELOG.md
│   │   ├── LICENSE.md
│   │   ├── CONTRIBUTING.md
│   │   ├── core_shared/
│   │   │   ├── README.md
│   │   │   ├── CHANGELOG.md
│   │   │   ├── lib/
│   │   │   │   └── src/
│   │   │   └── test/
│   │   ├── core_server/
│   │   │   ├── README.md
│   │   │   ├── CHANGELOG.md
│   │   │   ├── lib/
│   │   │   │   └── src/
│   │   │   └── test/
│   │   ├── core_client/
│   │   │   ├── README.md
│   │   │   ├── CHANGELOG.md
│   │   │   ├── lib/
│   │   │   │   └── src/
│   │   │   └── test/
│   │   └── ui/
│   │       ├── README.md
│   │       ├── CHANGELOG.md
│   │       ├── lib/
│   │       │   └── ui/
│   │       └── test/
│   │
│   ├── design_system/ # estrutura semelhante ao core
│   ├── images/ # estrutura semelhante ao core
│   ├── localizations/ # estrutura semelhante ao core
│   ├── open_api/ # estrutura semelhante ao core
│   └── {features}/ # estrutura semelhante ao core
│
├── scripts/
├── docs/
├── README.md
├── CHANGELOG.md
├── LICENSE.md
└── CONTRIBUTING.md
```