# Guia de Contribuição - Tag Feature

Este guia descreve como contribuir para a feature Tag do EMS System.

## Estrutura do Projeto

A feature Tag é composta por 4 pacotes independentes:

```
packages/project/tag/
├── tag_shared/      # Pure Dart - Domain & Business Logic
├── tag_client/      # HTTP Client (Retrofit/Dio)
├── tag_server/      # Backend (Drift/Shelf)
└── tag_ui/          # Flutter UI (MVVM)
```

## Fluxo de Desenvolvimento

### 1. Antes de Começar

- [ ] Certifique-se de estar na branch correta: `feature/tag` ou crie uma branch: `git checkout -b feature/tag-<descricao>`
- [ ] Execute `./scripts/pub_get_all.sh` para instalar dependências
- [ ] Leia a documentação em `docs/architecture/` e `docs/adr/`

### 2. Padrões de Código

#### Convenções de Nomenclatura

- **Classes**: PascalCase (`Tag`, `TagDetails`, `TagRepository`)
- **Arquivos**: snake_case (`tag_details.dart`, `tag_repository.dart`)
- **Variáveis/Funções**: camelCase (`createTag`, `tagName`)
- **Constantes**: lowerCamelCase (`tagConstants`, `maxTagNameLength`)

#### Estrutura de Entidades

Siga o padrão definido em `docs/architecture/entity_patterns.md`:

- **Entity** (tag.dart): Domínio puro, SEM id, SEM serialização
- **EntityDetails** (tag_details.dart): Implementa `BaseDetails`, compõe Entity
- **DTOs**: `TagCreate` (sem id), `TagUpdate` (id obrigatório, demais opcionais)
- **Models**: Responsáveis por serialização JSON

#### Result Pattern (OBRIGATÓRIO)

Todos os métodos de repositório e use cases **DEVEM** retornar `Result<T>`:

```dart
// ✅ Correto
Future<Result<TagDetails>> create(TagCreate data);
Future<Result<List<TagDetails>>> getAll();

// ❌ Incorreto
Future<TagDetails> create(TagCreate data);  // Não usa Result
```

Referência: [ADR-0001: Result Pattern](../../docs/adr/0001-use-result-pattern-for-error-handling.md)

### 3. Ordem de Implementação

**SEMPRE** seguir esta ordem:

1. `tag_shared` → validar (0 linters)
2. `tag_client` → validar (0 linters)
3. `tag_server` → validar (0 linters)
4. `tag_ui` → validar (0 linters)

**NÃO** prosseguir para o próximo pacote sem validar o anterior.

### 4. Checklist de Implementação

#### Para tag_shared

- [ ] Entity em `domain/entities/tag.dart` (pura, sem id)
- [ ] EntityDetails em `domain/entities/tag_details.dart` (implementa BaseDetails)
- [ ] DTOs em `domain/dtos/` (TagCreate, TagUpdate)
- [ ] Interface de repositório em `domain/repositories/tag_repository.dart`
- [ ] Use Cases em `domain/use_cases/`
- [ ] Models em `data/models/` (serialização)
- [ ] Validators em `validators/` (Zard)
- [ ] Barrel export em `tag_shared.dart`

#### Para tag_client

- [ ] API Service em `services/tag_api_service.dart` (Retrofit)
- [ ] Repository implementation em `repositories/tag_repository_impl.dart`
- [ ] Tratamento de `DioException` com Result Pattern
- [ ] Executar `dart run build_runner build`

#### Para tag_server

- [ ] Tabela Drift em `database/tables/tag_table.dart`
- [ ] Usar `@UseRowClass(TagDetails)`
- [ ] Aplicar `DriftTableMixinPostgres`
- [ ] Handlers em `handlers/tag_handler.dart` (Shelf)
- [ ] Anotações OpenAPI (`@Route`, `@Operation`)
- [ ] Script SQL para criar tabela

#### Para tag_ui

- [ ] Module em `tag_module.dart` (estender `AppModule`)
- [ ] ViewModels em `ui/view_models/` (MVVM com Result Pattern)
- [ ] Pages em `ui/pages/` (ResponsiveLayout)
- [ ] Widgets em `ui/widgets/` (usar Design System)
- [ ] Localização em `packages/localizations_ui/lib/localization/app_pt.arb`
- [ ] Executar `flutter gen-l10n` em `packages/localizations_ui`

### 5. Testes

#### Cobertura Mínima

- **tag_shared**: 90% (lógica de negócio)
- **tag_client**: 80% (data layer)
- **tag_server**: 80% (data layer)
- **tag_ui**: 50% (widget tests)

#### Executar Testes

```bash
# Pacote específico
cd packages/project/tag/tag_shared
dart test --coverage=coverage

# Gerar relatório de cobertura
dart pub global activate coverage
dart pub global run coverage:format_coverage \
  --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```

### 6. Validação (OBRIGATÓRIA)

Antes de considerar a tarefa completa:

```bash
# 1. Fix automático
dart fix --apply

# 2. Análise (DEVE resultar em 0 issues)
dart analyze  # ou flutter analyze para tag_ui

# 3. Formatação
dart format .

# 4. Testes
dart test  # ou flutter test para tag_ui
```

**⚠️ CRÍTICO**: Tarefa NÃO está completa se houver linters pendentes.

### 7. Commits

Siga [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: adicionar use case de criação de tag
fix: corrigir validação de nome de tag
docs: atualizar README com exemplos
refactor: simplificar lógica de filtro de tags
test: adicionar testes para TagValidator
chore: atualizar dependências
```

### 8. Pull Request

Antes de abrir PR:

- [ ] Todos os pacotes compilam sem erros
- [ ] Todos os testes passam
- [ ] `dart analyze` ou `flutter analyze` → 0 issues em TODOS os pacotes
- [ ] Documentação atualizada (README, CHANGELOG)
- [ ] Commits seguem Conventional Commits

Template de PR:

```markdown
## Descrição
[Descreva as mudanças implementadas]

## Tipo de Mudança
- [ ] Nova feature
- [ ] Bug fix
- [ ] Breaking change
- [ ] Documentação

## Checklist
- [ ] Código segue os padrões do projeto
- [ ] Testes adicionados/atualizados
- [ ] Documentação atualizada
- [ ] 0 linters pendentes
- [ ] Testes passando
```

## Dúvidas?

- Consulte `docs/architecture/` para padrões arquiteturais
- Consulte `docs/adr/` para decisões de arquitetura
- Veja exemplos em `packages/user/` (feature de referência)

## Referências

- [ADR-0001: Result Pattern](../../docs/adr/0001-use-result-pattern-for-error-handling.md)
- [ADR-0004: FormValidationMixin e Zard](../../docs/adr/0004-use-form-validation-mixin-and-zard.md)
- [ADR-0005: Standard Package Structure](../../docs/adr/0005-standard-package-structure.md)
- [Entity Patterns](../../docs/architecture/entity_patterns.md)
- [Architecture Patterns](../../docs/architecture/architecture_patterns.md)
