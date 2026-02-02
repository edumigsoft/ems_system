# Prompt Template: Implementação de Nova Feature

**Instruções de Uso**:
1.  Substitua `{{FEATURE_NAME}}` pelo nome da sua feature (ex: `library`, `finance`, `calendar`).
2.  Copie todo o conteúdo abaixo da linha "---" e envie para o seu Assistente de IA.
3.  Certifique-se de que o Assistente tem contexto dos arquivos `docs/rules/flutter_dart_rules.md`.

---

**Role**: Você é um Arquiteto de Software Sênior especializado em Flutter e Dart.
**Objetivo**: Implementar uma nova feature chamada **`{{FEATURE_NAME}}`** no monorepo *EMS System*.

## 0. Interação Inicial (OBRIGATÓRIO)

Antes de gerar qualquer código, você **DEVE** realizar as seguintes ações:

1.  **Confirmar o Nome da Feature**: Pergunte ao usuário se o nome da feature está correto (ex: "Você informou que o nome da feature é `{{FEATURE_NAME}}`. Confirma?").
2.  **Verificar Diretório e Branch**:
    *   Verifique se está na raiz do monorepo.
    *   Solicite ao usuário que confirme se está na branch correta: `feature/{{FEATURE_NAME}}`.
    *   Se não estiver, peça para executar: `git checkout -b feature/{{FEATURE_NAME}}`.
    *   **CRÍTICO**: Se o diretório ou branch estiverem incorretos, **NÃO PROSSIGA**. Falhe a tarefa imediatamente.

## 1. Contexto Arquitetural (The Great Schism Refined)

Você **DEVE** seguir estritamente a arquitetura "Great Schism". A feature será composta por 4 pacotes isolados em `packages/{{FEATURE_NAME}}/`:

| Pacote | Sufixo | Responsabilidade | Dependências Permitidas | Dependências Proibidas |
| :--- | :--- | :--- | :--- | :--- |
| **Domain & Business** | `_core` | Entidades, DTOs, Interfaces de Repository, UseCases, Validators. | `core_shared`, `drift` (annotation), `zard`, `open_api`, `meta` | UI, Shelf, Dio, Implementações Concretas |
| **HTTP Client** | `_client` | Implementação dos repositórios consumindo API via `Dio`. | `{{FEATURE_NAME}}_core`, `core_client`, `core_shared`, `dio`, `retrofit` | `shelf`, `drift` (runtime), UI, `html` |
| **Backend/Server** | `_server` | Tabelas DB (`Drift`), Handlers API (`Shelf`), Implementação de Data Sources. | `{{FEATURE_NAME}}_core`, `core_server`, `core_shared`, `shelf`, `drift` | UI (`flutter`), `dio`, `html` |
| **Presentation** | `_ui` | Telas, Widgets, ViewModels, Navegação (`AppModule`). | `{{FEATURE_NAME}}_client` (dev), `{{FEATURE_NAME}}_core`, `core_ui`, `system_ui`, `design_system`, `core_shared` | **DANGER**: `_server`, `drift`, `shelf` |

## 2. Padrões de Implementação (Reference: `core` package)

### 2.1. Injeção de Dependência & Navegação (`_ui`)
Ao contrário de versões anteriores, **NÃO** use mapas de rotas estáticos. Use o padrão `AppModule`:

1.  Crie `packages/{{FEATURE_NAME}}/{{FEATURE_NAME}}_ui/lib/{{FEATURE_NAME}}_module.dart`.
2.  A classe deve estender `AppModule` (de `core_ui`).
3.  Implemente `registerDependencies(DependencyInjector di)` para registrar:
    - Services
    - Repositories (Use `_client` por padrão no frontend)
    - UseCases (Obrigatório: UseCases devem ser a única entrada para os ViewModels)
    - ViewModels
    - Pages
4.  Implemente os getters de navegação (`navRailsDestination`, `botNavDestination`, `widgetDestinationViews`).
5.  **Rotas**: As rotas devem ser constantes definidas no `AppRoutes` (ou local no módulo se privado), nunca Strings mágicas.
6.  **Navegação Hierárquica (Submenus)**:
    - Use a propriedade `children` em `AppNavigationItem` para criar submenus.
    - Itens pai podem ter `route: null` (apenas agrupadores) ou uma rota própria.
    - Use `defaultExpanded: true` se o submenu deve iniciar aberto.
    
    ```dart
    AppNavigationItem(
      labelBuilder: (context) => 'Menu Pai',
      icon: Icons.folder,
      section: AppNavigationSection.finance,
      children: [
        AppNavigationItem(
          labelBuilder: (context) => 'Item Filho',
          icon: Icons.file_copy,
          route: '/rota-filho',
        ),
      ],
    )
    ```

### 2.2. Backend & Database (`_server`)
- **Conexão de Banco de Dados**: O módulo `_server` **NUNCA** deve criar sua própria conexão física com o banco de dados.
    - Ele deve receber o `QueryExecutor` ou usar o singleton `DatabaseProvider` do `core_server`.
    - Exemplo: `MyFeatureDatabase() : super(DatabaseProvider().executor);`
- **Tabelas Drift**: Defina as tabelas Drift no `_server`, mas mantenha as Entidades puras no `_core` (se usar conversão) ou use as classes geradas pelo Drift como DTOs internas.

#### ⚠️ **CRÍTICO: Campos DateTime em Drift Tables**
**SEMPRE** que a entidade tiver campos `DateTime`, você **DEVE** usar `DateTimeConverter` na tabela Drift:

```dart
import 'package:core_shared/core_shared.dart' show DateTimeConverter;

class MyTable extends Table {
  // ✅ CORRETO: DateTime com converter
  TextColumn get createdAt => text().map(const DateTimeConverter())();
  TextColumn get updatedAt => text().map(const DateTimeConverter())();
  
  // ❌ ERRADO: DateTime sem converter (causará erro de tipo)
  TextColumn get createdAt => text()(); // ERRO!
}
```

**Por quê?** 
- PostgreSQL armazena datas como TEXT (ISO 8601)
- Dart entidade usa tipo `DateTime`
- `DateTimeConverter` faz a conversão TEXT ↔ DateTime

#### ⚠️ **CRÍTICO: Padrão de Entidades para Persistência (Details Classes)**

