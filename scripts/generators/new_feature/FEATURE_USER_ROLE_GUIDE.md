# Guia de FeatureUserRole

Este guia explica como usar o sistema de controle de acesso baseado em papéis (FeatureUserRole) no EMS System.

## Visão Geral

O sistema de autorização do EMS possui dois níveis complementares:

1. **UserRole** (Global): Define o nível de acesso do usuário em todo o sistema
   - `owner`, `admin`, `manager`, `user`
   - Armazenado na tabela `users`
   - Admin/Owner fazem BYPASS automático das verificações de FeatureUserRole

2. **FeatureUserRole** (Granular): Define o nível de acesso em contextos específicos
   - `owner`, `admin`, `manager`, `member`, `viewer`
   - Armazenado em tabelas por feature (`{feature}_user_role`)
   - Aplica-se a instâncias específicas (ex: projeto X, empresa Y)

## Quando Usar FeatureUserRole

Use FeatureUserRole quando sua feature necessita de:

✅ **Controle de acesso por instância**
- Diferentes usuários podem ter diferentes papéis em diferentes instâncias
- Exemplo: João é `owner` do Projeto A, mas `viewer` do Projeto B

✅ **Compartilhamento e colaboração**
- Múltiplos usuários trabalham na mesma instância
- Exemplo: Equipe colaborando em um projeto

✅ **Hierarquia de permissões**
- Diferentes níveis de acesso dentro do contexto
- Exemplo: Owner pode deletar, Admin pode editar, Member pode comentar, Viewer pode apenas ver

❌ **NÃO use quando:**
- A feature não possui instâncias compartilháveis
- Acesso é sempre individual (ex: preferências do usuário)
- UserRole global já é suficiente

## Estrutura Gerada

O gerador `17_generate_feature_user_role.sh` cria 3 componentes principais:

### 1. Tabela Drift (`{feature}_user_role_table.dart`)

```dart
@UseRowClass(FeatureUserRoleDetails, constructor: 'create')
class ProjectUserRoles extends Table with DriftTableMixinPostgres {
  TextColumn get userId => text()();
  TextColumn get projectId => text()();
  TextColumn get role => text()
      .map(const FeatureUserRoleConverter())
      .withDefault(const Constant('viewer'))();

  @override
  List<Set<Column>> get uniqueKeys => [{userId, projectId}];
}
```

**Características:**
- Unique constraint em `(userId, featureId)` - cada usuário tem apenas 1 papel por instância
- Role padrão: `viewer`
- Inclui campos de BaseDetails (id, createdAt, updatedAt, isDeleted, isActive)

### 2. Repository (`{feature}_user_role_repository.dart`)

Implementa `FeatureUserRoleRepository` com métodos:

- `grant(data)` - Conceder/atualizar papel
- `revoke(userId, featureId)` - Revogar papel (soft delete)
- `getUserRole(userId, featureId)` - Obter papel do usuário
- `listFeatureMembers(featureId)` - Listar membros da feature
- `listUserFeatures(userId)` - Listar features do usuário
- `updateRole(data)` - Atualizar papel
- `hasRole(userId, featureId, minRole)` - Verificar permissão (otimizado)

### 3. Service (`{feature}_user_role_service.dart`)

Lógica de negócio com métodos auxiliares:

- `grantRole()` - Wrapper simplificado
- `revokeRole()` - Wrapper simplificado
- `canManageMembers()` - Verifica se pode gerenciar membros (>= manager)
- `isAdminOrOwner()` - Verifica se é admin ou owner (>= admin)

## Uso do Gerador

### Passo 1: Executar o gerador

```bash
cd /path/to/ems_system
./scripts/generators/new_feature/generators/17_generate_feature_user_role.sh
```

### Passo 2: Responder às perguntas

```
Nome da feature (snake_case, ex: project, finance): project
Nome da entidade ID (camelCase, ex: projectId, financeId): projectId
```

### Passo 3: Integrar ao Database

Adicione a tabela ao arquivo de database da feature:

