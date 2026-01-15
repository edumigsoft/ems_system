# Auth Server

Implementação do backend de autenticação e autorização baseada em papéis.

## Funcionalidades

### Autenticação
- **Rotas**: Login, Register, Refresh Token, Logout, Reset Password
- **Middlewares**: AuthMiddleware para proteção de rotas
- **Services**:
  - `AuthService` - Gerenciamento de autenticação (login, registro, tokens)
- **Repositories**:
  - `AuthRepository` - Persistência de credenciais e tokens de refresh

### Autorização por Papéis em Features

Sistema modular de autorização que permite controle de acesso granular por feature (projetos, finanças, tarefas, etc.).

#### Papéis Globais (UserRole)
Definidos em `core_shared`:
- `owner` (nível 4) - Proprietário do sistema
- `admin` (nível 3) - Administrador global
- `manager` (nível 2) - Gerente
- `user` (nível 1) - Usuário comum

#### Papéis por Feature (FeatureUserRole)
Cada feature pode ter seus próprios membros com papéis específicos:
- `owner` (nível 5) - Proprietário da feature
- `admin` (nível 4) - Administrador da feature
- `manager` (nível 3) - Gerente (pode adicionar/remover membros)
- `member` (nível 2) - Membro contribuidor
- `viewer` (nível 1) - Visualizador (somente leitura)

**Nota**: Usuários com papéis globais `admin` ou `owner` têm acesso irrestrito a todas as features, independente dos papéis específicos.

### Exemplo de Implementação: Project User Roles

Este pacote inclui uma implementação completa de papéis de usuário para projetos como exemplo de referência:

- **Tabela**: `ProjectUserRoles` - Armazena papéis de usuários em projetos
- **Repository**: `ProjectUserRoleRepository` - Implementa `FeatureUserRoleRepository`
- **Service**: `ProjectUserRoleService` - Lógica de negócio para gerenciamento de membros
- **Middleware**: `FeatureRoleMiddleware` - Middleware genérico reutilizável
- **Routes**: `ProjectUserRoleRoutes` - Endpoints REST para gerenciamento de membros

#### Endpoints de Project User Roles

```
POST   /api/v1/projects/:projectId/members       # Adicionar membro (requer manager)
DELETE /api/v1/projects/:projectId/members/:userId # Remover membro (requer manager)
GET    /api/v1/projects/:projectId/members       # Listar membros (requer viewer)
GET    /api/v1/projects/:projectId/members/:userId # Obter papel de usuário (requer viewer)
PATCH  /api/v1/projects/:projectId/members/:userId # Atualizar papel (requer manager)
```

## Estrutura do Pacote

```
lib/
├── src/
│   ├── database/
│   │   ├── auth_database.dart           # Database principal (Drift)
│   │   ├── tables/
│   │   │   ├── user_credentials_table.dart
│   │   │   ├── refresh_tokens_table.dart
│   │   │   └── project_user_role_table.dart  # Exemplo de tabela de papéis
│   │   └── converters/
│   │       └── feature_user_role_converter.dart  # Conversor Drift para enum
│   ├── repository/
│   │   ├── auth_repository.dart
│   │   └── project_user_role_repository.dart  # Exemplo de implementação
│   ├── service/
│   │   ├── auth_service.dart
│   │   └── project_user_role_service.dart
│   ├── middleware/
│   │   ├── auth_middleware.dart           # Verificação de JWT
│   │   └── feature_role_middleware.dart   # Verificação de papéis por feature
│   ├── routes/
│   │   ├── auth_routes.dart
│   │   └── project_user_role_routes.dart
│   └── module/
│       └── init_auth_module.dart          # Inicialização do módulo
└── auth_server.dart                       # Barrel file
```

## Criando Papéis para Novas Features

Para adicionar controle de acesso baseado em papéis para uma nova feature (ex: `finance`, `tasks`):

### 1. Criar Tabela Drift