**REGRA OBRIGATÓRIA**: Quando usar `DriftTableMixinPostgres` com `@UseRowClass`, as entidades **DEVEM** seguir o padrão `*Details`.

##### Conceito: Duas Camadas de Entidades

O sistema usa **separação clara** entre domínio e persistência:

1. **Entidades de Domínio** (`_core/src/domain/entities/`):
   - Representam conceitos puros de negócio
   - Contêm **apenas** campos relevantes ao domínio
   - **NÃO** incluem campos de infraestrutura (`createdAt`, `isDeleted`, etc.)
   - Exemplos: `Core`, `User`

2. **Entidades de Persistência** (sufixo `Details` em `_core/src/domain/entities/`):
   - Usadas com `@UseRowClass` em tabelas Drift
   - Incluem **TODOS** os campos do `DriftTableMixinPostgres`
   - Mantêm referência à entidade de domínio via propriedade `data`
   - Exemplos: `UserDetails`

##### Campos Obrigatórios do `DriftTableMixinPostgres`

Toda classe `*Details` **DEVE** ter estes campos:

```dart
String id;              // UUID (gerado automaticamente pelo banco)
bool isDeleted;         // Soft delete flag (padrão: false)
bool isActive;          // Status ativo/inativo (padrão: true)
DateTime? createdAt;    // Data de criação (auto no banco)
DateTime? updatedAt;    // Data de atualização (auto no banco)
```

##### Exemplo Completo: User vs UserDetails

**Entidade de Domínio** (`user.dart`):
```dart
// packages/user/user_core/lib/src/domain/entities/user.dart
class User {
  final String? id;
  final String name;
  
  const User({this.id, required this.name});
  
  // NENHUMA serialização aqui! Entidade Pura.
}
```

**Entidade de Persistência** (`user_details.dart`):
```dart
// packages/user/user_core/lib/src/domain/entities/user_details.dart
import 'package:open_api/open_api.dart';
import 'user.dart';

@apiModel
@Model(name: 'UserDetails', description: 'Detalhes de persistência de um Usuário.')
class UserDetails {
  @Property(description: 'id', required: true)
  final String id;
  @Property(description: 'is_deleted', required: true)
  final bool isDeleted;
  @Property(description: 'is_active', required: true)
  final bool isActive;
  @Property(description: 'created_at', required: false)
  final DateTime? createdAt;
  @Property(description: 'updated_at', required: false)
  final DateTime? updatedAt;
  @Property(description: 'User', required: true, ref: 'User')
  final User data;

  UserDetails({
    required this.id,
    required this.isDeleted,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    required String name,
  }) : data = User(id: id, name: name);

  // Expor campos de domínio via getters
  String get name => data.name;

  // Serialização APENAS porque é usada pelo Drift/Server ou API de admin
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_deleted': isDeleted,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'name': data.name, // Flattening para simplificar
    };
  }
  
  // Converter Drift Row -> Details
  factory UserDetails.fromJson(Map<String, dynamic> json) {
     return UserDetails(
      id: json['id'] as String,
      isDeleted: json['is_deleted'] as bool,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      name: json['name'] as String,
    );
  }
}
```

**Uso na Tabela Drift** (`user_table.dart`):
```dart
// packages/user/user_server/lib/src/database/tables/user_table.dart
import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart' show DriftTableMixinPostgres;
import 'package:user_core/user_core.dart'
    show UserDetails;

@UseRowClass(UserDetails)  // ✅ CORRETO: Usa Details
class UserTable extends Table with DriftTableMixinPostgres {
  @override
  String get tableName => 'users';
  
  TextColumn get name => text()();
  // id, createdAt, updatedAt, isDeleted, isActive vêm do mixin
}
```

##### Por Que Não Usar a Entidade de Domínio Diretamente?

❌ **Errado** (causará erros de compilação no Drift):
```dart
@UseRowClass(User)  // ❌ ERRO: faltam campos do mixin
class UserTable extends Table with DriftTableMixinPostgres {
  // ...
}
```

**Erro Resultante**:
```
Error: Type 'User' not found.
Parameter must accept bool (isDeleted)
Parameter must accept bool (isActive)
```

**Motivo**: O Drift espera que a classe usada em `@UseRowClass` tenha **TODOS** os campos da tabela, incluindo os herdados do `DriftTableMixinPostgres`.

##### Quando Criar Details Classes

**SEMPRE** que:
- Usar `DriftTableMixinPostgres` na tabela Drift
- A tabela será persistida no banco de dados
- Precisar dos campos de auditoria (`createdAt`, `updatedAt`, `isDeleted`, `isActive`)

**Referências no Código**:
- `packages/user/user_core/lib/src/domain/entities/user_details.dart`

#### ⚠️ **CRÍTICO: Conversores de Tipos Customizados (Enums)**

**REGRA**: Para usar enums em tabelas Drift, você **DEVE** criar um `TypeConverter`.

##### Quando Criar Conversores

- **Enums** → `int` (converte para índice do enum)
- **Lista de enums** → `String` (converte para CSV ou JSON)
- **Tipos customizados** não suportados nativamente pelo Drift

##### Exemplo: Conversor de Enum para Int

**1. Criar Conversor** (`_core/src/domain/converters/`):

```dart
// packages/user/user_core/lib/src/domain/converters/user_type_converter.dart
import 'package:drift/drift.dart';
import '../entities/user.dart';

class UserTypeConverter extends TypeConverter<UserType, int> {
  const UserTypeConverter();
  
  @override
  UserType fromSql(int fromDb) {
    // Validação para evitar crashes
    if (fromDb < 0 || fromDb >= UserType.values.length) {
      return UserType.elementarySchoolI; // valor padrão
    }
    return UserType.values[fromDb];
  }
  
  @override
  int toSql(UserType fromDart) {
    return fromDart.index;
  }
}
```

**2. Aplicar Conversor na Tabela**:

```dart
// packages/user/user_server/lib/src/database/tables/user_table.dart
import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart' show DriftTableMixinPostgres;
import 'package:user_core/user_core.dart'
    show UserDetails, UserTypeConverter;

@UseRowClass(UserDetails)
class UserTable extends Table with DriftTableMixinPostgres {
  @override
  String get tableName => 'users';
  
  TextColumn get name => text()();
  IntColumn get userType => integer().map(const UserTypeConverter())();  // ✅ Aplica conversor
  IntColumn get order => integer()();
}
```

