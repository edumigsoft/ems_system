# User Package

Pacote de gerenciamento de usuários do EMS System, implementando CRUD completo com autenticação e autorização baseada em papéis.

## Estrutura Multi-Variante

O pacote segue o padrão de 4 variantes do projeto:

```
user/
├── user_shared/    # Modelos e contratos compartilhados (Pure Dart)
├── user_server/    # Implementação backend (Dart/Shelf)
├── user_client/    # Cliente HTTP (Dio)
└── user_ui/        # Componentes Flutter
```

## User Shared

Camada compartilhada com zero dependências do Flutter.

### Domain Models

**UserRole Enum** (definido em `core_shared`):
```dart
enum UserRole {
  owner(4),    // Proprietário do sistema
  admin(3),    // Administrador global
  manager(2),  // Gerente (NOVO)
  user(1)      // Usuário comum
}
```

**Entities**:
- `User` - Entidade pura do domínio
- `UserDetails` - Entidade com campos de persistência (BaseDetails)

**DTOs**:
- `UserCreate` - Criação de usuário (registro)
- `UserUpdate` - Atualização de dados do usuário
- `UserAdminUpdate` - Atualização administrativa (inclui role, isActive, isDeleted)

**Repository Interface**:
- `UserRepository` - Contrato para operações de persistência

**Models**:
- `UserDetailsModel` - Serialização JSON
- `UserCreateModel` - Serialização de criação
- `UserUpdateModel` - Serialização de atualização

## User Server

Implementação backend com Drift (ORM) e Shelf (HTTP).

### Database

**Tabela**: `Users`
```dart
@DataClassName('UserData')
class Users extends Table with DriftTableMixinPostgres {
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  TextColumn get username => text().unique()();
  TextColumn get role => text().map(const UserRoleConverter())();
  IntColumn get emailVerified => integer().withDefault(const Constant(0))();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get bio => text().nullable()();
}
```

### Repository

`UserRepository` implementa:
- `create(UserCreate)` - Criar novo usuário
- `update(UserUpdate)` - Atualizar dados do usuário
- `adminUpdate(UserAdminUpdate)` - Atualização administrativa
- `findById(String)` - Buscar por ID
- `findByEmail(String)` - Buscar por email
- `findByUsername(String)` - Buscar por username
- `list()` - Listar todos os usuários
- `delete(String)` - Soft delete

### Service

`UserService` adiciona lógica de negócio:
- Validações de email e username únicos
- Verificações de permissão
- Regras de negócio para atualização

### Routes

#### Endpoints Públicos (Usuário Autenticado)

```
GET    /users/me           # Obter perfil do usuário logado
PUT    /users/me           # Atualizar perfil do usuário logado
```

#### Endpoints Administrativos (Requer Admin)

```
GET    /users              # Listar todos os usuários
GET    /users/:id          # Obter usuário por ID
PUT    /users/:id          # Atualizar usuário (admin)
DELETE /users/:id          # Deletar usuário (soft delete)
```

### Middleware

O módulo usa `AuthMiddleware` (do `auth_server`) para proteger rotas:
- Rotas `/users/me` requerem autenticação
- Rotas administrativas requerem papel `admin` ou superior

## User Client

Cliente HTTP usando Dio para comunicação com o backend.

### Uso

```dart
// Obter perfil do usuário logado
final result = await userClient.getMe();

if (result case Success(value: final user)) {
  print('Nome: ${user.name}');
  print('Email: ${user.email}');
  print('Role: ${user.role.name}');
}

// Atualizar perfil
final updateResult = await userClient.updateMe(
  UserUpdate(
    name: 'Novo Nome',
    bio: 'Nova bio',
  ),
);

// Admin: Listar usuários
final listResult = await userClient.list();

// Admin: Atualizar papel de usuário
final adminUpdateResult = await userClient.adminUpdate(
  UserAdminUpdate(
    id: 'user-id',
    role: UserRole.manager,
  ),
);
```

## User UI

Componentes Flutter para gerenciamento de usuários.

### Componentes

- **UserProfilePage** - Página de perfil do usuário
- **UserEditPage** - Formulário de edição de dados
- **UserListPage** - Lista de usuários (admin)
- **UserCard** - Card de exibição de usuário
- **UserAvatar** - Avatar do usuário com fallback

### ViewModels

- `UserProfileViewModel` - Gerencia estado do perfil
- `UserListViewModel` - Gerencia lista de usuários
- `UserEditViewModel` - Gerencia edição de dados

## Autorização por Papéis

### Papéis Globais (UserRole)

O sistema usa papéis hierárquicos:

1. **Owner (4)** - Proprietário do sistema, acesso total
2. **Admin (3)** - Administrador global
   - Pode gerenciar todos os usuários
   - Pode acessar todas as features
   - Bypassa verificações de papéis por feature
3. **Manager (2)** - Gerente
   - Pode ter permissões administrativas limitadas
   - Acesso a features depende de papéis específicos
4. **User (1)** - Usuário comum
   - Acesso padrão
   - Pode ser membro de features específicas

### Verificação de Permissões

```dart
// Verificar se é admin
if (user.role.isAdmin) {
  // Acesso administrativo
}

// Verificar se é pelo menos manager
if (user.role >= UserRole.manager) {
  // Acesso de gerência
}

// Verificar papel específico
if (user.role == UserRole.owner) {
  // Acesso de proprietário
}
```

### Integração com Feature Roles

Usuários com `UserRole.admin` ou superior automaticamente bypassa verificações de papéis específicos de features (projetos, finanças, etc.). Veja `auth_server` README para detalhes sobre `FeatureUserRole`.

## Desenvolvimento

### Executar Build Runner

```bash
cd packages/user/user_server
dart run build_runner build --delete-conflicting-outputs
```

### Executar Testes

```bash
# user_shared
cd packages/user/user_shared
dart test

# user_server
cd packages/user/user_server
dart test

# user_client
cd packages/user/user_client
flutter test
```

### Análise de Código

```bash
dart analyze
```

### Formatação

```bash
dart format .
```

## Dependências

### user_shared
- `core_shared` - Utilitários compartilhados, Result pattern, BaseDetails

### user_server
- `user_shared` - Modelos e contratos
- `core_server` - Utilitários do servidor
- `auth_server` - Middleware de autenticação
- `drift` - ORM

### user_client
- `user_shared` - Modelos e contratos
- `core_client` - Cliente HTTP base
- `dio` - HTTP client

### user_ui
- `user_shared` - Modelos
- `user_client` - Cliente HTTP
- `flutter` - Framework UI

## Migrações

### Schema Version 1 (Atual)
Tabela inicial de usuários com campos:
- Identificação: id, email, username
- Perfil: name, bio, avatarUrl
- Autorização: role, emailVerified
- Metadados: createdAt, updatedAt, isDeleted, isActive

## Exemplos de Uso Completo

### Fluxo de Registro e Login

```dart
// 1. Registrar novo usuário (via auth_server)
final registerResult = await authService.register(RegisterRequest(
  name: 'João Silva',
  email: 'joao@example.com',
  username: 'joaosilva',
  password: 'senha123',
));

// 2. Login (via auth_server)
final loginResult = await authService.login(LoginRequest(
  email: 'joao@example.com',
  password: 'senha123',
));

// 3. Obter perfil completo (via user_client)
final profileResult = await userClient.getMe();

if (profileResult case Success(value: final user)) {
  print('Bem-vindo, ${user.name}!');
  print('Sua role: ${user.role.name}');
}
```

### Atualização de Perfil

```dart
// Usuário atualiza próprio perfil
final result = await userClient.updateMe(UserUpdate(
  name: 'João Pedro Silva',
  bio: 'Desenvolvedor Flutter',
  avatarUrl: 'https://example.com/avatar.jpg',
));

result.when(
  success: (user) => print('Perfil atualizado!'),
  failure: (error) => print('Erro: $error'),
);
```

### Administração de Usuários

```dart
// Admin lista usuários
final listResult = await userClient.list();

if (listResult case Success(value: final users)) {
  for (final user in users) {
    print('${user.name} - ${user.role.name}');
  }
}

// Admin promove usuário a manager
final updateResult = await userClient.adminUpdate(UserAdminUpdate(
  id: 'user-id-123',
  role: UserRole.manager,
));

// Admin desativa usuário
final deactivateResult = await userClient.adminUpdate(UserAdminUpdate(
  id: 'user-id-456',
  isActive: false,
));
```

## Segurança

- **Senhas**: Nunca armazenadas ou trafegadas pelo user package. Gerenciadas pelo `auth_server`
- **Tokens**: JWT gerenciados pelo `auth_server`
- **Autorização**: Middleware verifica permissões antes de processar requisições
- **Validação**: Emails e usernames validados para unicidade
- **Soft Delete**: Usuários são marcados como deletados, não removidos fisicamente

## Roadmap

- [ ] Upload de avatar
- [ ] Verificação de email
- [ ] Perfil público vs privado
- [ ] Preferências de usuário
- [ ] Histórico de atividades
- [ ] Notificações de usuário