```dart
// packages/{feature}/{feature}_server/lib/src/database/{feature}_database.dart

import 'tables/{feature}_user_role_table.dart';

@DriftDatabase(tables: [
  // ... outras tabelas
  ProjectUserRoles,  // <- Adicione aqui
])
class ProjectDatabase extends _$ProjectDatabase {
  // ...
}
```

### Passo 4: Executar build_runner

```bash
cd packages/{feature}/{feature}_server
dart run build_runner build --delete-conflicting-outputs
```

### Passo 5: Registrar no Dependency Injection

```dart
// Exemplo com get_it
getIt.registerLazySingleton<ProjectUserRoleRepository>(
  () => ProjectUserRoleRepository(getIt<ProjectDatabase>()),
);

getIt.registerLazySingleton<ProjectUserRoleService>(
  () => ProjectUserRoleService(getIt<ProjectUserRoleRepository>()),
);
```

## Hierarquia de Papéis

### FeatureUserRole.owner (Nível 5)
**Controle total sobre o contexto**

Permissões:
- ✅ Editar, excluir e gerenciar membros
- ✅ Conceder/revogar todos os papéis (incluindo owner)
- ✅ Transferir ownership
- ✅ Acesso a todas as funcionalidades

Restrições:
- Nenhuma (controle total)

Exemplo: Dono do projeto

### FeatureUserRole.admin (Nível 4)
**Gerenciamento completo (exceto owner)**

Permissões:
- ✅ Editar e excluir recursos
- ✅ Gerenciar membros
- ✅ Conceder/revogar papéis (exceto owner)
- ✅ Configurar settings

Restrições:
- ❌ NÃO pode alterar papéis de owner
- ❌ NÃO pode transferir ownership

Exemplo: Administrador do projeto

### FeatureUserRole.manager (Nível 3)
**Gerenciamento limitado**

Permissões:
- ✅ Editar conteúdo
- ✅ Atribuir tarefas
- ✅ Visualizar membros

Restrições:
- ❌ NÃO pode excluir membros
- ❌ NÃO pode alterar configurações críticas
- ❌ NÃO pode alterar papéis de admin/owner

Exemplo: Coordenador de tarefas

### FeatureUserRole.member (Nível 2)
**Leitura e contribuição**

Permissões:
- ✅ Criar e editar próprio conteúdo
- ✅ Comentar e colaborar
- ✅ Visualizar conteúdo compartilhado

Restrições:
- ❌ NÃO pode gerenciar membros
- ❌ NÃO pode excluir recursos importantes
- ❌ Limitado a edição de conteúdo próprio

Exemplo: Colaborador do projeto

### FeatureUserRole.viewer (Nível 1)
**Apenas visualização**

Permissões:
- ✅ Visualizar conteúdo e informações
- ✅ Acessar relatórios (read-only)

Restrições:
- ❌ NÃO pode editar nada
- ❌ NÃO pode criar conteúdo
- ❌ Acesso somente leitura

Exemplo: Observador ou stakeholder

## Uso nos Middlewares

### Middleware Básico

```dart
import 'package:shelf/shelf.dart';
import 'package:auth_server/auth_server.dart';

class ProjectRoutes {
  final FeatureRoleMiddleware _featureRoleMiddleware;

  Router get router {
    final router = Router();

    // Requer pelo menos viewer
    router.get(
      '/projects/<id>',
      Pipeline()
        .addMiddleware(_featureRoleMiddleware.requireFeatureRole(
          FeatureUserRole.viewer,
          (req) => req.params['id']!,  // Extrai projectId
        ))
        .addHandler(_getProject),
    );

    // Requer pelo menos member para criar tarefas
    router.post(
      '/projects/<id>/tasks',
      Pipeline()
        .addMiddleware(_featureRoleMiddleware.requireFeatureRole(
          FeatureUserRole.member,
          (req) => req.params['id']!,
        ))
        .addHandler(_createTask),
    );

    // Requer pelo menos manager para gerenciar membros
    router.post(
      '/projects/<id>/members',
      Pipeline()
        .addMiddleware(_featureRoleMiddleware.requireFeatureRole(
          FeatureUserRole.manager,
          (req) => req.params['id']!,
        ))
        .addHandler(_addMember),
    );

    return router;
  }
}
```