**3. A Entidade Details Deve Aceitar o Enum**:

```dart
class UserDetails {
  final String id;
  final bool isDeleted;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User data;

  UserDetails({
    required this.id,
    required this.isDeleted,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    required String name,
    required UserType userType,  // ✅ Tipo enum Dart
    required int order,
  }) : data = User(
        id: id,
        name: name,
        userType: userType,
        order: order,
      );
}
```

##### Exemplo: Conversor de Lista de Enums para String

**Referência**: `packages/user/user_core/lib/src/domain/converters/user_roles_converter.dart`

```dart
class UserRolesListConverter extends TypeConverter<List<UserRoles>, String> {
  const UserRolesListConverter();

  @override
  List<UserRoles> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    
    final List<String> labels = fromDb.split(',');
    return labels.map((label) {
      return UserRoles.values.firstWhere(
        (e) => e.label == label,
        orElse: () => UserRoles.none,
      );
    }).toList();
  }

  @override
  String toSql(List<UserRoles> fromDart) {
    return fromDart.map((e) => e.label).join(',');
  }
}
```

##### Checklist para Conversores

- [ ] Criar conversor em `_core/src/domain/converters/`
- [ ] Estender `TypeConverter<TipoDart, TipoBanco>`
- [ ] Implementar `fromSql()` com validação
- [ ] Implementar `toSql()`
- [ ] Aplicar conversor na coluna: `.map(const MeuConverter())`
- [ ] Garantir que a entidade Details aceita o tipo Dart correto
- [ ] Exportar conversor no barrel file do `_core`

**Referências**:
- Conversor de enum: `packages/finance/finance_core/lib/src/domain/converters/education_level_converter.dart`
- Conversor de lista: `packages/finance/finance_core/lib/src/domain/converters/user_roles_converter.dart`


### 2.3. Interface do Usuário (`_ui`)
- Use **`ResponsiveLayout`** (de `core_ui`) para orquestrar layouts (Mobile, Tablet, Desktop).
- **Design System** (`design_system`):
    - **NUNCA** use estilos hardcoded ou cores manuais (`Colors.red`).
    - Use `AppThemeFactory` e tokens do tema via `context.theme`.
    - Use componentes do DS: `DSButton`, `DSCard`, `DSTextField`, etc.

### 2.4. **REGRAS OBRIGATÓRIAS CRÍTICAS** ⚠️

> **ATENÇÃO**: Estas regras são **OBRIGATÓRIAS** e devem ser seguidas sem exceção. Violação de qualquer uma delas resulta em tarefa incompleta.

#### 1. **ZERO Linters Pendentes**
- **NUNCA** considere uma tarefa completa se houver linters pendentes (warnings ou errors)
- Execute `dart analyze` ou `flutter analyze` em **TODOS** os pacotes da feature
- Resultado obrigatório: **0 issues found** em todos os pacotes (_core, _client, _server, _ui)
- Se houver dificuldade para resolver um linter específico: **PERGUNTE AO USUÁRIO**

#### 2. **Localização Completa**
- Ao adicionar chaves de localização em `packages/localizations_ui/lib/localization/app_pt.arb`:
  - **SEMPRE** execute `flutter gen-l10n` em `packages/localizations_ui`
  - **SEMPRE** execute `flutter pub get` no app que usa as localizações
  - Verifique que o getter foi gerado corretamente antes de usar

#### 3. **Tomada de Decisão**
- **SEMPRE** pergunte ao usuário quando estiver em dúvida sobre:
  - Qual abordagem técnica usar
  - Como resolver um linter complexo
  - Estrutura de dados ou arquitetura
  - Naming conventions específicos
  - **NUNCA** assuma ou tome decisões importantes sem consultar

#### 4. **Ordem de Implementação** (Obrigatório ADR-0005)
Implementar pacotes **NESTA ORDEM EXATA**:
1. `_core` → validar (0 linters)
2. `_client` → validar (0 linters)
3. `_server` → validar (0 linters)
4. `_ui` → validar (0 linters)

**NÃO** prosseguir para o próximo pacote sem validar o anterior.

### 2.5. Documentação & OpenAPI
- **DTOs**: Todas as classes de Request/Response em `_core` acessadas pela API devem ter a anotação `@Schema()` do pacote `open_api`.
- **Controllers**: Todos os métodos de Controllers em `_server` devem ter anotações `@Route`, `@Operation`, `@ApiResponse` para gerar o Swagger corretamente.

### 2.6. Arquivos Obrigatórios de Documentação

Siga a **hierarquia de documentação** definida no ADR-0005. A documentação é organizada em dois níveis:

#### Nível 1: Raiz da Feature (`packages/{{FEATURE_NAME}}/`)

**Arquivos obrigatórios** na raiz da feature:

- ✅ **README.md**: Visão geral da feature completa
  - Descrição da feature e seus 4 módulos (_core, _client, _server, _ui)
  - Arquitetura geral (diagrama opcional)
  - Links para README de cada subpacote
  - Como executar testes da feature completa
  
- ✅ **CONTRIBUTING.md**: Guia de contribuição da feature
  - Como contribuir em qualquer pacote desta feature
  - Padrões específicos de código da feature
  - Convenções de commit
  - Como executar testes
  - **IMPORTANTE**: Este arquivo É ÚNICO por feature, NÃO criar nos subpacotes

