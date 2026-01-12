# Project Context

## Purpose

O **EMS System (EduMigSoft System)** é um sistema de gestão modular desenvolvido em Flutter/Dart, organizado como monorepo. O objetivo principal é fornecer uma plataforma integrada para gerenciar:

- **Users**: Gestão de usuários e autenticação
- **Aura (Tasks)**: Sistema de gerenciamento de tarefas
- **Projects**: Gestão de projetos com tarefas e controle financeiro associado
- **Finance**: Gestão de receitas e despesas

O sistema é projetado para suportar tanto aplicações Flutter (mobile/web) quanto backend em Dart/Shelf, com máximo compartilhamento de código através de uma arquitetura multi-variante.

## Tech Stack

### Frontend
- **Flutter** `>=3.0.0` (mobile/web apps)
- **Dart** `>=3.10.4`
- **Material Design 3** (design system)

### Backend
- **Dart/Shelf** (servidor HTTP planejado)
- **Pure Dart** para lógica de negócio

### Ferramentas de Desenvolvimento
- `dart format` - Formatação de código
- `dart analyze` / `flutter analyze` - Análise estática
- `dart test` / `flutter test` - Testes
- Scripts shell para automação (`./scripts/`)

### Dependências Principais

#### Core/Shared (Pure Dart)
- `meta: ^1.17.0` - Annotations para código Dart
- `zard: ^0.0.25` - Validação de dados (formulários e entidades)
- `get_it: ^9.2.0` - Service Locator / Dependency Injection
- `logging: ^1.3.0` - Sistema de logging
- `path: ^1.9.1` - Manipulação de paths

#### Server (Backend)
- `shelf: ^1.4.2` / `shelf_router: ^1.1.4` - Framework HTTP
- `drift: ^2.30.0` / `drift_postgres: ^1.3.1` - ORM para banco de dados
- `postgres: ^3.5.9` - Driver PostgreSQL
- `dart_jsonwebtoken: ^3.3.1` - JWT para autenticação
- `bcrypt: ^1.2.0` / `pointycastle: 4.0.0` - Criptografia

#### UI (Flutter)
- `cupertino_icons` - Ícones iOS
- `path_provider: ^2.1.5` - Acesso a diretórios do sistema

#### Dev Dependencies
- `flutter_lints: ^6.0.0` / `lints: ^6.0.0` - Linting
- `test: ^1.29.0` / `flutter_test` - Testes
- `build_runner: 2.10.4` - Code generation

## Project Conventions

### Code Style