### Bypass Automático para Admin/Owner Globais

```dart
// Usuário com UserRole.admin ou UserRole.owner SEMPRE passa
// nas verificações de FeatureUserRole, independente do papel específico

// Exemplo:
// - Usuário X tem UserRole.admin (global)
// - Usuário X não tem papel no Projeto Y
// - Usuário X acessa /projects/Y/settings
// → ACESSO PERMITIDO (bypass automático)

// Isso está implementado no FeatureRoleMiddleware:
if (authContext.role.isAdmin) {
  return innerHandler(request);  // Bypass!
}
```

## Verificações Programáticas no Handler

```dart
Future<Response> _deleteProject(Request request) async {
  final authContext = request.context['authContext'] as AuthContext;
  final projectId = request.params['id']!;

  // Global admin/owner sempre pode
  if (authContext.role.isAdmin) {
    return _performDelete(projectId);
  }

  // Senão, precisa ser owner do projeto
  final roleResult = await _roleService.getUserRole(
    userId: authContext.userId,
    projectId: projectId,
  );

  return roleResult.when(
    success: (role) {
      if (role?.role == FeatureUserRole.owner) {
        return _performDelete(projectId);
      }
      return Response.forbidden('Only project owner can delete');
    },
    failure: (error) => Response.internalServerError(),
  );
}
```

## Operações Comuns

### Conceder papel a um usuário

```dart
final result = await _roleService.grantRole(
  userId: 'user-123',
  projectId: 'project-456',
  role: FeatureUserRole.admin,
);

result.when(
  success: (details) => print('Role granted: ${details.role}'),
  failure: (error) => print('Error: $error'),
);
```

### Listar membros de um projeto

```dart
final result = await _roleService.listMembers(
  projectId: 'project-456',
);

result.when(
  success: (members) {
    for (final member in members) {
      print('${member.userId}: ${member.role}');
    }
  },
  failure: (error) => print('Error: $error'),
);
```

### Verificar permissão específica

```dart
final canManage = await _roleService.canManageMembers(
  userId: 'user-123',
  projectId: 'project-456',
);

canManage.when(
  success: (allowed) => allowed
      ? print('User can manage members')
      : print('User cannot manage members'),
  failure: (error) => print('Error: $error'),
);
```

### Revogar papel (sair do projeto)

```dart
final result = await _roleService.revokeRole(
  userId: 'user-123',
  projectId: 'project-456',
);

result.when(
  success: (_) => print('User removed from project'),
  failure: (error) => print('Error: $error'),
);
```

## Personalização Após Geração

### Adicionar métodos específicos ao Service

```dart
class ProjectUserRoleService {
  // ... métodos gerados

  /// Método personalizado: transferir ownership
  Future<Result<FeatureUserRoleDetails>> transferOwnership({
    required String currentOwnerId,
    required String newOwnerId,
    required String projectId,
  }) async {
    // 1. Verificar se currentOwner é realmente owner
    final currentRole = await getUserRole(
      userId: currentOwnerId,
      projectId: projectId,
    );

    if (currentRole is! Success ||
        (currentRole as Success).value?.role != FeatureUserRole.owner) {
      return Failure(DataException('Current user is not owner'));
    }

    // 2. Promover novo owner
    await grantRole(
      userId: newOwnerId,
      projectId: projectId,
      role: FeatureUserRole.owner,
    );

    // 3. Rebaixar antigo owner para admin
    return grantRole(
      userId: currentOwnerId,
      projectId: projectId,
      role: FeatureUserRole.admin,
    );
  }
}
```

### Adicionar rotas HTTP específicas

