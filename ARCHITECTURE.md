# Sistema EMS - Documentação de Arquitetura

**Versão:** 1.0
**Última Atualização:** 30-01-2026

## Sumário

1. [Visão Geral](#visão-geral)
2. [Padrão de Pacotes Multi-Variantes](#padrão-de-pacotes-multi-variantes)
3. [Arquitetura Limpa (Clean Architecture)](#arquitetura-limpa)
4. [Padrão MVVM](#padrão-mvvm)
5. [Fluxo de Dados](#fluxo-de-dados)
6. [Padrão de Paginação](#padrão-de-paginação)
7. [Busca e Filtragem](#busca-e-filtragem)
8. [Padrão de Exclusão Lógica (Soft Delete)](#padrão-de-exclusão-lógica-soft-delete)
9. [RBAC (Controle de Acesso Baseado em Funções)](#rbac-controle-de-acesso-baseado-em-funções)
10. [Injeção de Dependência](#injeção-de-dependência)
11. [Validação](#validação)
12. [Padrões de UI](#padrões-de-ui)
13. [Exemplos de Código](#exemplos-de-código)

---

## Visão Geral

O Sistema EMS (Sistema EduMigSoft) é um monorepo Flutter/Dart para gerenciamento de usuários, tarefas (Aura), projetos e finanças. A arquitetura segue os princípios da **Arquitetura Limpa (Clean Architecture)** com uma **estrutura de pacotes multi-variantes** que permite o compartilhamento de código entre aplicativos Flutter e servidores backend Dart/Shelf.

**Principais Objetivos Arquiteturais:**
- 📦 **Modularidade**: Pacotes independentes e reutilizáveis
- 🔄 **Compartilhamento de Código**: Lógica de negócios compartilhada entre cliente e servidor
- 🧪 **Testabilidade**: Camada de domínio em Dart puro, fácil de testar
- 🎯 **Separação de Preocupações**: Fronteiras claras entre as camadas
- 🔌 **Agnóstico de Plataforma**: Lógica de domínio independente de Flutter/Shelf

---

## Padrão de Pacotes Multi-Variantes

O monorepo utiliza uma **estrutura de pacotes de 4 variantes**, onde cada funcionalidade é dividida em camadas específicas por plataforma:

```
packages/{funcionalidade}/
├── {funcionalidade}_shared/    # Dart Puro - Domínio, Casos de Uso, Repositórios
├── {funcionalidade}_ui/        # Flutter - Widgets, ViewModels, Páginas
├── {funcionalidade}_client/    # Cliente - Serviços HTTP, Implementação de Repositório
└── {funcionalidade}_server/    # Servidor - Banco de Dados, Rotas, Repositório do Servidor
```

### Responsabilidades das Camadas

#### `*_shared` (Dart Puro)
- ✅ Entidades de domínio e objetos de valor (Value Objects)
- ✅ Casos de Uso (Lógica de negócios)
- ✅ Interfaces de Repositório
- ✅ DTOs e modelos
- ✅ Validadores (Esquemas Zard)
- ✅ Constantes e enums
- ❌ **SEM** dependências do Flutter
- ❌ **SEM** bibliotecas HTTP
- ❌ **SEM** bibliotecas de Banco de Dados

#### `*_ui` (Flutter)
- ✅ ViewModels (MVVM)
- ✅ Widgets e Páginas
- ✅ Navegação
- ✅ Gerenciamento de estado da UI
- ✅ Configuração de Injeção de Dependência
- ➡️ Depende de `*_shared`, `*_client`

#### `*_client` (Lado do Cliente)
- ✅ Serviços HTTP (Retrofit/Dio)
- ✅ Implementações de repositório (chamadas à API HTTP)
- ✅ Mapeamento de respostas
- ➡️ Depende de `*_shared`

#### `*_server` (Lado do Servidor)
- ✅ Consultas ao banco de dados (Drift)
- ✅ Rotas HTTP (Shelf)
- ✅ Implementações de repositório (chamadas ao banco de dados)
- ✅ Middlewares (autenticação, logs)
- ➡️ Depende de `*_shared`

### Direção das Dependências

```
┌─────────────┐
│   *_ui      │────┐
└─────────────┘    │
                   ▼
┌─────────────┐  ┌─────────────┐
│  *_client   │─▶│  *_shared   │◀─┐
└─────────────┘  └─────────────┘  │
                                  │
                 ┌─────────────┐  │
                 │  *_server   │──┘
                 └─────────────┘
```

**Regra:** Todas as variantes dependem de `*_shared`. Não há dependências horizontais.

---

## Arquitetura Limpa

O sistema segue a **Arquitetura Limpa do Uncle Bob** com separação clara de responsabilidades:

```
┌──────────────────────────────────────────────────┐
│                 Apresentação                     │
│         (UI, ViewModels, Widgets)                │
└───────────────────┬──────────────────────────────┘
                    │
┌───────────────────▼──────────────────────────────┐
│                  Aplicação                       │
│        (Casos de Uso, Lógica de Negócio)         │
└───────────────────┬──────────────────────────────┘
                    │
┌───────────────────▼──────────────────────────────┐
│                   Domínio                        │
│      (Entidades, Interfaces de Repositório)      │
└───────────────────┬──────────────────────────────┘
                    │
┌───────────────────▼──────────────────────────────┐
│                Infraestrutura                    │
│   (Banco de Dados, HTTP, Serviços Externos)      │
└──────────────────────────────────────────────────┘
```

### Detalhamento das Camadas

#### 1. Camada de Domínio (`*_shared`)

**Entidades:**
```dart
// Objetos de negócio puros
class SchoolDetails implements BaseDetails {
  final String id;
  final bool isDeleted;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String code;
  final SchoolStatus status;
  // ...
}
```

**Interfaces de Repositório:**
```dart
abstract class SchoolRepository {
  Future<Result<PaginatedResult<SchoolDetails>>> getAll({
    int? limit,
    int? offset,
    String? search,
    SchoolStatus? status,
  });

  Future<Result<SchoolDetails>> create(SchoolCreate school);
  Future<Result<SchoolDetails>> update(SchoolDetails school);
  Future<Result<Unit>> delete(String id);
  Future<Result<Unit>> restore(String id);
}
```

#### 2. Camada de Aplicação (`*_shared`)

**Casos de Uso:**
```dart
class GetAllUseCase {
  final SchoolRepository _repository;

  GetAllUseCase({required SchoolRepository repository})
    : _repository = repository;

  Future<Result<PaginatedResult<SchoolDetails>>> execute({
    int? limit,
    int? offset,
    String? search,
    SchoolStatus? status,
  }) {
    return _repository.getAll(
      limit: limit,
      offset: offset,
      search: search,
      status: status,
    );
  }
}
```

**Benefícios:**
- ✅ Responsabilidade Única: Um caso de uso por operação de negócio
- ✅ Testável: Fácil de mockar o repositório
- ✅ Reutilizável: Mesmo caso de uso para web, mobile, CLI

#### 3. Camada de Infraestrutura

**Repositório do Servidor (`*_server`):**
```dart
class SchoolRepositoryServer implements SchoolRepository {
  final SchoolQueries _schoolQueries;

  @override
  Future<Result<PaginatedResult<SchoolDetails>>> getAll({...}) async {
    try {
      final items = await _schoolQueries.getAll(...);
      final total = await _schoolQueries.getTotalCount(...);

      return Success(PaginatedResult.fromOffset(
        items: items,
        total: total,
        offset: offset ?? 0,
        limit: limit ?? 50,
      ));
    } on Exception catch (e) {
      return Failure(DataException(e.toString()));
    }
  }
}
```

**Repositório do Cliente (`*_client`):**
```dart
class SchoolRepositoryClient implements SchoolRepository {
  final SchoolService _schoolService;

  @override
  Future<Result<PaginatedResult<SchoolDetails>>> getAll({...}) async {
    return executeRequest(
      request: () => _schoolService.getAll(limit, offset, search, status?.name),
      context: 'buscando escolas',
      mapper: (models) => models.map((m) => m.toDomain()).toList(),
    );
  }
}
```

#### 4. Camada de Apresentação (`*_ui`)

**ViewModels (MVVM):**
```dart
class SchoolViewModel extends BaseCRUDViewModel<SchoolDetails> {
  final GetAllUseCase _getAllUseCase;

  late final Command0<List<SchoolDetails>> fetchAllCommand = Command0(_fetchAll);

  Future<Result<List<SchoolDetails>>> _fetchAll() async {
    final result = await _getAllUseCase.execute();
    return result.map((paginatedResult) => paginatedResult.items);
  }
}
```

---

## Padrão MVVM

A camada de UI segue o padrão **Model-View-ViewModel (MVVM)**:

```
┌─────────────┐        ┌──────────────┐        ┌─────────────┐
│    View     │───────▶│  ViewModel   │───────▶│ Caso de Uso │
│  (Widget)   │◀───────│  (Commands)  │◀───────│  (Negócio)  │
└─────────────┘ notifica └──────────────┘ Resultado └─────────────┘
```

### Estrutura da ViewModel

```dart
class SchoolViewModel extends BaseCRUDViewModel<SchoolDetails>
    with FormValidationMixin {

  // Dependências (Casos de Uso)
  final GetAllUseCase _getAllUseCase;
  final CreateUseCase _createUseCase;
  final UpdateUseCase _updateUseCase;
  final DeleteUseCase _deleteUseCase;

  // Estado
  bool _showDeleted = false;
  bool get showDeleted => _showDeleted;

  // Comandos (Operações de UI)
  late final Command0<List<SchoolDetails>> fetchAllCommand = Command0(_fetchAll);
  late final Command0<Unit> refreshCommand = Command0(_refresh);
  late final Command0<Unit> toggleShowDeletedCommand = Command0(_toggleShowDeleted);

  // Implementações dos comandos
  Future<Result<List<SchoolDetails>>> _fetchAll() async {
    final result = _showDeleted
        ? await _getDeletedUseCase.execute()
        : await _getAllUseCase.execute();
    return result.map((paginatedResult) => paginatedResult.items);
  }
}
```

### Padrão Command

**Command0** (sem argumentos):
```dart
late final Command0<Unit> refreshCommand = Command0(_refresh);

Future<Result<Unit>> _refresh() async {
  await fetchAllCommand.execute();
  return successOfUnit();
}
```

**Command1** (um argumento):
```dart
late final Command1<SchoolDetails, SchoolDetails> detailsCommand = Command1(_setDetails);

Future<Result<SchoolDetails>> _setDetails(SchoolDetails school) async {
  details = school;
  notifyListeners();
  return Success(school);
}
```

### Integração com a View (Widget)

```dart
class SchoolPage extends StatefulWidget {
  final SchoolViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return viewModel.fetchAllCommand.running
            ? CircularProgressIndicator()
            : viewModel.fetchAllCommand.result?.when(
                success: (schools) => ListView(...),
                failure: (error) => ErrorWidget(...),
              ) ?? EmptyWidget();
      },
    );
  }
}
```

---

## Fluxo de Dados

### 1. Fluxo de Leitura (Buscando Dados)

```
Ação do Usuário
    ↓
Widget chama ViewModel.fetchAllCommand.execute()
    ↓
ViewModel chama UseCase.execute()
    ↓
UseCase chama Repository.getAll()
    ↓
Repositório (Cliente) chama Serviço HTTP
    ↓
Serviço HTTP faz requisição GET para o Servidor
    ↓
Rota do Servidor recebe a requisição
    ↓
Repositório do Servidor chama Consultas ao Banco de Dados
    ↓
Banco de Dados retorna os dados
    ↓
Servidor mapeia para entidades de Domínio
    ↓
Servidor retorna resposta JSON
    ↓
Cliente desserializa para Modelos
    ↓
Cliente mapeia para entidades de Domínio
    ↓
Repositório retorna Result<List<Entidade>>
    ↓
UseCase retorna Result para a ViewModel
    ↓
ViewModel atualiza estado, notifica ouvintes
    ↓
Widget reconstrói com novos dados
```

### 2. Fluxo de Escrita (Criando/Atualizando Dados)

```
Usuário preenche formulário
    ↓
Widget chama ViewModel.saveCommand.execute()
    ↓
ViewModel valida com FormValidationMixin
    ↓
ViewModel chama CreateUseCase/UpdateUseCase.execute(entidade)
    ↓
UseCase chama Repository.create()/update()
    ↓
Repositório (Cliente) chama Serviço HTTP
    ↓
Serviço HTTP faz requisição POST/PUT
    ↓
Servidor valida com SchemaValidator
    ↓
Repositório do Servidor chama Consultas ao Banco de Dados
    ↓
Banco de Dados insere/atualiza registro
    ↓
Servidor retorna entidade criada/atualizada
    ↓
Cliente desserializa e mapeia para Domínio
    ↓
Repositório retorna Result<Entidade>
    ↓
ViewModel atualiza estado, atualiza lista
    ↓
Widget mostra mensagem de sucesso
```

---

## Padrão de Paginação

### Implementação no Backend

**Consulta com COUNT:**
```dart
class SchoolQueries extends DatabaseAccessor<SchoolDatabase> {
  // Busca itens paginados
  Future<List<SchoolDetails>> getAll({
    int? limit,
    int? offset,
    String? search,
  }) async {
    final query = select(schoolTable);
    query.where((t) => t.isDeleted.equals(0));

    if (search != null && search.isNotEmpty) {
      query.where((t) => t.name.contains(search) | t.code.contains(search));
    }

    query.orderBy([(t) => OrderingTerm.asc(t.name)]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    final result = await query.get();
    return result.map((row) => SchoolDetails(...)).toList();
  }

  // Obtém contagem total com os mesmos filtros
  Future<int> getTotalCount({String? search}) async {
    final query = selectOnly(schoolTable);
    query.where(schoolTable.isDeleted.equals(0));

    if (search != null && search.isNotEmpty) {
      query.where(
        schoolTable.name.contains(search) | schoolTable.code.contains(search),
      );
    }

    query.addColumns([schoolTable.id.count()]);

    final result = await query.getSingle();
    return result.read(schoolTable.id.count()) ?? 0;
  }
}
```

**Repositório com PaginatedResult:**
```dart
@override
Future<Result<PaginatedResult<SchoolDetails>>> getAll({
  int? limit,
  int? offset,
  String? search,
}) async {
  try {
    final effectiveLimit = limit ?? 50;
    final effectiveOffset = offset ?? 0;

    // Busca itens e total em paralelo (otimização opcional)
    final items = await _schoolQueries.getAll(
      limit: effectiveLimit,
      offset: effectiveOffset,
      search: search,
    );

    final total = await _schoolQueries.getTotalCount(search: search);

    final result = PaginatedResult.fromOffset(
      items: items,
      total: total,
      offset: effectiveOffset,
      limit: effectiveLimit,
    );

    return Success(result);
  } on Exception catch (e) {
    return Failure(DataException(e.toString()));
  }
}
```

### Paginação no Frontend

**ViewModel:**
```dart
Future<Result<List<SchoolDetails>>> _fetchAll() async {
  final result = await _getAllUseCase.execute(
    limit: 50,
    offset: _currentPage * 50,
    search: _searchQuery,
  );
  return result.map((paginatedResult) => paginatedResult.items);
}
```

**UI com DSPaginationController:**
```dart
final paginationController = DSPaginationController(
  allItems: filteredSchools,
  itemsPerPage: 10,
);

DSPagination(
  currentPage: paginationController.currentPage,
  totalItems: paginationController.totalItems,
  itemsPerPage: paginationController.itemsPerPage,
  onPreviousPage: () => setState(() => paginationController.previousPage()),
  onNextPage: () => setState(() => paginationController.nextPage()),
  hasPreviousPage: paginationController.hasPreviousPage,
  hasNextPage: paginationController.hasNextPage,
)
```

---

## Busca e Filtragem

### Padrão de Parâmetros de Consulta (Query Parameters)

**Rota do Backend:**
```dart
Future<Response> getAll(Request request) async {
  final queryParams = request.url.queryParameters;

  // Analisa paginação
  final limit = queryParams.containsKey('limit')
      ? int.tryParse(queryParams['limit']!)
      : null;
  final offset = queryParams.containsKey('offset')
      ? int.tryParse(queryParams['offset']!)
      : null;

  // Analisa filtros
  final search = queryParams['search'];
  final city = queryParams['city'];
  final district = queryParams['district'];

  // Analisa enum
  final statusStr = queryParams['status'];
  final status = statusStr != null
      ? SchoolStatus.values.firstWhere(
          (e) => e.name == statusStr,
          orElse: () => null,
        )
      : null;

  final result = await _repository.getAll(
    limit: limit,
    offset: offset,
    search: search,
    status: status,
    city: city,
    district: district,
  );

  return HttpResponseHelper.toResponse(result, onSuccess: (data) => {...});
}
```

### UI de Filtros no Frontend

**Filtros Desktop:**
```dart
// Filtros ativos com chips
DSTableFilterBar<SchoolDetails>(
  filters: activeFilters,
  onFilterChanged: (filter) {
    setState(() {
      if (activeFilters.contains(filter)) {
        activeFilters.remove(filter);
      } else {
        activeFilters.add(filter);
      }
      _applyFilters();
    });
  },
  onClearAll: () {
    setState(() {
      activeFilters.clear();
      _applyFilters();
    });
  },
)

// Filtros disponíveis como botões
availableFilters
    .where((f) => !activeFilters.contains(f))
    .map((filter) => OutlinedButton.icon(
          onPressed: () => setState(() {
            activeFilters.add(filter);
            _applyFilters();
          }),
          icon: Icon(Icons.add, size: 16),
          label: Text(filter.label),
        ))
    .toList()
```

---

## Padrão de Exclusão Lógica (Soft Delete)

### Esquema do Banco de Dados

```dart
@DriftDatabase(tables: [SchoolTable])
class SchoolDatabase extends _$SchoolDatabase {
  // ...
}

class SchoolTable extends Table with DriftTableMixinPostgres {
  // Herdado do mixin:
  // IntColumn get isDeleted => integer().withDefault(const Constant(0))();
  // IntColumn get isActive => integer().withDefault(const Constant(1))();
  // TextColumn get id => text()();
  // DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get name => text()();
  TextColumn get code => text().unique()();
  // ... outros campos
}
```

### Padrão de Consulta

**Filtrar Registros Ativos:**
```dart
Future<List<SchoolDetails>> getAll({...}) async {
  final query = select(schoolTable);

  // SEMPRE exclui os deletados
  query.where((t) => t.isDeleted.equals(0));

  // ... outros filtros
}
```

**Obter Registros Deletados:**
```dart
Future<List<SchoolDetails>> getDeleted({...}) async {
  final query = select(schoolTable);

  // APENAS os deletados
  query.where((t) => t.isDeleted.equals(1));

  // ... outros filtros
}
```

### Métodos de Repositório

```dart
abstract class SchoolRepository {
  // CRUD regular exclui deletados
  Future<Result<PaginatedResult<SchoolDetails>>> getAll({...});

  // Método específico para itens deletados
  Future<Result<PaginatedResult<SchoolDetails>>> getDeleted({...});

  // Exclusão lógica (define isDeleted = true)
  Future<Result<Unit>> delete(String id);

  // Restaurar (define isDeleted = false)
  Future<Result<Unit>> restore(String id);
}
```

### Padrão de Alternância (Toggle) na UI

**ViewModel:**
```dart
bool _showDeleted = false;
bool get showDeleted => _showDeleted;

late final Command0<Unit> toggleShowDeletedCommand = Command0(_toggleShowDeleted);

Future<Result<List<SchoolDetails>>> _fetchAll() async {
  final result = _showDeleted
      ? await _getDeletedUseCase.execute()
      : await _getAllUseCase.execute();
  return result.map((paginatedResult) => paginatedResult.items);
}

Future<Result<Unit>> _toggleShowDeleted() async {
  _showDeleted = !_showDeleted;
  await fetchAllCommand.execute();
  notifyListeners();
  return successOfUnit();
}
```

**Botão de Alternância na UI:**
```dart
FilterChip(
  label: Text(viewModel.showDeleted ? 'Deletadas' : 'Ativas'),
  selected: viewModel.showDeleted,
  onSelected: (_) => viewModel.toggleShowDeletedCommand.execute(),
  avatar: Icon(
    viewModel.showDeleted ? Icons.delete_outline : Icons.check_circle_outline,
  ),
)
```

**Ações Condicionais:**
```dart
DSDataTableColumn<SchoolDetails>(
  label: 'AÇÕES',
  builder: (school) => DSTableActions(
    actions: school.isDeleted
        ? [
            // Itens deletados: apenas restaurar
            DSTableAction(
              icon: Icons.restore_from_trash,
              onPressed: () => _restoreSchool(school),
              tooltip: 'Restaurar',
            ),
          ]
        : [
            // Itens ativos: editar e excluir
            DSTableAction(
              icon: Icons.edit,
              onPressed: () => _editSchool(school),
              tooltip: 'Editar',
            ),
            DSTableAction(
              icon: Icons.delete_outline,
              onPressed: () => _deleteSchool(school),
              tooltip: 'Excluir',
            ),
          ],
  ),
)
```

---

## RBAC (Controle de Acesso Baseado em Funções)

### Hierarquia de Funções de Usuário

```dart
enum UserRole {
  owner(4),     // Acesso total irrestrito
  admin(3),     // Amplas permissões de gerenciamento
  manager(2),   // Escopo de gerenciamento limitado
  user(1);      // Usuário regular

  const UserRole(this.level);
  final int level;

  bool operator >=(UserRole other) => level >= other.level;
}
```

### Contexto de Autenticação

```dart
class AuthContext {
  final String userId;
  final String email;
  final UserRole role;

  const AuthContext({
    required this.userId,
    required this.email,
    required this.role,
  });

  bool hasRole(UserRole required) => role >= required;
  bool hasAnyRole(List<UserRole> roles) => roles.contains(role);
}
```

### Middleware

```dart
class AuthMiddleware {
  // Verifica JWT e extrai informações do usuário
  Handler verifyJwt(Handler handler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(401, body: 'Token ausente ou inválido');
      }

      final token = authHeader.substring(7);
      final payload = _verifyToken(token); // Verifica JWT

      final authContext = AuthContext(
        userId: payload['userId'],
        email: payload['email'],
        role: UserRole.values.byName(payload['role']),
      );

      // Anexa ao contexto da requisição
      return handler(request.change(context: {'authContext': authContext}));
    };
  }

  // Requer uma função específica
  Handler requireRole(UserRole required) {
    return (Request request) async {
      final authContext = request.context['authContext'] as AuthContext?;

      if (authContext == null) {
        return Response(401, body: 'Não autorizado');
      }

      if (!authContext.hasRole(required)) {
        return Response(403, body: 'Permissões insuficientes');
      }

      return handler(request);
    };
  }
}
```

### Proteção de Rotas

```dart
class SchoolRoutes extends Routes {
  final AuthMiddleware _authMiddleware;

  @override
  Router get router {
    final router = Router();

    final authMiddleware = _authMiddleware.verifyJwt;
    final adminMiddleware = _authMiddleware.requireRole(UserRole.admin);
    final ownerMiddleware = _authMiddleware.requireRole(UserRole.owner);

    // Leitura pública - qualquer usuário autenticado
    router.get(
      '/schools',
      Pipeline().addMiddleware(authMiddleware).addHandler(getAll),
    );

    // Operações de Admin
    router.post(
      '/schools',
      Pipeline().addMiddleware(adminMiddleware).addHandler(create),
    );

    router.put(
      '/schools/<id>',
      Pipeline().addMiddleware(adminMiddleware).addHandler(update),
    );

    router.post(
      '/schools/<id>/restore',
      Pipeline().addMiddleware(adminMiddleware).addHandler(restore),
    );

    // Operações exclusivas de Owner
    router.delete(
      '/schools/<id>',
      Pipeline().addMiddleware(ownerMiddleware).addHandler(delete),
    );

    // Admin+ pode visualizar deletados
    router.get(
      '/schools/deleted',
      Pipeline().addMiddleware(adminMiddleware).addHandler(getDeleted),
    );

    return router;
  }
}
```

### Matriz de Permissões

| Operação | Usuário | Gerente | Admin | Dono (Owner) |
|-----------|------|---------|-------|-------|
| Ver Escolas Ativas | ✅ | ✅ | ✅ | ✅ |
| Ver Escolas Deletadas | ❌ | ❌ | ✅ | ✅ |
| Criar Escola | ❌ | ❌ | ✅ | ✅ |
| Atualizar Escola | ❌ | ❌ | ✅ | ✅ |
| Restaurar Escola | ❌ | ❌ | ✅ | ✅ |
| Excluir Escola | ❌ | ❌ | ❌ | ✅ |

---

## Injeção de Dependência

### Padrão Module

```dart
class SchoolModule extends AppModule {
  final DependencyInjector di;

  SchoolModule({required this.di});

  @override
  void registerDependencies(DependencyInjector di) {
    // Serviço HTTP (Singleton)
    di.registerLazySingleton<SchoolService>(
      () => SchoolService(di.get()),
    );

    // Repositório (Singleton)
    di.registerLazySingleton<SchoolRepository>(
      () => SchoolRepositoryClient(
        schoolService: di.get<SchoolService>(),
      ),
    );

    // Casos de Uso (Singleton)
    di.registerLazySingleton<GetAllUseCase>(
      () => GetAllUseCase(repository: di.get<SchoolRepository>()),
    );

    di.registerLazySingleton<GetDeletedSchoolsUseCase>(
      () => GetDeletedSchoolsUseCase(repository: di.get<SchoolRepository>()),
    );

    di.registerLazySingleton<CreateUseCase>(
      () => CreateUseCase(repository: di.get<SchoolRepository>()),
    );

    di.registerLazySingleton<UpdateUseCase>(
      () => UpdateUseCase(repository: di.get<SchoolRepository>()),
    );

    di.registerLazySingleton<DeleteUseCase>(
      () => DeleteUseCase(repository: di.get<SchoolRepository>()),
    );

    di.registerLazySingleton<RestoreSchoolUseCase>(
      () => RestoreSchoolUseCase(repository: di.get<SchoolRepository>()),
    );

    // ViewModel (Singleton)
    di.registerLazySingleton<SchoolViewModel>(
      () => SchoolViewModel(
        getAllUseCase: di.get<GetAllUseCase>(),
        getDeletedUseCase: di.get<GetDeletedSchoolsUseCase>(),
        createUseCase: di.get<CreateUseCase>(),
        updateUseCase: di.get<UpdateUseCase>(),
        deleteUseCase: di.get<DeleteUseCase>(),
        restoreUseCase: di.get<RestoreSchoolUseCase>(),
      ),
    );

    // Página (Singleton)
    di.registerLazySingleton<SchoolPage>(
      () => SchoolPage(viewModel: di.get<SchoolViewModel>()),
    );
  }

  @override
  Map<String, Widget> get routes => {
    '/schools': di.get<SchoolPage>(),
  };
}
```

### Singleton vs Factory

**Singleton (`registerLazySingleton`):**
- Criado uma única vez, reutilizado em todo o app.
- Uso recomendado para: ViewModels, Repositórios, Serviços.
- Memória: Uma única instância.

**Factory (`registerFactory`):**
- Criado toda vez que for solicitado.
- Uso recomendado para: Objetos temporários, instâncias por requisição.
- Memória: Nova instância a cada solicitação.

---

## Validação

### Validação Baseada em Esquema Zard

**Definição do Esquema (`*_shared`):**
```dart
class SchoolDetailsValidator {
  const SchoolDetailsValidator();

  static final schema = z.object({
    'name': z.string().min(3, 'Nome deve ter no mínimo 3 caracteres'),
    'code': z.string().regex(
      RegExp(r'^[A-Z0-9]{6,10}$'),
      'Código deve ter 6-10 caracteres alfanuméricos',
    ),
    'email': z.string().email('Email inválido'),
    'phone': z.string().regex(
      RegExp(r'^\(\d{2}\) \d{4,5}-\d{4}$'),
      'Formato: (XX) XXXXX-XXXX',
    ),
    'status': z.string().oneOf(['active', 'inactive', 'maintenance']),
  });

  ValidationResult validate(SchoolDetails school) {
    final data = SchoolDetailsModel.fromDomain(school).toJson();
    return schema.validate(data);
  }
}
```

**Validação no Lado do Servidor:**
```dart
Future<Response> create(Request request) async {
  final body = await request.readAsString();
  final data = json.decode(body) as Map<String, dynamic>;

  final schoolCreateModel = SchoolCreateModel.fromJson(data);
  final schoolCreate = schoolCreateModel.toDomain();

  // Valida
  final tempSchool = SchoolDetails.fromData(id: 'temp', data: schoolCreate);
  final validation = _validator.validate(tempSchool);

  if (!validation.isValid) {
    return Response(
      400,
      body: json.encode({
        'error': 'Dados inválidos',
        'details': validation.errors
            .map((e) => {'field': e.field, 'message': e.message})
            .toList(),
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  final result = await _repository.create(schoolCreate);
  return HttpResponseHelper.toResponse(result, successCode: 201);
}
```

**Validação no Lado do Cliente (FormValidationMixin):**
```dart
class SchoolViewModel extends BaseCRUDViewModel<SchoolDetails>
    with FormValidationMixin {

  @override
  Future<Result<SchoolDetails>> createEntity(SchoolDetails entity) async {
    // Valida antes de enviar para o servidor
    final validation = validateForm(
      data: SchoolDetailsModel.fromDomain(entity).toJson(),
      schema: SchoolDetailsValidator.schema,
    );

    if (validation case Failure(error: final error)) {
      return Failure(error);
    }

    return _createUseCase.execute(entity);
  }
}
```

---

## Padrões de UI

### Pull-to-Refresh (Arrastar para Atualizar)

**Mobile/Tablet:**
```dart
RefreshIndicator(
  onRefresh: () async {
    await viewModel.refreshCommand.execute();
  },
  child: ListView.builder(...),
)
```

**Desktop:**
```dart
IconButton(
  icon: Icon(Icons.refresh),
  onPressed: viewModel.fetchAllCommand.running
      ? null
      : () => viewModel.refreshCommand.execute(),
  tooltip: 'Atualizar lista',
)
```

### Layout Responsivo

```dart
ResponsiveLayout(
  mobile: MobileWidget(viewModel: viewModel),
  tablet: TabletWidget(viewModel: viewModel),
  desktop: DesktopWidget(viewModel: viewModel),
)
```

### Diálogos de Confirmação

```dart
void _showRestoreConfirmation(BuildContext context, String schoolName) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Restaurar Escola'),
      content: Text('Deseja restaurar a escola "$schoolName"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            viewModel.restoreCommand.execute();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Escola "$schoolName" restaurada!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: Text('Restaurar'),
        ),
      ],
    ),
  );
}
```

### Estados de Carregamento

```dart
viewModel.fetchAllCommand.running
    ? Center(child: CircularProgressIndicator())
    : viewModel.fetchAllCommand.result?.when(
          success: (schools) => ListView(...),
          failure: (error) => ErrorWidget(error),
        ) ?? EmptyWidget()
```

---

## Exemplos de Código

### Exemplo Completo de Fluxo CRUD

**1. Definir Entidade (`*_shared`):**
```dart
class SchoolDetails {
  final String id;
  final String name;
  final String code;

  const SchoolDetails({
    required this.id,
    required this.name,
    required this.code,
  });

  SchoolDetails copyWith({String? name, String? code}) {
    return SchoolDetails(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
    );
  }
}
```

**2. Definir Interface de Repositório (`*_shared`):**
```dart
abstract class SchoolRepository {
  Future<Result<List<SchoolDetails>>> getAll();
  Future<Result<SchoolDetails>> create(SchoolCreate school);
}
```

**3. Criar Caso de Uso (`*_shared`):**
```dart
class GetAllUseCase {
  final SchoolRepository _repository;

  GetAllUseCase({required SchoolRepository repository})
    : _repository = repository;

  Future<Result<List<SchoolDetails>>> execute() {
    return _repository.getAll();
  }
}
```

**4. Implementar Repositório do Servidor (`*_server`):**
```dart
class SchoolRepositoryServer implements SchoolRepository {
  final SchoolQueries _queries;

  @override
  Future<Result<List<SchoolDetails>>> getAll() async {
    try {
      final items = await _queries.getAll();
      return Success(items);
    } catch (e) {
      return Failure(DataException(e.toString()));
    }
  }
}
```

**5. Implementar Repositório do Cliente (`*_client`):**
```dart
class SchoolRepositoryClient implements SchoolRepository {
  final SchoolService _service;

  @override
  Future<Result<List<SchoolDetails>>> getAll() async {
    return executeRequest(
      request: () => _service.getAll(),
      context: 'buscando escolas',
      mapper: (models) => models.map((m) => m.toDomain()).toList(),
    );
  }
}
```

**6. Criar ViewModel (`*_ui`):**
```dart
class SchoolViewModel extends ChangeNotifier {
  final GetAllUseCase _getAllUseCase;

  late final Command0<List<SchoolDetails>> fetchAllCommand = Command0(_fetchAll);

  Future<Result<List<SchoolDetails>>> _fetchAll() {
    return _getAllUseCase.execute();
  }
}
```

**7. Construir a UI (`*_ui`):**
```dart
class SchoolPage extends StatelessWidget {
  final SchoolViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return viewModel.fetchAllCommand.result?.when(
          success: (schools) => ListView.builder(
            itemCount: schools.length,
            itemBuilder: (context, index) {
              final school = schools[index];
              return ListTile(
                title: Text(school.name),
                subtitle: Text(school.code),
              );
            },
          ),
          failure: (error) => Text('Erro: $error'),
        ) ?? CircularProgressIndicator();
      },
    );
  }
}
```

**8. Registrar Dependências (`*_ui`):**
```dart
class SchoolModule extends AppModule {
  @override
  void registerDependencies(DependencyInjector di) {
    di.registerLazySingleton<SchoolRepository>(
      () => SchoolRepositoryClient(schoolService: di.get()),
    );

    di.registerLazySingleton<GetAllUseCase>(
      () => GetAllUseCase(repository: di.get()),
    );

    di.registerLazySingleton<SchoolViewModel>(
      () => SchoolViewModel(getAllUseCase: di.get()),
    );
  }
}
```

---

## Melhores Práticas

### Camada de Domínio
- ✅ Mantenha entidades imutáveis (use `copyWith`).
- ✅ Use objetos de valor para conceitos de domínio (ColorValue, etc.).
- ✅ Interfaces de repositório definem contratos, não implementações.
- ✅ Use `Result<T>` para operações que podem falhar.

### Casos de Uso
- ✅ Um caso de uso por operação de negócio.
- ✅ Princípio da Responsabilidade Única.
- ✅ Nenhuma lógica de UI nos casos de uso.
- ✅ Fácil de testar com repositórios mockados.

### ViewModels
- ✅ Use Comandos para operações assíncronas.
- ✅ Estenda `ChangeNotifier` ou `BaseCRUDViewModel`.
- ✅ Chame `notifyListeners()` após mudanças de estado.
- ✅ Injete casos de uso, não repositórios.

### Repositórios
- ✅ Implementação do servidor usa consultas ao banco de dados.
- ✅ Implementação do cliente usa serviços HTTP.
- ✅ Ambos implementam a mesma interface.
- ✅ Retorne `Result<T>` para tratamento de erros.

### UI
- ✅ Use `ListenableBuilder` ou `ValueListenableBuilder`.
- ✅ Trate os estados de carregamento, sucesso e erro.
- ✅ Mantenha os widgets pequenos e focados.
- ✅ Use layouts responsivos (mobile/tablet/desktop).

---

## Conclusão

Esta arquitetura fornece:
- 🎯 **Separação clara de responsabilidades** - cada camada tem um propósito específico.
- 🔄 **Reutilização de código** - lógica de domínio compartilhada entre plataformas.
- 🧪 **Testabilidade** - camada de domínio em Dart puro, fácil de mockar.
- 📦 **Modularidade** - pacotes independentes e compostos.
- 🚀 **Escalabilidade** - fácil de adicionar novas funcionalidades seguindo padrões estabelecidos.

**Princípios Fundamentais:**
1. **Dependa de abstrações, não de concreções** (Interfaces de Repositório).
2. **Lógica de negócio nos casos de uso** (não em ViewModels ou Repositórios).
3. **Responsabilidade Única** (uma classe, uma função).
4. **DRY** (Don't Repeat Yourself - compartilhe código via `*_shared`).
5. **KISS** (Keep It Simple, Stupid - evite o excesso de engenharia).

Para dúvidas ou melhorias, consulte CLAUDE.md ou PROGRESS.md.