- Seguir [Effective Dart Guidelines](https://dart.dev/guides/language/effective-dart)
- **Formatação**: Executar `dart format .` antes de cada commit
- **Análise**: Zero warnings em `dart analyze` / `flutter analyze`
- **Nomenclatura**:
  - `snake_case` para arquivos, diretórios, chaves de configuração e chaves de mapas/json
  - `PascalCase` para classes e enums
  - `camelCase` para variáveis, funções e métodos
  - Prefixo `_` para membros privados
  - Sufixo `Config` para classes de configuração (ex: `DSThemeConfig`)

### Architecture Patterns

#### Multi-Variant Package Pattern

Todos os pacotes seguem uma estrutura de **4 variantes**:

```
packages/{package_name}/
├── {package}_shared/    # Pure Dart (zero dependências Flutter)
├── {package}_ui/        # Flutter widgets e UI components
├── {package}_client/    # Lógica client-side
└── {package}_server/    # Lógica server-side (Dart/Shelf)
```

**Princípios da Arquitetura:**

1. **Shared Layer é Pure Dart**: `*_shared` contém ZERO dependências Flutter
   - Apenas `meta: ^1.17.0`
   - Define models, value objects e configurações como PODOs
   - Totalmente serializável (JSON) para comunicação API

2. **Direção de Dependências** (em camadas):
   ```
   *_ui     → *_shared
   *_client → *_shared
   *_server → *_shared
   ```
   Sem dependências horizontais entre variantes.

3. **Configuration as Data**: Conceitos de domínio representados como data classes serializáveis
   - Transmissível via API backend ↔ frontend
   - Persistível em bancos de dados
   - Suporta padrões Server-Driven UI
   - Configuração dinâmica sem mudanças de código

4. **Value Object Pattern**: Para conceitos de domínio (cores, moedas, etc.)
   - Imutável
   - Métodos de serialização (`toMap`/`fromMap`)
   - Equality baseada em valor
   - Factory constructors para criação

#### Exemplo de Referência: Design System

Ver `packages/design_system/` para implementação madura do padrão:
- `ColorValue`: Value object para cores (ARGB int32, framework-agnostic)
- `DSThemeConfig`: Configuração de tema como data class
- `DSTheme`: Conversão de config para `ThemeData` do Flutter

### Testing Strategy

- **Cobertura mínima**: 80% de code coverage
- **Estrutura**: Testes em `test/` espelham estrutura de `lib/`
- **Tipos de teste**:
  - Unit tests para lógica de negócio
  - Widget tests para componentes UI
  - Mocks quando apropriado
- **Execução**: `dart test` ou `flutter test`
- **Restrição**: Não usar testes automatizados em projetos pequenos/simples (conforme princípios de clean code)

### Architectural Decision Records (ADRs)

Decisões arquiteturais documentadas em `docs/adr/`:

1. **ADR-0001**: Result Pattern para tratamento de erros
2. **ADR-0002**: Dio Error Handler Mixin para HTTP client
3. **ADR-0003**: Base Repository Pattern para acesso a dados
4. **ADR-0004**: Form Validation Mixin com Zard
5. **ADR-0005**: Standard Package Structure (4 variantes)
6. **ADR-0006**: Base Details Sync para sincronização de dados

### Git Workflow

#### Convenção de Commits

Usar [Conventional Commits](https://www.conventionalcommits.org/) em **inglês**:

```
feat: add new authentication feature
fix: resolve login button crash
docs: update README with setup instructions
test: add unit tests for user service
refactor: simplify profile page logic
```

**Tipos de commit:**
- `feat:` - Nova funcionalidade
- `fix:` - Correção de bug
- `docs:` - Documentação
- `style:` - Formatação (sem mudanças de lógica)
- `refactor:` - Refatoração de código
- `test:` - Adição ou modificação de testes
- `chore:` - Tarefas de manutenção

#### Branching

- `main` - Branch principal, código estável
- `feature/{name}` - Desenvolvimento de features
- `fix/{name}` - Correções de bugs

#### Pull Requests

- Mínimo 1 aprovação necessária
- CI/CD deve passar
- Code coverage não deve diminuir

## Domain Context

### Módulos de Negócio

1. **Users** - Gestão de usuários
2. **Aura (Tasks)** - Sistema de tarefas pessoais/profissionais
3. **Projects** - Gestão de projetos com:
   - Tarefas vinculadas ao projeto
   - Controle financeiro específico do projeto
   - **Nota**: Não utiliza o módulo Finance global
4. **Finance** - Gestão financeira global:
   - Receitas (income)
   - Despesas (expenses)
   - **Separado** do financeiro de projetos
5. **Auth** - Gestão de autenticação e autorização (planejado)

### Configurações como Dados

O sistema trata temas, localizações e outras configurações como **dados transmissíveis**:
- Backend pode enviar configurações de tema via API
- Frontend renderiza UI baseado em configurações recebidas
- Suporta multi-tenancy e personalização por cliente

### Design System

- Sistema de design baseado em Material 3
- Tokens de design: `DSSpacing`, `DSRadius`, `DSPaddings`, `DSShadows`
- Temas pré-definidos: Default, BlueGray, Acqua, Lolo, Teal
- Componentes: `DSCard`, `DSInfoCard`, `DSActionCard`

## Important Constraints

### Técnicas

1. **Zero Flutter em Shared**: Camada `*_shared` NUNCA pode ter dependências Flutter
2. **Análise Estrita**:
   - `strict-casts`, `strict-inference`, `strict-raw-types` habilitados
   - Arquivos gerados excluídos: `**/*.g.dart`, `**/*.freezed.dart`, `**/*.mocks.dart`
3. **Versões Mínimas**:
   - Flutter SDK: `>=3.0.0`
   - Dart SDK: `>=3.10.4`

### Organizacionais

- **Monorepo**: Todo código em um único repositório
- **Documentação**: Todas as classes e métodos públicos devem ser documentados com `///`
- **Idioma**:
  - Código, commits e documentação técnica em **inglês**
  - Documentação de usuário (README, CONTRIBUTING) em **português brasileiro**
  - Interaction Plans, Tasks e Walkthroughs em **português brasileiro**

### Clean Code Principles

- Projetos pequenos e simples privilegiam código claro sobre testes automatizados
- Evitar over-engineering
- Preferir soluções simples e diretas

## External Dependencies

### Atuais

- **Dart Pub**: Gerenciamento de pacotes
- **Flutter SDK**: Framework de UI
- **Material Design Icons**: `cupertino_icons` para ícones
- **PostgreSQL**: Banco de dados relacional (via Drift ORM)
- **JWT**: Autenticação via tokens
- **API Generation**: OpenAPI/Swagger (pacote `open_api`)
- **i18n**: Flutter localizations (pacote `localizations`)

### Planejadas

- **CI/CD**: GitHub Actions ou similar
- **Container**: Docker (diretório `containers/` preparado)

### Scripts de Automação

Disponíveis em `./scripts/`:

#### Manutenção
- `pub_get_all.sh` - Instala dependências em todos os pacotes
- `clean_all.sh` - Remove build artifacts
- `build_runner_all.sh` - Executa build_runner em todos os pacotes
- `dart_fix_all.sh` - Aplica dart fix em todos os pacotes

#### Validação
- `check_documentation.sh` - Verifica documentação de classes/métodos públicos
- `validate_architecture.sh` - Valida estrutura de pacotes conforme ADR-0005

#### Geração de Código
- `generators/` - Scripts para geração de novas features:
  - Estrutura completa de pacotes (4 variantes)
  - Models, repositories, use cases
  - View models, telas e widgets
  - Validadores com Zard

## Packages Structure

### Pacotes Implementados

| Pacote | Status | Descrição |
|--------|--------|--------|
| `core` | ✅ Ativo | Infraestrutura compartilhada (shared, ui, client, server) |
| `design_system` | ✅ Ativo | Sistema de design com tokens e componentes |
| `localizations` | ✅ Ativo | Internacionalização |
| `open_api` | ✅ Ativo | Geração de API OpenAPI/Swagger |
| `images` | 🔄 Estruturado | Assets de imagens |