```dart
// finance_user_role_table.dart
@DataClassName('FinanceUserRoleData')
class FinanceUserRoles extends Table with DriftTableMixinPostgres {
  TextColumn get userId => text()();
  TextColumn get financeId => text()();  // featureId
  TextColumn get role => text().map(const FeatureUserRoleConverter())();

  @override
  List<Set<Column>> get uniqueKeys => [{userId, financeId}];
}
```

### 2. Criar Repository

```dart
// finance_user_role_repository.dart
@DriftAccessor(tables: [FinanceUserRoles])
class FinanceUserRoleRepository extends DatabaseAccessor<AuthDatabase>
    with _$FinanceUserRoleRepositoryMixin
    implements FeatureUserRoleRepository {

  FinanceUserRoleRepository(AuthDatabase db) : super(db);

  // Implementar métodos da interface FeatureUserRoleRepository
  // Seguir padrão de project_user_role_repository.dart
}
```

### 3. Criar Service

```dart
// finance_user_role_service.dart
class FinanceUserRoleService {
  final FinanceUserRoleRepository _repository;

  FinanceUserRoleService(this._repository);

  // Métodos de negócio: grantRole, revokeRole, canManage, etc.
}
```

### 4. Criar Routes

```dart
// finance_user_role_routes.dart
class FinanceUserRoleRoutes extends Routes {
  final FinanceUserRoleService _service;

  // Implementar endpoints seguindo padrão de ProjectUserRoleRoutes
}
```

### 5. Registrar no Módulo

```dart
// init_auth_module.dart
di.registerLazySingleton<FinanceUserRoleRepository>(
  () => FinanceUserRoleRepository(authDb),
);

di.registerLazySingleton<FinanceUserRoleService>(
  () => FinanceUserRoleService(di.get<FinanceUserRoleRepository>()),
);

di.registerLazySingleton<FinanceUserRoleRoutes>(
  () => FinanceUserRoleRoutes(
    di.get<FinanceUserRoleService>(),
    backendBaseApi: backendBaseApi,
  ),
);

addRoutes(di, di.get<FinanceUserRoleRoutes>(), security: true);
```

### 6. Atualizar Database

```dart
// auth_database.dart
@DriftDatabase(tables: [
  UserCredentials,
  RefreshTokens,
  ProjectUserRoles,
  FinanceUserRoles,  // ADICIONAR
])
class AuthDatabase extends _$AuthDatabase {
  @override
  int get schemaVersion => 3;  // INCREMENTAR

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.createTable(financeUserRoles);
      }
    },
  );
}
```

## Uso do Middleware

### Proteger Rota Apenas com Autenticação

```dart
router.get(
  '/public-data',
  Pipeline()
    .addMiddleware(authMiddleware.protect())
    .addHandler(_getPublicData),
);
```

### Proteger Rota com Papel Específico

```dart
// Usando FeatureRoleMiddleware
router.post(
  '/projects/<projectId>/tasks',
  Pipeline()
    .addMiddleware(authMiddleware.protect())
    .addMiddleware(featureRoleMiddleware.requireFeatureRole(
      FeatureUserRole.member,  // Papel mínimo necessário
      (req) => req.params['projectId']!,  // Extrator de featureId
    ))
    .addHandler(_createTask),
);
```

**Nota**: Admin/Owner global bypassa automaticamente verificações de feature-role.

## Migrações de Banco de Dados

### Schema Version 1
- Tabelas: `user_credentials`, `refresh_tokens`, `resource_members`

### Schema Version 2 (Atual)
- Removida: `resource_members` (sistema antigo)
- Adicionada: `project_user_roles` (novo sistema)

## Dependências

- `drift` - ORM para banco de dados
- `shelf` - Framework HTTP
- `auth_shared` - Modelos compartilhados de autenticação
- `core_server` - Utilidades compartilhadas do servidor
- `user_server` - Gerenciamento de usuários

## Testes

Execute os testes com:

```bash
dart test
```

## Desenvolvimento

Para gerar código Drift após modificações nas tabelas:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Para análise de código:

```bash
dart analyze
```

Para formatação:

```bash
dart format .
```
