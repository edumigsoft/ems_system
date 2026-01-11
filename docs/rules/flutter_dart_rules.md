# Flutter & Dart Rules for EduMigSoft (EMS System)

Este documento consolida as regras oficiais do [Flutter AI Rules](https://raw.githubusercontent.com/flutter/flutter/refs/heads/master/docs/rules/rules.md), adaptadas para o contexto do **EMS System**.

> **Fonte Oficial**: Baseado nas diretrizes de engenharia do Google para Flutter.

---

## 1. Arquitetura e Organização

### Separation of Concerns (O "Great Schism")
*   **Separation of Concerns**: Organize o projeto em camadas lógicas claras:
    *   **Presentation**: Widgets, Screens, ViewModels (`*_ui`).
    *   **Domain**: Entidades, Interfaces de Repositório, Use Cases (`*_core`).
    *   **Data**: DTOs, Implementação de Repositórios, Data Sources (`*_client` ou `*_server`).
*   **Feature-based Organization**: Mantenha tudo relacionado a uma feature junto (ex: `packages/core` contém ui, core, client e server).
*   **Estrutura de Pacotes**: Siga **rigorosamente** o padrão definido em `docs/adr/0005-standard-package-structure.md`.

### 1.1. Estrutura Interna de Pacotes

Cada tipo de pacote segue uma estrutura específica. Consulte **ADR-0005** para detalhes completos.

#### Pacotes Core (Domain/Data)

```
lib/src/
  domain/              # Camada de domínio (regras de negócio)
    entities/          # Objetos de domínio com identidade
    repositories/      # Interfaces/contratos
    use_cases/         # Casos de uso
  data/                # Camada de dados (implementações)
    models/            # DTOs
    repositories/      # Implementações concretas
  validators/          # Validações (Zard)
  constants/           # Constantes
  extensions/          # Extensions
```

**Princípios:**
- Domain **nunca** depende de Data
- Domain deve ser **pure Dart** (zero dependências de Flutter ou framework)
- Use Cases são a **única entrada** para ViewModels

#### Pacotes UI (Presentation)

```
lib/ui/
  pages/              # Telas/Páginas
  view_models/        # ViewModels (MVVM)
  widgets/            # Widgets reutilizáveis
```

**Princípios:**
- UI **nunca** importa `_server`
- ViewModels usam **Use Cases**, não Repositories diretamente
- Widgets devem ser **imutáveis** (`const` constructors quando possível)

> **Referência Completa**: `docs/adr/0005-standard-package-structure.md`

### API Design Principles
*   **Consider the User**: Desenhe APIs (pacotes, classes) pensando em quem vai consumir. Se é difícil de usar, está errado.
*   **Documentation**: Todo pacote deve ter um `README.md` e métodos públicos devem ter DartDoc (`///`).

---

## 2. Dart Best Practices

### Code Style & Safety
*   **Null Safety**: Escreva código *soundly null-safe*. Evite `!` (bang operator) a menos que a não-nulidade seja garantida logicamente.
*   **Async/Await**:
    *   Use `Future` para operações únicas.
    *   Use `Stream` para sequências de eventos assíncronos.
*   **Pattern Matching**: Use `switch` expressions e destructuring sempre que simplificar a lógica.
*   **Records**: Prefira Records `(double x, double y)` ao invés de criar classes DTO descartáveis para retornos múltiplos simples.

### Tratamento de Erros

> **PADRÃO OBRIGATÓRIO**: Use `Result<T>` para todas as operações que podem falhar.

*   **Result Pattern**: Adotamos o padrão `Result<T>` (tipo soma com `Success<T>` e `Failure<T>`) para tratamento explícito de erros.
*   **Onde Usar**:
    *   **Repositórios**: TODOS os métodos de repository DEVEM retornar `Result<T>`
    *   **Use Cases**: TODOS os use cases DEVEM retornar `Result<T>`
    *   **ViewModels**: Devem consumir `Result<T>` dos use cases e reagir adequadamente
*   **Evite `try-catch` na UI**: O tratamento de exceções deve ocorrer nas camadas inferiores (Data/Domain)
*   **Pattern Matching**: Use `switch` ou `when()` para lidar com casos de sucesso/falha

**Exemplo**:
```dart
// Repository
Future<Result<FinanceDetails>> create(FinanceCreate data) async {
  try {
    final response = await _api.create(data);
    return Success(response);
  } on DioException catch (e) {
    return Failure(handleDioError(e));
  }
}

// ViewModel
final result = await _createUseCase(data);
switch (result) {
  case Success<FinanceDetails>(:final value):
    _items.add(value);
    notifyListeners();
  case Failure<FinanceDetails>(:final error):
    _errorMessage = error.toString();
    notifyListeners();
}
```

> **Referência Completa**: [ADR-0001: Padrão Result para Tratamento de Erros](../adr/0001-use-result-pattern-for-error-handling.md)

### Validação de Formulários

> **PADRÃO OBRIGATÓRIO**: Use `Zard` para validação declarativa e `FormValidationMixin` em ViewModels.

*   **Validators Zard**: Validação declarativa de DTOs no `*_core/validators/`
*   **Onde Usar**:
    *   **Validators**: TODOS os DTOs de entrada (Create/Update) DEVEM ter validators Zard
    *   **FormValidationMixin**: ViewModels que lidam com formulários DEVEM usar o mixin
    *   **Validação em camadas**: UI (feedback imediato), UseCase (segurança), Server (nunca confiar no client)
*   **Pattern Matching**: Use `if (!validate(_validator, data))` para validar antes de processar
*   **Mensagens consistentes**: Validators garantem mensagens padronizadas em toda a aplicação

**Exemplo**:
```dart
// Validator (em *_core/validators/)
class FinanceCreateValidator extends Validator<FinanceCreate> {
  @override
  ValidationResult validate(FinanceCreate value) {
    final errors = <ValidationError>[];
    
    if (value.name.length < 3) {
      errors.add(ValidationError(
        field: 'name',
        message: 'Nome deve ter no mínimo 3 caracteres',
      ));
    }
    
    return ValidationResult(errors);
  }
}

// ViewModel (em *_ui/view_models/)
class FinanceFormViewModel extends ChangeNotifier 
    with FormValidationMixin {
  
  final CreateFinanceUseCase _createUseCase;
  final FinanceCreateValidator _validator;
  
  Future<void> submit(FinanceCreate data) async {
    // Validar usando FormValidationMixin
    if (!validate(_validator, data)) {
      return; // Erros já foram setados no mixin
    }
    
    // Prosseguir com lógica de negócio
    final result = await _createUseCase(data);
    switch (result) {
      case Success(:final value):
        clearErrors();
      case Failure(:final error):
        setFieldError('form', error.toString());
    }
  }
}
```

> **Referência Completa**: [ADR-0004: FormValidationMixin e Zard](../adr/0004-use-form-validation-mixin-and-zard.md)

### Serialização JSON e DTOs

> **REGRA DE OURO**: Entidades de Domínio (`_core/domain/entities`) devem ser **PURAS**.
> 
> *   **NÃO** implemente `fromJson` ou `toJson` nas Entidades.
> *   **NÃO** dependa de `dart:convert` ou pacotes de serialização no Domínio.

*   **Responsabilidade de Serialização**: A serialização deve ocorrer exclusivamente nas camadas de interface (API/DB), usando **Models** (DTOs) ou **Details** (Persistência).
*   **Padrão de Mapeamento**:
    1.  Recebe JSON da API.
    2.  Converte JSON -> `MyModel` (DTO com `fromJson`).
    3.  Converte `MyModel` -> `MyEntity` (usando mappers ou factory `toDomain`).
    4.  Usa `MyEntity` na lógica de negócio.
*   **Exemplo Correto**:

**Entidade Pura** (Domain) - SEM `id`, SEM serialização:
```dart
class Subject {
  final String name;
  final String code;

  const Subject({required this.name, required this.code});
  
  // Apenas lógica de domínio
  bool get isValidCode => code.length >= 3;
}
```

**Details** (Agregação com metadados de persistência):
```dart
import 'package:core_shared/core_shared.dart';

class SubjectDetails implements BaseDetails {
  @override
  final String id;
  @override
  final bool isDeleted;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;   // Non-nullable
  @override
  final DateTime updatedAt;   // Non-nullable
  
  final Subject data;
  
  SubjectDetails({
    required this.id,
    this.isDeleted = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required String name,
    required String code,
  }) : data = Subject(name: name, code: code);
  
  // Getters de conveniência
  String get name => data.name;
  String get code => data.code;
}
```

**Model** (Serialização):
```dart
class SubjectDetailsModel {
  final SubjectDetails entity;

  SubjectDetailsModel(this.entity);

  factory SubjectDetailsModel.fromJson(Map<String, dynamic> json) {
    return SubjectDetailsModel(
      SubjectDetails(
        id: json['id'] as String,
        isDeleted: json['is_deleted'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        name: json['name'] as String,
        code: json['code'] as String,
      ),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': entity.id,
    'is_deleted': entity.isDeleted,
    'is_active': entity.isActive,
    'created_at': entity.createdAt.toIso8601String(),
    'updated_at': entity.updatedAt.toIso8601String(),
    'name': entity.name,
    'code': entity.code,
  };

  SubjectDetails toDomain() => entity;
  
  factory SubjectDetailsModel.fromDomain(SubjectDetails details) =>
      SubjectDetailsModel(details);
}
```

> [!IMPORTANT]
> **Padrão Completo Entity/Details/DTOs**
> 
> - **Entity**: Domínio puro (SEM `id`, SEM serialização)
> - **EntityDetails**: Implementa `BaseDetails` (COM `id` e metadados)
> - **EntityCreate**: DTO para criação (sem `id`)
> - **EntityUpdate**: DTO para atualização (com `id` required, campos opcionais)
> - **Models**: Classes `*Model` para serialização JSON
> 
> Para detalhes completos, consulte:
> - [Padrões Arquiteturais](../architecture/architecture_patterns.md)
> - [Padrões de Entities](../architecture/entity_patterns.md)
> - [ADR-0006: Sincronização BaseDetails](../adr/0006-base-details-sync.md)

### Documentation & Comments
*   **No Redundant Comments**: Nunca escreva comentários que apenas repetem o código.
    *   **Errado**: `final int x = 0; // esta é a variavel x`
    *   **Correto**: `// Contagem de tentativas de login falhas.`
*   **Docstrings (///)**: Use `///` para documentar **todos** os membros públicos (Classes, Métodos, Enums).
    *   Siga o padrão: Resumo na primeira linha, pula uma linha, detalhes depois.


### Linting
*   O projeto deve ter um `analysis_options.yaml` na raiz.
*   **Regra de Ouro**: Warnings do linter devem ser tratados como Erros.

---

## 3. Flutter Best Practices

### Performance de Build
*   **Immutability**: Widgets devem ser *profundamente* imutáveis (`const` constructors).
*   **Composition**: Prefira compor widgets pequenos a herdar widgets grandes.
*   **Build Method**: O método `build()` deve ser **puro** e rápido. Nunca faça chamadas de API ou cálculos pesados dentro dele.
    *   Extraia widgets complexos para classes privadas (`class _MySubWidget`) ao invés de métodos helpers (`_buildWidget()`).

### State Management
*   **Simplicidade**: Prefira soluções nativas quando possível.
    *   `ValueNotifier` para estados locais simples.
    *   `ChangeNotifier` (com `ListenableBuilder`) para estados mais complexos/compartilhados.
*   **Evite Bloat**: Não adicione bibliotecas pesadas de terceiros (como BLoC ou Redux) a menos que estritamente necessário. *Adotamos ViewModel + ChangeNotifier*.

---

## 4. Visual Design & Theming (Design System)

### Material 3 & Theme Extensions
*   **ThemeData**: Use `ColorScheme.fromSeed()` para gerar paletas harmoniosas.
*   **Design Tokens**: **Não** use cores ou estilos "hardcoded" nos widgets.
    *   **Correto**: `Theme.of(context).extension<MyColors>()!.success`
    *   **Errado**: `Colors.green`
*   **Component Themes**: Centralize a customização de componentes (ex: `CardTheme`, `InputDecorationTheme`) no `design_system`.

> [!IMPORTANT]
> **Guia Completo de Design System**
> 
> Para regras detalhadas sobre uso de tipografia, cores, spacing e componentes, consulte o [Guia de Uso do Design System](../architecture/design_system_guide.md).

### Layout
*   **Responsividade**: Use `LayoutBuilder` ou `MediaQuery` para decisões de layout, não valores de pixel fixos.
*   **Flexibilidade**: Use `Flexible` e `Expanded` para layouts que se adaptam ao tamanho da tela, evitando Overflow errors.

---

## 5. Navegação e Rotas

> **Adaptação**: O guia original sugere `go_router`, mas para este projeto adotamos a estratégia **Nativa Modular**.

*   **Native Navigation**: Use `Navigator` (v1/v2) nativo.
*   **Named Routes**: Use rotas nomeadas (`/finance/details`) definidas em contratos constantes (`AppRoutes` no `core_shared`).
*   **Deep Linking**: Se necessário, suporte deep links via configuração nativa do Android/iOS mapeando para rotas nomeadas.

---

## 6. Testing

*   **Tipos de Teste**:
    *   **Unit Tests**: Para lógica de negócio (`*_core` e ViewModels). Use `package:test`.
    *   **Widget Tests**: Para garantir que a UI renderiza o estado correto. Use `package:flutter_test`.
    *   **Integration Tests**: Para fluxos completos do usuário.
*   **Assertions**: Use `package:checks` ou `matcher` para asserções legíveis.

---

## 7. Acessibilidade (A11y)

*   **Semantics**: Use `Semantics` para elementos customizados que não têm descrição nativa.
*   **Contraste**: Garanta contraste mínimo de 4.5:1 em textos.
*   **Scalabilidade**: A UI **deve** quebrar graciosamente se o usuário aumentar a fonte do sistema (não use alturas fixas em textos).

---

## 8. Scripts & Tooling (Automação)

*   **Docstring Generation**: Use o comando `dart doc .` para gerar a documentação HTML do pacote.
    *   Certifique-se de que não há warnings de "undocumented member" em APIs públicas.
*   **Test Coverage**:
    *   Execute: `flutter test --coverage`
    *   Visualize: `genhtml coverage/lcov.info -o coverage/html`
    *   **Regra**: Não comite código com regressão de cobertura injustificada.

### Validação e Robustez
*   **Globs e Caminhos**: Ao criar scripts, configurações ou prompts:
    *   **Valide** os globs/paths com base na árvore real do repositório. Se um padrão não encontrar arquivos, o script deve alertar ou falhar.
    *   **Resumo**: Mostre os arquivos encontrados no resumo da execução para confirmação visual.
*   **Ambiguidade**: Diante de configurações ou cenários ambíguos:
    *   Proponha e use **Defaults Sensatos** (o caminho mais provável/padrão).
    *   Registre obrigatoriamente um **TODO** ou Warning no output/código para revisão humana futura.

## 9. Métricas de Aceitação (KPIs de Qualidade)

Para considerar uma feature "Bem Feita", ela deve atingir:

1.  **Cobertura de Testes**:
    *   **Core (Domain/UseCases)**: Mínimo **90%**.
    *   **Client/Server (Data)**: Mínimo **80%**.
    *   **UI (Widgets)**: Mínimo **50%** (foco em widgets complexos).
2.  **Complexidade Ciclomática**: Mantenha métodos abaixo de 10. Se passar disso, quebre em métodos menores.
3.  **Manutenibilidade**: 0 Warnings no `dart analyze`.
4.  **Documentação**: 100% dos membros públicos documentados.

> **Nota sobre Testes de Integração**: Embora opcionais para features pequenas, eles são **Obrigatórios** para fluxos críticos (Login, Checkout, Matrícula). Use `integration_test` para validar o "Caminho Feliz" desses fluxos.

