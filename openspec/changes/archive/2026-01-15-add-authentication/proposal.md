# Change: Adicionar Sistema de Autenticação

## Why

O EMS System precisa de um sistema completo de autenticação para gerenciar acesso de usuários. Atualmente a infraestrutura de segurança (`SecurityService`, `JWTSecurityService`) existe em `core_server`, mas não há um módulo Auth dedicado com login, registro, refresh token e logout.

O sistema também não possui tabela de usuário, sendo necessário criar tanto a infraestrutura de identidade quanto a de autenticação.

## What Changes

### Arquitetura de Identidade e Autenticação

A implementação segue o princípio de **separação de responsabilidades**:

| Componente | Responsabilidade |
|------------|------------------|
| `core_shared` | `User` - modelo base de identidade (Pure Dart) |
| `packages/user/` | Gestão de usuários (tabela, perfil, CRUD) |
| `packages/auth/` | Autenticação (credenciais, tokens, login/logout) |

#### Justificativa

- **User no core**: Conceito fundamental referenciado por todos os módulos (auth, projects, finance, tasks)
- **User separado de Auth**: Perfil de usuário é diferente de credenciais de acesso
- **Segurança**: Dados sensíveis (password hash) isolados em tabela separada

---

### 1. Alteração em `packages/core/core_shared/`

Adicionar a entity base `User` e enums no padrão de domínio:

```
core_shared/lib/src/domain/
├── entity/
│   └── user.dart          # Entity pura (domínio)
└── enums/
    └── user_role.dart     # Enum de roles globais
```

**UserRole** - Roles globais do sistema:

```dart
/// Roles globais do usuário no sistema.
/// 
/// Define o nível de acesso base do usuário.
/// Permissões específicas por recurso são tratadas separadamente.
enum UserRole { 
  admin,   // Acesso total ao sistema
  user,    // Acesso padrão
  guest    // Acesso limitado (não autenticado ou conta pendente)
}
```

**User** - Entity de domínio puro (seguindo `entity_patterns.md`):

```dart
/// Entity pura de usuário - SEM campos de persistência.
/// 
/// Seguindo as regras:
/// - SEM id (detalhe de persistência)
/// - SEM createdAt/updatedAt (metadados)
/// - SEM toJson/fromJson (responsabilidade de Models)
class User {
  final String name;
  final String email;
  final String username;
  final UserRole role;           // Role global única
  final bool emailVerified;
  final String? avatarUrl;
  final String? phone;

  const User({
    required this.name,
    required this.email,
    required this.username,
    this.role = UserRole.user,
    this.emailVerified = false,
    this.avatarUrl,
    this.phone,
  });
  
  // Lógica de domínio
  bool get isAdmin => role == UserRole.admin;
}
```

> **Por que no core_shared?** 
> `User` é um conceito fundamental referenciado por TODOS os módulos (auth, projects, finance, tasks). Colocá-lo no core evita dependências circulares.

---

### 1.1 Modelo de Autorização (RBAC Genérico)

O sistema utiliza **dois níveis de autorização**:

| Tipo | Escopo | Onde fica | Exemplo |
|------|--------|-----------|---------|
| **Global Role** | Sistema inteiro | `User.role` | `admin`, `user`, `guest` |
| **Resource Permission** | Por recurso (genérico) | Tabela `resource_members` | `project:manage`, `document:read` |

**Cenário suportado:**
```
Usuário João:
├── Global: user (role padrão)
└── Recursos:
    ├── project/abc123 → manage (CRUD + gerenciar membros)
    ├── project/def456 → read (apenas leitura)
    └── document/xyz789 → write (pode editar)
```

---

#### Sistema Genérico de Permissões por Recurso

Uma única estrutura para **qualquer módulo** (projects, documents, teams, etc.):

**`auth_shared` - Permissões padrão:**

