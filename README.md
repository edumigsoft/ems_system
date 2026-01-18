
# EMS System (EduMigSoft System)

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/edumigsoft/ems_system/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.md)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2.svg?logo=dart&logoColor=white)](https://dart.dev)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

Sistema de Gestão de features para o EduMigSoft.

## 🆕 Atualizações Recentes

### Sistema de Autorização por Papéis em Features ✨

O sistema agora implementa um modelo robusto de autorização em dois níveis:

1. **Papéis Globais** - UserRole expandido com novo papel `manager`
2. **Papéis por Feature** - Controle de acesso granular para projetos, finanças, tarefas, etc.

Cada feature pode ter seus próprios membros com papéis independentes (owner, admin, manager, member, viewer), permitindo que diferentes usuários tenham diferentes níveis de acesso em diferentes projetos.

**Exemplo de implementação disponível**: `project_user_role` em `packages/auth/auth_server`

📚 Documentação completa: [Auth Server README](packages/auth/auth_server/README.md)

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
| `POST` | `/projects/{id}/members` | Adiciona membro ao projeto | ✅ Manager |
| `DELETE` | `/projects/{id}/members/{userId}` | Remove membro do projeto | ✅ Manager |
| `GET`  | `/projects/{id}/members` | Lista membros do projeto | ✅ Viewer |
| `PATCH` | `/projects/{id}/members/{userId}` | Atualiza papel do membro | ✅ Manager |

### Autorização e Papéis

O sistema implementa **RBAC (Role-Based Access Control)** em dois níveis:

#### 1. Papéis Globais (UserRole)
- **Owner (4)** - Proprietário do sistema, acesso total
- **Admin (3)** - Administrador global, bypassa verificações de features
- **Manager (2)** - Gerente com permissões limitadas
- **User (1)** - Usuário comum (padrão)

#### 2. Papéis por Feature (FeatureUserRole)
Cada feature (projetos, finanças, tarefas) possui controle de acesso independente:
- **Owner (5)** - Proprietário da feature
- **Admin (4)** - Administrador da feature
- **Manager (3)** - Gerente (pode adicionar/remover membros)
- **Member (2)** - Membro contribuidor
- **Viewer (1)** - Visualizador (somente leitura)

**Importante**: Usuários com papel global `admin` ou `owner` têm acesso irrestrito a todas as features.

#### Proteção de Rotas
- **Autenticação**: Header `Authorization: Bearer <token>`
- **AuthMiddleware**: Valida JWT e popula `AuthContext`
- **FeatureRoleMiddleware**: Verifica papel específico em features

#### Exemplo de Uso

```dart
// Verificar papel global
if (user.role.isAdmin) {
  // Acesso administrativo global
}

// Proteger rota com papel de feature
router.post(
  '/projects/<projectId>/tasks',
  Pipeline()
    .addMiddleware(authMiddleware.protect())
    .addMiddleware(featureRoleMiddleware.requireFeatureRole(
      FeatureUserRole.member,  // Papel mínimo necessário
      (req) => req.params['projectId']!,
    ))
    .addHandler(_createTask),
);
```

### Arquitetura Modular de Features

Cada feature (projetos, finanças, tarefas) mantém sua própria tabela de papéis, garantindo:
- **Isolamento**: Papéis de uma feature não interferem em outras
- **Escalabilidade**: Fácil adicionar novas features com controle de acesso
- **Flexibilidade**: Cada usuário pode ter diferentes papéis em diferentes contextos

**Implementação de referência**: Veja `ProjectUserRoleRepository`, `ProjectUserRoleService` e `ProjectUserRoleRoutes` em `packages/auth/auth_server` como exemplo completo para criar novas features.

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

### Estrutura

A estrutura do projeto será a seguinte:

```
ems_system/
├── apps/
│   ├── app_design_draft/
│   │   ├── lib/
│   │   │   ├── ui/
│   │   │   │   ├── pages/
│   │   │   │   └── view_models/
│   │   │   └── app_layout.dart
│   │   ├── pubspec.yaml
│   │   └── README.md
│   │
│   ├── app_mobile/
│   │   ├── lib/
│   │   │   ├── ui/
│   │   │   │   ├── pages/
│   │   │   │   └── view_models/
│   │   │   └── app_layout.dart
│   │   ├── pubspec.yaml
│   │   └── README.md
│   │
│   └── app_web/
│       ├── lib/
│       │   ├── ui/
│       │   │   ├── pages/
│       │   │   └── view_models/
│       │   └── app_layout.dart
│       ├── pubspec.yaml
│       └── README.md
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

## 🆕 Novo objetivo e  estrutura

### Objetivo

O novo objetivo é utilizar o sistema EMS System como base para sistemas orientado por features e aplicativos (app e server) este tendo as features base do sistema compartilhados para que seja modular e escalável.
Ambos aplicativos deverá ter seus proprios .env (variáveis de ambientes), databse independentes.
Será compartilhado somente a base de códigos.
Em relação a localização para evitar duplicidade e excesso de traduções sem necessidade em um aplicativo que não precisa, teremos: localization > para as traduções comuns, localization_ems > para o sistema EMS e assim para os demais sistemas.
Em relaçao ao design_system, inicialmente seŕa compartilhado, mas futuramente, será feito estudos/expreiência para diferencia-los.
O sistema deve ser capaz de gerenciar features diversas de forma eficiente, com funcionalidades como:

```
- App
  - ems_app                       # aplicativo voltado para o sistema de gestão pessoal/empresarial
    - ems_app_v1
  - sms_app
    - sms_app_v1                  # aplicativo voltado para o sistema de gestão School Manager System
- Server
  - ems_server
    - ems_server_v1               # servidor voltado para o sistema de gestão pessoal/empresarial
  - sms_server
    - sms_server_v1               # servidor voltado para o sistema de gestão School Manager System
- packages
  - core
    - core_shared
    - core_server
    - core_client
    - core_ui
  - design_system
    - design_system_shared
    - design_system_server
    - design_system_client
    - design_system_ui
  - images
    - images_shared
    - images_server
    - images_client
    - images_ui
  - localizations                 # traduções compartilhado entre os sistemas, cada sistema terá sua própria feature de traduções (localizations_ems, localizations_sms, etc)
    - localizations_shared
    - localizations_server
    - localizations_client
    - localizations_ui
  - open_api
    - open_api_shared
    - open_api_server
    - open_api_client
    - open_api_ui
  - {features}                    # exemplo de feature que poderá ser utilizada em qualquer um dos aplicativos
    - {feature}_shared
    - {feature}_server
    
Ideias de features:
- Gestão de tarefas             # para o EMS e SMS
- Gestão de projetos            # para o EMS e SMS 
- Gestão de usuários            # para o EMS e SMS
- Gestão de finanças            # para o EMS e SMS
- Gestão de imagens             # para o EMS e SMS
- Gestão de alunos              # para o SMS
- Gestão de turmas              # para o SMS
- Gestão de notas               # para o SMS
- Gestão de professores         # para o SMS
- Gestão de turmas              # para o SMS

### Por que esta decisão?

A idéia é aproveitar os conceitos e técnicas de códigos para ambas os sistemas e futuros, facilitando a manutenção e evolução conjunta.

### Problemas possíveis

Uma alteração nos pacotes base, afetará todos os sistemas, o que pode ser um problema em caso de mudanças drásticas na arquitetura ou nas tecnologias utilizadas.

### Soluções possíveis

Mudanças nas bases devem ser feitas em branches separadas e testadas exaustivamente antes de serem mescladas nas bases principais.