- ✅ **CHANGELOG.md**: Histórico agregado da feature
  - Documenta mudanças gerais que afetam múltiplos subpacotes
  - Seguir formato [Keep a Changelog](https://keepachangelog.com/)
  - Linkar para CHANGELOGs dos subpacotes quando relevante

#### Nível 2: Subpacotes (`packages/{{FEATURE_NAME}}/{{FEATURE_NAME}}_{{type}}/`)

**Arquivos obrigatórios** em CADA subpacote (_core, _client, _server, _ui):

- ✅ **README.md**: Documentação específica do pacote
  - Objetivo e responsabilidade do pacote
  - Como usar/importar o pacote
  - Exemplos de código (se aplicável)
  - Dependências principais
  - API pública do pacote

- ✅ **CHANGELOG.md**: Histórico de mudanças do pacote
  - Seguir formato [Keep a Changelog](https://keepachangelog.com/)
  - Formato: `## [version] - YYYY-MM-DD`
  - Categorias: Added, Changed, Deprecated, Removed, Fixed, Security
  - Essencial para versionamento independente

- ✅ **pubspec.yaml**: Configuração do pacote Dart (criado automaticamente)
  - Dependências
  - Metadados (name, version, description)

- ✅ **analysis_options.yaml**: Configurações de linting (⚠️ **REGRA OBRIGATÓRIA**)
  - **Pacotes Dart** (_core, _server, _client): DEVEM importar `analysis_options_dart.yaml`:
    ```yaml
    include: ../../../analysis_options_dart.yaml
    ```
  - **Pacotes Flutter** (_ui): DEVEM importar `analysis_options_flutter.yaml`:
    ```yaml
    include: ../../../analysis_options_flutter.yaml
    ```
  - Podem adicionar customizações específicas abaixo da importação
  - Nunca duplicar regras que já estão nos arquivos da raiz

#### Estrutura Completa de Exemplo

```
packages/{{FEATURE_NAME}}/
  ├── README.md                    # Visão geral da feature
  ├── CONTRIBUTING.md              # Guia de contribuição (ÚNICO)
  ├── {{FEATURE_NAME}}_core/
  │   ├── README.md                # Específico do core
  │   ├── CHANGELOG.md             # Versões do core
  │   ├── pubspec.yaml
  │   ├── analysis_options.yaml
  │   └── lib/...
  ├── {{FEATURE_NAME}}_client/
  │   ├── README.md
  │   ├── CHANGELOG.md
  │   ├── pubspec.yaml
  │   ├── analysis_options.yaml
  │   └── lib/...
  ├── {{FEATURE_NAME}}_server/
  │   ├── README.md
  │   ├── CHANGELOG.md
  │   ├── pubspec.yaml
  │   ├── analysis_options.yaml
  │   └── lib/...
  └── {{FEATURE_NAME}}_ui/
      ├── README.md
      ├── CHANGELOG.md
      ├── pubspec.yaml
      ├── analysis_options.yaml
      └── lib/...
```

> **Referência Completa**: `docs/adr/0005-standard-package-structure.md` seção "Arquivos de Documentação"

### 2.7. Nomenclatura de Rotas

**Regra Obrigatória**: As rotas de navegação (`routeName`) em módulos **DEVEM** usar apenas o nome do pacote/feature, **NÃO** o path completo da estrutura de diretórios.

#### ✅ Correto:

```dart
// packages/finance/finance_ui/lib/finance_module.dart
class FinanceModule extends AppModule {
  static const String routeName = '/finance';  // ✅ Apenas o nome da feature
}

// packages/user/user_ui/lib/user_module.dart  
class UserModule extends AppModule {
  static const String routeName = '/user';   // ✅ Simples e direto
}
```

#### ❌ Incorreto:

```dart
// ❌ NÃO usar path completo de diretórios
static const String routeName = '/finance/finance';
static const String routeName = '/finance/finances';
static const String routeName = '/packages/user/users';
```

#### Justificativa:

1. **Simplicidade**: Rotas devem ser amigáveis e fáceis de lembrar
2. **Desacoplamento**: A estrutura de diretórios é uma decisão de organização interna, não deve vazar para a API pública
3. **Manutenção**: Se a estrutura de diretórios mudar, as rotas não precisam mudar
4. **Consistência**: Todos os módulos seguem o mesmo padrão: `/{feature_plural}`

#### Padrão de Nomenclatura:

- Use plural do nome da entidade principal: `/users`, `/finances`
- Se a feature tiver múltiplas rotas, use prefixo curto: `/activities`, `/areas`
- Mantenha lowercase e use hífens para palavras compostas: `/finance`

#### Rotas de API (Endpoints):

**Regra Obrigatória**: As rotas da API (Retrofit/Shelf) **DEVEM** usar apenas o nome da entidade/feature (preferencialmente plural), **NÃO** o path completo da estrutura de diretórios.

✅ **Correto**:
- `/finances`
- `/users`

❌ **Incorreto**:
- `/finance/finances`
- `/user/users`

**Motivo**: A API deve ser agnóstica à estrutura de pastas do projeto.

### 2.8. Estrutura Interna dos Pacotes

Siga rigorosamente a estrutura definida no **ADR-0005** (`docs/adr/0005-standard-package-structure.md`).

#### Pacote Core (`{{FEATURE_NAME}}_core`)

```
lib/
  src/
    domain/              # Camada de domínio (core business logic)
      entities/          # Objetos de domínio
      repositories/      # Interfaces de repositórios
      use_cases/         # Casos de uso/regras de negócio
    data/                # Camada de dados (implementações)
      models/            # DTOs e modelos de dados
      repositories/      # Implementações (se necessário)
    validators/          # Validações (Zard schemas)
    constants/           # Constantes de domínio
    extensions/          # Extensions da feature
    enums/              # Enumerações
```

**Onde colocar cada arquivo:**
- **Entidades de domínio** → `domain/entities/`
- **Interfaces de repositórios** → `domain/repositories/`
- **Use cases** → `domain/use_cases/`
- **DTOs/Models** → `data/models/`
- **Validators (Zard)** → `validators/`
- **Constantes** → `constants/`

#### Pacote Client (`{{FEATURE_NAME}}_client`)

```
lib/
  src/
    repositories/        # Implementações HTTP (Dio/Retrofit)
    services/           # Serviços API
```

#### Pacote Server (`{{FEATURE_NAME}}_server`)

```
lib/
  src/
    database/           # Tabelas Drift
    handlers/           # Handlers Shelf/API
    repositories/       # Implementações server-side
```

#### Pacote UI (`{{FEATURE_NAME}}_ui`)

```
lib/
  ui/
    pages/              # Páginas/Telas
    view_models/        # ViewModels
    widgets/            # Widgets reutilizáveis
```

> **Referência Completa**: Consulte `docs/adr/0005-standard-package-structure.md` para variações aceitas e exemplos detalhados.

### 2.9. Validação de Formulários (FormValidationMixin)

**IMPORTANTE**: O projeto usa um padrão **Dual Interface** para validação de formulários que isola completamente a biblioteca Zard.

#### Arquitetura de Validação

```
*_shared (Dart Puro)
  └─ FeatureValidator extends CoreValidator<T>
      ├─ schema (static ZMap) ← Para FormValidationMixin (UI)
      └─ validate(T) → CoreValidationResult ← Para UseCases/backend

core_ui (Camada de Abstração)
  └─ FormValidationMixin
      ├─ Gerencia TextEditingControllers
      ├─ Gerencia erros por campo
      ├─ Gerencia dirty/touched state
      └─ submitForm() com validação integrada

*_ui (ViewModels + Widgets)
  └─ ViewModel with FormValidationMixin
      └─ NUNCA importa zard diretamente
```

#### Template de Validador (`*_shared`)

**Localização**: `packages/{{FEATURE_NAME}}/{{FEATURE_NAME}}_core/lib/src/validators/{{entity}}_validator.dart`

```dart
import 'package:core_shared/core_shared.dart';
import 'package:zard/zard.dart';
import '../domain/entities/{{entity}}_details.dart';

// Constantes de campos (compartilhadas)
const String {{entity}}NameField = 'name';
const String {{entity}}EmailField = 'email';
// ... outros campos

class {{Entity}}Validator extends CoreValidator<{{Entity}}Details> {
  const {{Entity}}Validator();

  /// Schema Zard para validação de UI e backend
  /// Este schema é usado por FormValidationMixin
  static final schema = z.map({
    {{entity}}NameField: z.string().min(1, message: 'Nome obrigatório'),
    {{entity}}EmailField: z.string().email(message: 'Email inválido'),
    // ... outras validações
  });

  /// Método validate para UseCases e backend
  @override
  CoreValidationResult validate({{Entity}}Details value) {
    final data = {
      {{entity}}NameField: value.name,
      {{entity}}EmailField: value.email,
      // ... outros campos
    };

    final result = schema.safeParse(data);

    if (result.success) {
      return CoreValidationResult.success();
    } else {
      final errors = <CoreValidationError>[];
      for (final issue in (result as dynamic).error.issues) {
        final path = (issue.path as List?)?.join('.') ?? 'unknown';
        errors.add(CoreValidationError(
          field: path,
          message: issue.message,
        ));
      }
      return CoreValidationResult.failure(errors);
    }
  }
}
```

#### Template de ViewModel com FormValidationMixin (`*_ui`)

**Localização**: `packages/{{FEATURE_NAME}}/{{FEATURE_NAME}}_ui/lib/ui/view_models/{{entity}}_form_view_model.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_shared/core_shared.dart';
import 'package:{{feature_name}}_core/{{feature_name}}_core.dart';

/// ViewModel para formulário de criação/edição de {{Entity}}
class {{Entity}}FormViewModel extends ChangeNotifier with FormValidationMixin {
  final Create{{Entity}}UseCase _createUseCase;
  final Update{{Entity}}UseCase? _updateUseCase;
  final {{Entity}}Details? _initialData;

  bool get isEditMode => _initialData != null;

  {{Entity}}FormViewModel({
    required Create{{Entity}}UseCase createUseCase,
    Update{{Entity}}UseCase? updateUseCase,
    {{Entity}}Details? initialData,
  })  : _createUseCase = createUseCase,
        _updateUseCase = updateUseCase,
        _initialData = initialData {
    _initializeFields();
  }

  /// Registra campos do formulário
  void _initializeFields() {
    final data = _initialData;
    if (data != null) {
      // Modo edição: preenche com dados existentes
      registerField({{entity}}NameField, initialValue: data.name);
      registerField({{entity}}EmailField, initialValue: data.email);
      // ... outros campos
    } else {
      // Modo criação: campos vazios
      registerField({{entity}}NameField);
      registerField({{entity}}EmailField);
      // ... outros campos
    }
  }

  /// Submete o formulário com validação
  Future<Result<{{Entity}}Details>> submit() async {
    final formData = {
      {{entity}}NameField: getFieldValue({{entity}}NameField),
      {{entity}}EmailField: getFieldValue({{entity}}EmailField),
      // ... outros campos
    };

    return submitForm<{{Entity}}Details>(
      data: formData,
      schema: {{Entity}}Validator.schema,
      onValid: (validatedData) async {
        final entity = _createEntityFromData(validatedData);

        if (isEditMode) {
          if (_updateUseCase == null) {
            return Failure(Exception('Update use case não configurado'));
          }
          return await _updateUseCase!.execute(entity);
        } else {
          return await _createUseCase.execute(entity);
        }
      },
    );
  }

  /// Cria entidade a partir dos dados validados
  {{Entity}}Details _createEntityFromData(Map<String, dynamic> data) {
    return {{Entity}}Details(
      id: _initialData?.id ?? '',
      isDeleted: _initialData?.isDeleted ?? false,
      isActive: _initialData?.isActive ?? true,
      createdAt: _initialData?.createdAt,
      updatedAt: _initialData?.updatedAt,
      name: data[{{entity}}NameField] as String,
      email: data[{{entity}}EmailField] as String,
      // ... outros campos
    );
  }

  /// Reseta o formulário para valores iniciais
  void reset() {
    if (_initialData != null) {
      resetForm({
        {{entity}}NameField: _initialData!.name,
        {{entity}}EmailField: _initialData!.email,
        // ... outros campos
      });
    } else {
      resetForm();
    }
  }

  @override
  void dispose() {
    disposeFormResources(); // ← CRÍTICO: Liberar recursos
    super.dispose();
  }
}
```

#### Template de Widget de Formulário (`*_ui`)

**Localização**: `packages/{{FEATURE_NAME}}/{{FEATURE_NAME}}_ui/lib/ui/widgets/forms/{{entity}}_form_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart';
import 'package:{{feature_name}}_core/{{feature_name}}_core.dart';
import '../view_models/{{entity}}_form_view_model.dart';

class {{Entity}}FormWidget extends StatefulWidget {
  final Create{{Entity}}UseCase createUseCase;
  final Update{{Entity}}UseCase? updateUseCase;
  final {{Entity}}Details? initialData;
  final void Function({{Entity}}Details)? onSuccess;
  final void Function(Exception)? onError;

  const {{Entity}}FormWidget({
    Key? key,
    required this.createUseCase,
    this.updateUseCase,
    this.initialData,
    this.onSuccess,
    this.onError,
  }) : super(key: key);

  @override
  State<{{Entity}}FormWidget> createState() => _{{Entity}}FormWidgetState();
}

class _{{Entity}}FormWidgetState extends State<{{Entity}}FormWidget> {
  late {{Entity}}FormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = {{Entity}}FormViewModel(
      createUseCase: widget.createUseCase,
      updateUseCase: widget.updateUseCase,
      initialData: widget.initialData,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo Nome
            TextField(
              controller: _viewModel.registerField({{entity}}NameField),
              decoration: InputDecoration(
                labelText: 'Nome',
                errorText: _viewModel.getFieldError({{entity}}NameField),
              ),
            ),
            SizedBox(height: 16),

            // Campo Email
            TextField(
              controller: _viewModel.registerField({{entity}}EmailField),
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _viewModel.getFieldError({{entity}}EmailField),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24),

            // Botão Submit
            ElevatedButton(
              onPressed: _viewModel.isSubmitting
                  ? null
                  : (_viewModel.isFormValid && _viewModel.isFormDirty
                      ? _handleSubmit
                      : null),
              child: _viewModel.isSubmitting
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Salvando...'),
                      ],
                    )
                  : Text(_viewModel.isEditMode ? 'Atualizar' : 'Criar'),
            ),

            // Botão Reset (opcional)
            if (_viewModel.isFormDirty)
              TextButton(
                onPressed: _viewModel.reset,
                child: Text('Cancelar'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    final result = await _viewModel.submit();

    if (!mounted) return;

    if (result case Success(:final value)) {
      widget.onSuccess?.call(value);
    } else if (result case Failure(:final error)) {
      widget.onError?.call(error);
    }
  }
}
```

#### Métodos Disponíveis no FormValidationMixin

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `registerField(name, {initialValue})` | `TextEditingController` | Registra campo e retorna controller |
| `getFieldValue(name)` | `String` | Obtém valor atual do campo |
| `setFieldValue(name, value)` | `void` | Define valor programaticamente |
| `getFieldError(name)` | `String?` | Obtém erro de validação do campo |
| `setFieldError(name, error)` | `void` | Define erro manual |
| `clearErrors([name])` | `void` | Limpa erros (campo específico ou todos) |
| `validateForm({data, schema})` | `Result<Map>` | Valida sem submeter |
| `submitForm<T>({data, schema, onValid})` | `Future<Result<T>>` | Valida e submete |
| `resetForm([initialValues])` | `void` | Reseta formulário |
| `disposeFormResources()` | `void` | Libera recursos (chamar no dispose) |

#### Getters de Estado

| Getter | Tipo | Descrição |
|--------|------|-----------|
| `formErrors` | `Map<String, String?>` | Mapa de erros por campo |
| `isSubmitting` | `bool` | Formulário sendo submetido |
| `isValidating` | `bool` | Validação em andamento |
| `isFormDirty` | `bool` | Algum campo foi modificado |
| `hasErrors` | `bool` | Existem erros de validação |
| `isFormValid` | `bool` | Formulário válido (sem erros) |

#### Quando Usar Cada Abordagem

**Use CoreValidator.validate() quando:**
- ✅ Validar em **UseCases** (antes de persistir)
- ✅ Validar em **backend** (server-side)
- ✅ Validar em **testes unitários**
- ✅ Validação **sem UI**

**Use FormValidationMixin quando:**
- ✅ Criar/editar **formulários Flutter**
- ✅ Precisar de **estado reativo** (dirty, errors, loading)
- ✅ Gerenciar **TextEditingControllers**
- ✅ Submit com **validação integrada**

#### Referências

- **Documentação Completa**: `docs/adr/0004-use-form-validation-mixin-and-zard.md`
- **Implementação**: `packages/core/core_ui/lib/core/mixins/form_validation_mixin.dart`
- **Exemplos de Referência**:
  - School: `packages/school/school_ui/lib/ui/view_models/school_form_view_model.dart`
  - Notebook: `packages/notebook/notebook_ui/lib/ui/view_models/notebook_form_view_model.dart`

> **IMPORTANTE**: O pacote `zard_form` está **DESCONTINUADO**. Use apenas FormValidationMixin para novos formulários.

## 3. Tarefas de Implementação

Gere o código passo a passo, solicitando validação a cada grande bloco:

1.  **Setup Inicial**: 
    - Criar pastas seguindo **ADR-0005**
    - Criar `pubspec.yaml` para `_core`, `_client`, `_server`, `_ui` com dependências corretas
    - **Nível Feature** (`packages/{{FEATURE_NAME}}/`):
      - Criar `README.md` com visão geral da feature
      - Criar `CONTRIBUTING.md` (ÚNICO arquivo para toda a feature)
      - Criar `CHANGELOG.md` (iniciar com `## [Unreleased]`)
    - **Nível Subpacotes** (cada `_core`, `_client`, `_server`, `_ui`):
      - Criar `README.md` específico do pacote
      - Criar `CHANGELOG.md` (iniciar com v0.1.0)
      - Criar `analysis_options.yaml` seguindo **REGRA OBRIGATÓRIA**:
        - Dart packages: `include: ../../../analysis_options_dart.yaml`
        - Flutter packages: `include: ../../../analysis_options_flutter.yaml`
2.  **Core Domain**:
    - Definir Entidades em `domain/entities/`
    - Definir Interfaces de Repositórios em `domain/repositories/` (**OBRIGATÓRIO: retornar `Result<T>`**)
    - Criar Use Cases em `domain/use_cases/` (**OBRIGATÓRIO: retornar `Result<T>`**)
    - Definir DTOs em `data/models/` (`json_serializable`, `@Schema`)
    - Criar Validators em `validators/` seguindo padrão **Dual Interface** (ver seção 2.9):
      - Schema estático para FormValidationMixin (UI)
      - Método `validate()` para UseCases/backend
      - Constantes de campos compartilhadas
    
    **Exemplo de Repository Interface**:
    ```dart
    // packages/{{FEATURE_NAME}}/{{FEATURE_NAME}}_core/lib/src/domain/repositories/{{entity}}_repository.dart
    import 'package:core_shared/core_shared.dart';
    import '../entities/{{entity}}_details.dart';
    import '../dtos/{{entity}}_create.dart';
    import '../dtos/{{entity}}_update.dart';
    
    abstract class {{Entity}}Repository {
      Future<Result<{{Entity}}Details>> create({{Entity}}Create data);
      Future<Result<{{Entity}}Details>> getById(String id);
      Future<Result<List<{{Entity}}Details>>> getAll();
      Future<Result<{{Entity}}Details>> update({{Entity}}Update data);
      Future<Result<void>> delete(String id);
    }
    ```
    
    **Exemplo de Use Case**:
    ```dart
    // packages/{{FEATURE_NAME}}/{{FEATURE_NAME}}_core/lib/src/domain/use_cases/get_all_{{entity}}_use_case.dart
    import 'package:core_shared/core_shared.dart';
    import '../entities/{{entity}}_details.dart';
    import '../repositories/{{entity}}_repository.dart';
    
    class GetAll{{Entity}}UseCase {
      final {{Entity}}Repository _repository;
      
      GetAll{{Entity}}UseCase(this._repository);
      
      Future<Result<List<{{Entity}}Details>>> call() async {
        return await _repository.getAll();
      }
    }
    ```
    
    > **Referência**: [ADR-0001: Padrão Result](../adr/0001-use-result-pattern-for-error-handling.md)
3.  **Server Implementation**:
    - Implementar Tabelas em `database/` (`Drift`) usando `DatabaseProvider`
    - Implementar Handlers em `handlers/` (`Shelf`, `open_api`)
4.  **Client Implementation**: 
    - Implementar Repositórios em `repositories/` (`Retrofit/Dio`) **COM Result Pattern**
    - Implementar Serviços em `services/`
    
    **Exemplo de Repository Implementation**:
    ```dart
    // packages/{{FEATURE_NAME}}/{{FEATURE_NAME}}_client/lib/src/repositories/{{entity}}_repository_impl.dart
    import 'package:core_shared/core_shared.dart';
    import 'package:{{feature_name}}_core/{{feature_name}}_core.dart';
    import 'package:dio/dio.dart';
    import '../services/{{entity}}_api_service.dart';
    
    class {{Entity}}RepositoryImpl implements {{Entity}}Repository {
      final {{Entity}}ApiService _api;
      
      {{Entity}}RepositoryImpl(this._api);
      
      @override
      Future<Result<List<{{Entity}}Details>>> getAll() async {
        try {
          final response = await _api.getAll();
          final entities = response.map((model) => model.toDomain()).toList();
          return Success(entities);
        } on DioException catch (e) {
          return Failure(handleDioError(e));
        } catch (e) {
          return Failure(Exception('Erro inesperado: $e'));
        }
      }
      
      @override
      Future<Result<{{Entity}}Details>> create({{Entity}}Create data) async {
        try {
          final model = {{Entity}}CreateModel.fromDomain(data);
          final response = await _api.create(model.toJson());
          return Success(response.toDomain());
        } on DioException catch (e) {
          return Failure(handleDioError(e));
        } catch (e) {
          return Failure(Exception('Erro ao criar: $e'));
        }
      }
    }
    ```
5.  **UI Foundation**: 
    - Criar `{{FEATURE_NAME}}Module.dart` e registrar rotas
    - Estruturar `ui/pages/`, `ui/view_models/`, `ui/widgets/`
6.  **UI Screens**:
    - Criar Telas seguindo **Responsive Layout** e **Design System**
    - Criar ViewModels seguindo padrão MVVM **COM Result Pattern**
    - Para formulários: usar **FormValidationMixin** (ver seção 2.9 para templates completos)
    
    **Exemplo de ViewModel**:
    ```dart
    // packages/{{FEATURE_NAME}}/{{FEATURE_NAME}}_ui/lib/ui/view_models/{{entity}}_view_model.dart
    import 'package:flutter/foundation.dart';
    import 'package:{{feature_name}}_core/{{feature_name}}_core.dart';
    
    class {{Entity}}ViewModel extends ChangeNotifier {
      final GetAll{{Entity}}UseCase _getAllUseCase;
      final Create{{Entity}}UseCase _createUseCase;
      
      List<{{Entity}}Details> _items = [];
      String? _errorMessage;
      bool _isLoading = false;
      
      List<{{Entity}}Details> get items => _items;
      String? get errorMessage => _errorMessage;
      bool get isLoading => _isLoading;
      
      {{Entity}}ViewModel(this._getAllUseCase, this._createUseCase);
      
      Future<void> loadAll() async {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();
        
        final result = await _getAllUseCase();
        
        // Usando pattern matching
        switch (result) {
          case Success<List<{{Entity}}Details>>(:final value):
            _items = value;
          case Failure<List<{{Entity}}Details>>(:final error):
            _errorMessage = error.toString();
        }
        
        _isLoading = false;
        notifyListeners();
      }
      
      Future<void> create({{Entity}}Create data) async {
        _isLoading = true;
        notifyListeners();
        
        final result = await _createUseCase(data);
        
        // Usando .when()
        result.when(
          success: (entity) {
            _items.add(entity);
            _errorMessage = null;
          },
          failure: (error) {
            _errorMessage = 'Erro ao criar: ${error.toString()}';
          },
        );
        
        _isLoading = false;
        notifyListeners();
      }
    }
    ```

7.  **Integração com Aplicações** (dependendo dos pacotes criados):
    
    **App V1 (Cliente)** - Somente se tiver `_client` E `_ui`:
    - Adicionar `{{FEATURE_NAME}}_ui` como dependência em `apps/app_v1/pubspec.yaml`
    - Registrar `{{FeatureName}}Module` em `apps/app_v1/lib/config/di/injector.dart`
    - Adicionar chave de localização em `packages/localizations_ui/lib/localization/app_pt.arb`
    - **OBRIGATÓRIO**: Executar `flutter gen-l10n` em `packages/localizations_ui`
    - Executar `flutter pub get` em `apps/app_v1`
    - Validar `dart analyze` (0 errors) em `{{FEATURE_NAME}}_ui`
    
    **EMS Server V1 (Backend)** - Somente se tiver `_server`:
    - Adicionar `{{FEATURE_NAME}}_core` e `{{FEATURE_NAME}}_server` em `servers/server_v1/pubspec.yaml`
    - Criar `Init{{FeatureName}}ModuleToServer` no barrel export `{{FEATURE_NAME}}_server.dart`
    - Registrar em `servers/server_v1/lib/config/injector.dart`
    - Criar tabela no PostgreSQL com script SQL (incluir campos DriftTableMixinPostgres)
    - Executar `dart pub get` em `servers/server_v1`
    - Validar `dart analyze` (0 errors) em `{{FEATURE_NAME}}_server`

## 4. Definição de Concluído (DoD) - RÍGIDO

Para considerar a tarefa finalizada, você deve passar nas seguintes verificações:

1.  **Linting & Analysis** ⚠️ **OBRIGATÓRIO**:
    - Rodar `dart fix --apply` em todos os pacotes.
    - Rodar `dart analyze` ou `flutter analyze`. **Resultado OBRIGATÓRIO: 0 Warnings/Errors**.
    - **NUNCA** considere a tarefa concluída com linters pendentes.
    - Se em dúvida sobre como resolver um linter: **PERGUNTE AO USUÁRIO**.
2.  **Testes Automatizados (Coverage Metrics)**:
    - **Core**: Mínimo **90%** de cobertura (Lógica de negócio pura).
    - **Data (Client/Server)**: Mínimo **80%** de cobertura.
    - **UI**: Mínimo **50%** de cobertura (Widget Tests).
3.  **Documentação**:
    - Swagger UI deve exibir os endpoints da feature.
    - DartDoc: 100% dos membros públicos documentados.
4.  **Arquitetura**:
    - `_ui` não deve importar `_server`.
    - `_server` usa `DatabaseProvider`.
5.  **Integração**:
    - Se a feature tiver `_client` E `_ui`: verificar que está registrada em `apps/app_v1` e aparece no menu.
    - Se a feature tiver `_server`: verificar que está registrada em `servers/server_v1` e rotas respondem corretamente.

## 5. Erros Comuns e Como Evitá-los ⚠️

Esta seção documenta erros frequentes encontrados durante implementações de features. **Leia com atenção** antes de começar.

### 5.1. Erros em Models (`_core/src/data/models/`)

#### ❌ Erro: Campos Ausentes no `fromJson`

```dart
// ERRADO
factory DisciplineModel.fromJson(Map<String, dynamic> json) {
  return DisciplineModel(
    id: json['id'] as String?,
    name: json['name'] as String,
    // ❌ FALTANDO: isActive, isDeleted, createdAt, updatedAt
  );
}
```

**Consequência**: Erro de tipo ao tentar usar o model com API que retorna campos de auditoria.

#### ✅ Solução: Incluir TODOS os Campos

```dart
// CORRETO
factory DisciplineModel.fromJson(Map<String, dynamic> json) {
  return DisciplineModel(
    id: json['id'] as String?,
    name: json['name'] as String,
    isActive: json['is_active'] as bool,  // ✅
    isDeleted: json['is_deleted'] as bool,      // ✅
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
  );
}
```

#### ❌ Erro: Tipo de Retorno Incorreto em `toDomain()`

```dart
// ERRADO
KnowledgeArea toDomain() {  // ❌ Perde campos de auditoria
  return KnowledgeArea(id: id ?? '', name: name);
}
```

#### ✅ Solução: Retornar Entidade `*Details`

```dart
// CORRETO
KnowledgeAreaDetails toDomain() {  // ✅ Preserva todos os campos
  return KnowledgeAreaDetails(
    id: id ?? '',
    isDeleted: isDeleted,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
    name: name,
  );
}
```

### 5.2. Erros em Repositórios (`_client/src/repositories/`)

#### ❌ Erro: Valores Hardcoded

```dart
// ERRADO
Future<Result<DisciplineDetails>> create(Discipline entity) async {
  final model = DisciplineModel(
    name: entity.name,
    isActive: true,    // ❌ HARDCODED
    isDeleted: false,    // ❌ HARDCODED
  );
}
```

**Consequência**: Ignora valores da entidade, sempre força `isActive: true`.

#### ✅ Solução: Usar Valores da Entidade

```dart
// CORRETO
Future<Result<DisciplineDetails>> create(Discipline entity) async {
  final model = DisciplineModel(
    name: entity.name,
    isActive: entity.isActive,  // ✅ Do parâmetro
    isDeleted: entity.isDeleted,    // ✅ Do parâmetro
  );
}
```

### 5.3. Erros de Estrutura de Diretórios (`_ui/`)

#### ❌ Erro: Diretório `src/` Incorreto

```
lib/
├── my_module.dart
└── src/          ❌ NÃO usar src/ em pacotes UI
    └── ui/
```

#### ✅ Solução: Estrutura Correta

```
lib/
├── my_module.dart
└── ui/           ✅ Diretamente em lib/ui/
    ├── pages/
    ├── view_models/
    └── widgets/
```

**Referência**: `packages/user/user_ui/`

### 5.4. Erros de Configuração de Módulo

#### ❌ Erro: Parâmetro `backendUrl` Desnecessário

```dart
// ERRADO
class MyModule extends AppModule {
  final String backendUrl;  // ❌ Não use!
  
  MyModule({required this.di, required this.backendUrl});
}
```

**Problema**: O injector do app não tem `backendUrl` disponível.

#### ✅ Solução: Usar `baseUrl` do Dio

```dart
// CORRETO
class MyModule extends AppModule {
  MyModule({required this.di});  // ✅ Apenas DI
  
  @override
  void registerDependencies(DependencyInjector di) {
    di.registerLazySingleton<MyApiService>(
      () {
        final dio = di.get<Dio>();
        return MyApiService(
          dio,
          baseUrl: dio.options.baseUrl,  // ✅ Vem do Dio
        );
      },
    );
  }
}
```

### 5.5. Erros de Navegação

#### ❌ Erro: Item de Menu para Página Vazia

```dart
// ERRADO
List<AppNavigationItem> get navigationItems => [
  AppNavigationItem(
    label: 'Gerenciamento de Financeiro',
    route: '/finance',  // ❌ Página só mostra texto
  ),
  AppNavigationItem(
    label: 'Gerenciamento de Notas',
    route: '/notes',  // ✅ Página funcional
  ),
];
```

#### ✅ Solução: Apenas Itens Funcionais

```dart
// CORRETO
List<AppNavigationItem> get navigationItems => [
  // Removido item principal redundante
  AppNavigationItem(
    label: 'Gerenciamento Financeiro',
    route: '/finance',
  ),
  AppNavigationItem(
    label: 'Gerenciamento de Notas',
    route: '/notes',
  ),
];
```