```dart
// auth_shared/lib/src/authorization/resource_permission.dart

/// Permissões padrão CRUD reutilizáveis por qualquer módulo.
/// 
/// Hierarquia: read < write < delete < manage
/// Cada nível inclui as permissões dos níveis anteriores.
enum ResourcePermission {
  read(1),    // Apenas leitura
  write(2),   // Criar/editar
  delete(3),  // Remover
  manage(4);  // Controle total + gerenciar membros

  final int level;
  const ResourcePermission(this.level);
  
  /// Verifica se esta permissão satisfaz o nível mínimo exigido.
  bool satisfies(ResourcePermission required) => level >= required.level;
}
```

**`auth_server` - Tabela genérica:**

```dart
// auth_server/lib/src/database/tables/resource_members_table.dart

/// Relacionamento genérico entre usuário e qualquer recurso.
/// 
/// Usado por: projects, documents, teams, organizations, etc.
/// Cada módulo define seu próprio `resourceType`.
class ResourceMembers extends Table with DriftTableMixinPostgres {
  TextColumn get userId => text().references(Users, #id)();
  
  /// Tipo do recurso (ex: "project", "team", "document")
  @JsonKey('resource_type')
  TextColumn get resourceType => text()();
  
  /// ID do recurso específico
  @JsonKey('resource_id')
  TextColumn get resourceId => text()();
  
  /// Permissão do usuário neste recurso
  TextColumn get permission => text()();  // "read", "write", "manage", etc.
}
```

**`auth_server` - Middleware genérico:**

```dart
// auth_server/lib/src/middleware/resource_permission_middleware.dart

/// Middleware reutilizável para verificar permissão em qualquer recurso.
Middleware requireResourcePermission({
  required String resourceType,
  required String resourceIdParam,
  required ResourcePermission minPermission,
}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final resourceId = request.params[resourceIdParam];
      final authContext = request.context['authContext'] as AuthContext;
      
      final hasPermission = await resourcePermissionService.checkPermission(
        userId: authContext.userId,
        resourceType: resourceType,
        resourceId: resourceId!,
        minPermission: minPermission,
      );
      
      if (!hasPermission) {
        return Response.forbidden('Insufficient permissions');
      }
      
      return innerHandler(request);
    };
  };
}
```

---

#### Uso por Qualquer Módulo

O sistema de rotas do projeto usa a classe base `Routes` com flag `security` e função `addRoutes()`:

```dart
// project_server/lib/src/routes/project_routes.dart

/// Rotas de projetos - protegidas por padrão (security = true)
class ProjectRoutes extends Routes {
  final ProjectService _projectService;
  final ResourcePermissionService _permissionService;

  ProjectRoutes(this._projectService, this._permissionService);

  @override
  String get path => '/projects';

  @override
  Router get router {
    final router = Router();
    
    router.get('/', _listProjects);
    router.get('/<projectId>', _getProject);
    router.put('/<projectId>', _updateProject);
    router.delete('/<projectId>', _deleteProject);
    
    return router;
  }

  /// Atualizar projeto - requer permissão write
  Future<Response> _updateProject(Request request) async {
    final projectId = request.params['projectId']!;
    final authContext = request.context['authContext'] as AuthContext;
    
    // Verificar permissão no recurso
    final hasPermission = await _permissionService.checkPermission(
      userId: authContext.userId,
      resourceType: 'project',
      resourceId: projectId,
      minPermission: ResourcePermission.write,
    );
    
    if (!hasPermission) {
      return Response.forbidden('Insufficient permissions');
    }
    
    // Processar atualização...
  }
}

// Registro no server - security: true aplica AuthRequired automaticamente
await addRoutes(di, ProjectRoutes(projectService, permissionService));
```

**Fluxo de autenticação/autorização:**

```
Request
    │
    ▼
┌─────────────────────────────────┐
│ addRoutes(security: true)       │  ← Aplica AuthRequired middleware
│ └── AuthRequired.getMiddleware()│  ← Valida JWT, popula AuthContext
└─────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────┐
│ Handler (ex: _updateProject)    │
│ └── permissionService.check()   │  ← Verifica permissão no recurso
└─────────────────────────────────┘
    │
    ▼
Response
```