```dart
// Rota para listar membros
router.get(
  '/projects/<id>/members',
  Pipeline()
    .addMiddleware(_featureRoleMiddleware.requireFeatureRole(
      FeatureUserRole.viewer,
      (req) => req.params['id']!,
    ))
    .addHandler((req) async {
      final projectId = req.params['id']!;
      final result = await _roleService.listMembers(projectId: projectId);

      return result.when(
        success: (members) {
          final json = members.map((m) => {
            'userId': m.userId,
            'role': m.role.name,
            'createdAt': m.createdAt.toIso8601String(),
          }).toList();
          return Response.ok(jsonEncode(json));
        },
        failure: (error) => Response.internalServerError(),
      );
    }),
);

// Rota para adicionar membro
router.post(
  '/projects/<id>/members',
  Pipeline()
    .addMiddleware(_featureRoleMiddleware.requireFeatureRole(
      FeatureUserRole.manager,
      (req) => req.params['id']!,
    ))
    .addHandler((req) async {
      final projectId = req.params['id']!;
      final body = jsonDecode(await req.readAsString());

      final result = await _roleService.grantRole(
        userId: body['userId'],
        projectId: projectId,
        role: FeatureUserRole.values.byName(body['role']),
      );

      return result.when(
        success: (details) => Response.ok(jsonEncode({
          'id': details.id,
          'userId': details.userId,
          'role': details.role.name,
        })),
        failure: (error) => Response.badRequest(),
      );
    }),
);
```

## Testes

### Exemplo de teste unitário

```dart
void main() {
  late ProjectUserRoleRepository repository;
  late ProjectUserRoleService service;

  setUp(() {
    final db = ProjectDatabase.memory();
    repository = ProjectUserRoleRepository(db);
    service = ProjectUserRoleService(repository);
  });

  test('grant role creates new role', () async {
    final result = await service.grantRole(
      userId: 'user-1',
      projectId: 'project-1',
      role: FeatureUserRole.admin,
    );

    expect(result, isA<Success<FeatureUserRoleDetails>>());
    final details = (result as Success).value;
    expect(details.userId, 'user-1');
    expect(details.featureId, 'project-1');
    expect(details.role, FeatureUserRole.admin);
  });

  test('hasRole returns true for sufficient role', () async {
    await service.grantRole(
      userId: 'user-1',
      projectId: 'project-1',
      role: FeatureUserRole.admin,
    );

    final result = await service.hasRole(
      userId: 'user-1',
      projectId: 'project-1',
      minRole: FeatureUserRole.member,
    );

    expect(result, isA<Success<bool>>());
    expect((result as Success).value, true);
  });
}
```

## Boas Práticas

### ✅ DO

- Use FeatureUserRole para controle de acesso granular
- Sempre valide papéis antes de operações sensíveis
- Mantenha a hierarquia de papéis consistente
- Use o bypass de admin/owner global quando apropriado
- Documente permissões específicas da sua feature

### ❌ DON'T

- NÃO misture lógica de negócio no repository (use service)
- NÃO ignore verificações de papel (security risk)
- NÃO hardcode papéis - use o enum
- NÃO permita múltiplos papéis por usuário/feature (única restrição)
- NÃO esqueça de incluir a tabela no database file

## Referências

- Documento de arquitetura: `/user_refactor.md`
- Interface genérica: `/packages/auth/auth_shared/lib/src/domain/repositories/feature_user_role_repository.dart`
- Middleware: `/packages/auth/auth_server/lib/src/middleware/feature_role_middleware.dart`
- Enum de papéis: `/packages/auth/auth_shared/lib/src/authorization/feature_user_role_enum.dart`

## Troubleshooting

### Erro: "Table not found"
**Solução:** Adicione a tabela ao database file e execute build_runner

### Erro: "FeatureUserRoleConverter not found"
**Solução:** Importe `package:auth_server/auth_server.dart`

### Middleware não está aplicando
**Solução:** Verifique se AuthMiddleware.verifyJwt está sendo executado antes

### Bypass de admin não funciona
**Solução:** Verifique se AuthContext está sendo injetado corretamente no request

## Suporte

Para dúvidas ou problemas:
1. Consulte este guia
2. Verifique a documentação inline nos enums
3. Examine implementações existentes (se houver)
4. Abra uma issue no repositório