**Conceder permissão a um usuário:**

```dart
// Ao criar um projeto, dar permissão manage ao criador
await permissionService.grantPermission(
  userId: authContext.userId,
  resourceType: 'project',
  resourceId: newProjectId,
  permission: ResourcePermission.manage,
);

// Convidar usuário para projeto com permissão de leitura
await permissionService.grantPermission(
  userId: invitedUserId,
  resourceType: 'project',
  resourceId: projectId,
  permission: ResourcePermission.read,
);
```

---

#### Vantagens do Sistema Genérico

| Benefício | Descrição |
|-----------|-----------|
| **Reutilizável** | Um único sistema para projects, documents, teams, etc. |
| **Sem código duplicado** | Não precisa criar `ProjectRole`, `DocumentRole`, etc. |
| **Extensível** | Novos módulos usam o mesmo middleware sem alterações |
| **Hierárquico** | `manage` inclui `delete`, que inclui `write`, que inclui `read` |
| **Centralizado** | Uma tabela, um service, fácil de auditar |
| **Integrado** | Funciona com o padrão `Routes` + `addRoutes()` existente |

---


### 2. Novo Pacote: `packages/user/`

Seguindo o Multi-Variant Package Pattern (ADR-0005):

```
packages/user/
├── user_shared/     # Models, DTOs e Details
│   └── lib/src/
│       ├── domain/entity/
│       │   └── user_details.dart   # Implementa BaseDetails, compõe User
│       ├── dto/
│       │   ├── user_create.dart
│       │   └── user_update.dart
│       └── models/
│           └── user_details_model.dart  # Serialização JSON
│
├── user_server/     # Backend
│   └── database/tables/
│       └── users_table.dart        # Tabela users (Drift)
│   └── repository/
│       └── user_repository.dart    # CRUD de usuários
│   └── service/
│       └── user_service.dart       # Lógica de negócio
│
├── user_client/     # Cliente HTTP para apps Flutter
│   └── user_client.dart
│
└── user_ui/         # Telas de perfil (futuro)
    └── pages/
        └── user_profile_page.dart
```

**UserDetails** (user_shared) - Agregação completa com persistência:

```dart
/// Implementa BaseDetails conforme entity_patterns.md
class UserDetails implements BaseDetails {
  @override final String id;
  @override final DateTime createdAt;
  @override final DateTime updatedAt;
  @override final bool isDeleted;
  @override final bool isActive;

  final User data;

  UserDetails({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isActive = true,
    required String name,
    required String email,
    required String username,
    UserRole role = UserRole.user,
    bool emailVerified = false,
    String? avatarUrl,
    String? phone,
  }) : data = User(
    name: name,
    email: email,
    username: username,
    role: role,
    emailVerified: emailVerified,
    avatarUrl: avatarUrl,
    phone: phone,
  );

  // Getters de conveniência
  String get name => data.name;
  String get email => data.email;
  String get username => data.username;
  UserRole get role => data.role;
}
```

**Tabela `users`** (user_server) - Usando `@UseRowClass`:

```dart
/// Usa @UseRowClass para integrar diretamente com UserDetails do domínio.
/// 
/// Vantagens do @UseRowClass sobre @DataClassName:
/// - Evita duplicação de classes (não gera classe separada)
/// - Integração direta com a entity de domínio
/// - Drift popula UserDetails automaticamente
@UseRowClass(UserDetails)
class Users extends Table with DriftTableMixinPostgres {
  TextColumn get email => text().unique()();
  TextColumn get name => text()();
  TextColumn get username => text().unique()();
  TextColumn get role => text().map(const UserRoleConverter())
      .withDefault(const Constant('user'))();
  
  @JsonKey('email_verified')
  BoolColumn get emailVerified => boolean().withDefault(const Constant(false))();
  
  @JsonKey('avatar_url')
  TextColumn get avatarUrl => text().nullable()();
  
  TextColumn get phone => text().nullable()();
}
```

| Anotação | Drift gera classe? | Quando usar |
|----------|-------------------|-------------|
| `@DataClassName` | ✅ Sim | Quando não há entity de domínio definida |
| `@UseRowClass` | ❌ Não (usa existente) | Quando já existe entity/details no `*_shared` |

> **Decisão:** Usar `@UseRowClass(UserDetails)` porque temos a arquitetura de entity + details definida em `user_shared`, seguindo o `entity_patterns.md`.

---

### 3. Novo Pacote: `packages/auth/`

Seguindo o Multi-Variant Package Pattern (ADR-0005):

```
packages/auth/
├── auth_shared/     # Models puros + contratos de autorização
│   └── lib/src/
│       ├── models/
│       │   ├── auth_request.dart       # LoginRequest, RegisterRequest
│       │   ├── auth_response.dart      # TokenPair, AuthResult
│       │   └── token_payload.dart      # Claims do JWT
│       └── authorization/
│           ├── resource_permission.dart # Enum de permissões (read, write, delete, manage)
│           └── auth_context.dart        # Contexto de autorização (userId, role)
│
├── auth_server/     # Backend
│   └── lib/src/
│       ├── database/tables/
│       │   ├── user_credentials_table.dart   # passwordHash (FK → users)
│       │   ├── refresh_tokens_table.dart     # token, expiresAt, revokedAt
│       │   └── resource_members_table.dart   # ← Permissões genéricas por recurso
│       ├── repository/
│       │   ├── auth_repository.dart
│       │   └── resource_permission_repository.dart  # CRUD de permissões
│       ├── service/
│       │   ├── auth_service.dart        # Usa CryptService e SecurityService do core
│       │   └── resource_permission_service.dart  # Verificação/concessão de permissões
│       ├── routes/
│       │   └── auth_routes.dart         # Endpoints Shelf
│       └── middleware/                  # ← Middlewares de autorização
│           ├── auth_middleware.dart              # Verifica JWT (autenticação)
│           ├── role_middleware.dart              # Verifica UserRole global
│           └── resource_permission_middleware.dart # Verifica permissão por recurso
│
├── auth_client/     # Cliente HTTP para apps Flutter
│   └── lib/src/
│       └── auth_client.dart
│
└── auth_ui/         # Telas de autenticação
    └── lib/src/pages/
        ├── login_page.dart
        ├── register_page.dart
        └── forgot_password_page.dart
```

**Tabelas do auth_server**:

| Tabela | Campos | Relação |
|--------|--------|---------|
| `user_credentials` | `userId`, `passwordHash`, `lastLoginAt` | FK → `users.id` |
| `refresh_tokens` | `userId`, `token`, `expiresAt`, `revokedAt` | FK → `users.id` |
| `resource_members` | `userId`, `resourceType`, `resourceId`, `permission` | FK → `users.id`, genérica |

**Middlewares fornecidos** (auth_server):

| Middleware | Função | Uso |
|------------|--------|-----|
| `authMiddleware.verifyJWT` | Valida token JWT, popula request com AuthContext | Todos endpoints protegidos |
| `authMiddleware.requireRole(UserRole)` | Verifica role global do usuário | Endpoints admin |
| `authMiddleware.requireAnyRole([...])` | Usuário deve ter uma das roles | Endpoints com múltiplas roles |
| `authMiddleware.requireResourcePermission(...)` | Verifica permissão genérica em recurso | Qualquer módulo (projects, docs, etc.) |

**API de Permissões** (ResourcePermissionService):

| Método | Descrição |
|--------|-----------|
| `grantPermission(userId, resourceType, resourceId, permission)` | Concede permissão a um usuário |
| `revokePermission(userId, resourceType, resourceId)` | Remove permissão de um usuário |
| `checkPermission(userId, resourceType, resourceId, minPermission)` | Verifica se usuário tem permissão mínima |
| `listPermissions(resourceType, resourceId)` | Lista todos os usuários com acesso ao recurso |
| `listUserResources(userId, resourceType)` | Lista todos os recursos do tipo que o usuário tem acesso |

### 4. Endpoints de API

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST | `/auth/register` | Registro de novo usuário |
| POST | `/auth/login` | Autenticação com email/senha |
| POST | `/auth/refresh` | Renovação de access token |
| POST | `/auth/logout` | Invalidação de refresh token |
| POST | `/auth/forgot-password` | Solicitação de reset de senha |
| POST | `/auth/reset-password` | Reset de senha com token |

---

### 5. Segurança

- **Access Token (JWT)**: Expiração configurável via `ACCESS_TOKEN_EXPIRES_MINUTES` (padrão: 15 min)
- **Refresh Token**: Expiração configurável via `REFRESH_TOKEN_EXPIRES_DAYS` (padrão: 7 dias)
- **Password hashing**: bcrypt (já disponível no projeto)
- **Rate limiting**: 5 tentativas por conta, 10 por IP em endpoints sensíveis
- **Email service**: Configurável via `EMAIL_SERVICE_*` env vars

---

### 6. Dependências entre Pacotes

```
┌──────────────────────────────┐
│        core_shared           │
│  (User entity em domain/entity)│
│  (UserRole em domain/enums)  │◄───────────────┐
└───────────┬──────────────────┘                │
            │                                   │
    ┌───────┴───────┐                           │
    ▼               ▼                           │
┌────────────┐  ┌──────────────┐                │
│user_shared │  │ auth_shared  │────────────────┘
│(UserDetails│  │(AuthRequest, │
│ UserCreate)│  │ ResourceRole)│
└─────┬──────┘  └──────┬───────┘
      │                │
      ▼                ▼
┌────────────┐  ┌──────────────┐
│user_server │◄─│ auth_server  │
│(Users table│FK│(Credentials, │
│ Repository)│  │ Middlewares) │
└────────────┘  └──────────────┘
```

**Fluxo de dependências:**
- `core_shared` → base (Entity `User` em `domain/entity/`, enum `UserRole` em `domain/enums/`)
- `user_shared` / `auth_shared` → dependem de `core_shared`
- `auth_server` → depende de `user_server` (FK para tabela `users`)
- Outros pacotes (ex: `project_server`) → usam middlewares do `auth_server`

> [!IMPORTANT]
> **Garantia de Não-Circularidade:** O pacote `user_server` NÃO DEVE importar `auth_server`. A direção de dependência é unidirecional: `auth_server → user_server`. O `user_server` expõe apenas a tabela `users` e repositório CRUD básico. Funcionalidades de autenticação (validação de senha, tokens) ficam exclusivamente em `auth_server`.

---

### 7. Email Service (Recomendação)

O email service é utilizado por `auth` (reset de senha) e `user` (verificação de email).

**Recomendação:** Implementar como **utilitário em `core_server`** ao invés de capability separada.

| Opção | Prós | Contras |
|-------|------|--------|
| **`core_server/email/`** ✅ | Reutilizável, simples, sem overhead | Menos isolamento |
| `packages/email/` | Isolamento total | Overhead para algo simples |

**Justificativa:**
- Email é infraestrutura transversal, não domínio de negócio
- Não requer UI própria nem client separado
- Configuração via env vars já existe no padrão do projeto

**Estrutura proposta:**
```
core_server/lib/src/
├── email/
│   ├── email_service.dart       # Interface + implementação
│   ├── email_template.dart      # Templates (verificação, reset)
│   └── email_config.dart        # Leitura de env vars
```

---

## Geração de Código

Utilizar os scripts existentes para scaffold e geração de componentes:

### Scripts de Feature Completa

Para geração de uma feature completa (com todos os 4 pacotes: shared, server, client, ui):

| Script | Descrição |
|--------|-----------|
| `create_feature_wizard.sh` | Wizard interativo que guia a criação de uma feature completa |
| `scaffold_feature.sh` | Gera a estrutura base da feature com todos os pacotes |

**Uso para criar as features `user` e `auth`:**
```bash
cd scripts/generators/new_feature
./create_feature_wizard.sh  # Seguir o wizard para cada feature
```

### Scripts de Componentes Individuais

Na pasta `generators/` existem scripts individuais para criação de componentes específicos. Úteis quando:
- Precisa adicionar mais de uma entity a uma feature existente
- Quer criar apenas um tipo de componente
- Necessita regenerar um componente específico

| Script | Componente | Camada |
|--------|------------|--------|
| `01_generate_entities.sh` | Entities de domínio | shared |
| `02_generate_details.sh` | Details (entity + metadados) | shared |
| `03_generate_dtos.sh` | DTOs (create/update) | shared |
| `04_generate_models.sh` | Models (serialização) | shared |
| `05_generate_converters.sh` | Converters (domain ↔ model) | shared |
| `06_generate_constants.sh` | Constantes de feature | shared |
| `07_generate_tables.sh` | Tabelas (Drift) | server |
| `08_generate_type_converters.sh` | Type converters (Drift) | server |
| `09_generate_repositories.sh` | Repositories | server |
| `10_generate_services.sh` | Services | server |
| `11_generate_routes.sh` | Routes (Shelf) | server |
| `12_generate_use_cases.sh` | Use cases | client |
| `13_generate_validators.sh` | Validators | shared |
| `14_generate_ui_module.sh` | Módulo UI | ui |
| `15_generate_ui_components.sh` | Componentes UI | ui |
| `16_generate_ui_widgets.sh` | Widgets reutilizáveis | ui |

**Exemplo - Adicionar nova entity a feature existente:**
```bash
cd scripts/generators/new_feature/generators
./01_generate_entities.sh auth "SessionToken:token:String,expiresAt:DateTime"
```

> [!TIP]
> Consulte `generators/README.md` e `generators/SUMMARY.md` para documentação completa dos scripts e exemplos de uso avançado.

---

## Ordem de Implementação

1. **core_shared**: Adicionar estrutura de domínio
   - `lib/src/domain/entity/user.dart` - Entity User
   - `lib/src/domain/enums/user_role.dart` - Enum UserRole

2. **packages/user/**: Criar os 4 pacotes (shared, server, client, ui)
   - `user_shared`: `UserDetails`, `UserCreate`, `UserUpdate`, `UserDetailsModel`
   - `user_server`: Tabela `users` com `@UseRowClass(UserDetails)`, `UserRepository`

3. **packages/auth/**: Criar os 4 pacotes (shared, server, client, ui)
   - `auth_shared`: 
     - `AuthRequest`, `AuthResponse`, `TokenPayload`
     - `ResourcePermission` enum (read, write, delete, manage)
     - `AuthContext` (userId, globalRole)
   - `auth_server`: 
     - Tabelas: `user_credentials`, `refresh_tokens`, `resource_members`
     - Services: `AuthService`, `ResourcePermissionService`
     - Middlewares: `AuthMiddleware`, `RoleMiddleware`, `ResourcePermissionMiddleware`
     - Routes: `/auth/login`, `/auth/register`, etc.

4. **server_v1**: Registrar módulos e configurar middlewares
   - Registrar `UserServerModule` e `AuthServerModule`
   - Configurar pipeline de autenticação

---

## Impact

- **Affected specs**: novas capabilities `user` e `auth`
- **Affected code**:
  - `packages/core/core_shared/` (adiciona `domain/entity/user.dart` e `domain/enums/user_role.dart`)
  - `packages/core/core_server/` (adiciona `email/` com EmailService)
  - `packages/user/` (novo - 4 variantes)
  - `packages/auth/` (novo - 4 variantes)
  - `servers/server_v1/` (registra os módulos e middlewares via Injector)
- **Dependências existentes aproveitadas**: `dart_jsonwebtoken`, `bcrypt`, `zard`, `flutter_secure_storage`, `drift`
- **Padrão de ORM**: `@UseRowClass` para integração direta com entities de domínio
- **Modelo de autorização**: RBAC genérico com `ResourcePermission` reutilizável por qualquer módulo
- **Email**: Utilitário transversal em `core_server`, não capability separada




