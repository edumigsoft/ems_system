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
- `meta: ^1.17.0` - Annotations para código Dart
- `cupertino_icons` - Ícones iOS
- `flutter_lints: ^6.0.0` - Linting para Flutter
- `package:lints` - Linting para Dart puro

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

### Planejadas

- **Database**: PostgreSQL ou similar (para backend)
- **API Generation**: OpenAPI/Swagger (pacote `open_api`)
- **i18n**: Flutter localizations (pacote `localizations`)
- **CI/CD**: GitHub Actions ou similar
- **Container**: Docker (configurações em `containers/`)
- **Auth**: Autenticação e autorização
- **Core**: Códigos compartilhados
- **Images**: Imagens do sistema

### Scripts de Automação

Disponíveis em `./scripts/`:
- `pub_get_all.sh` - Instala dependências em todos os pacotes
- `clean_all.sh` - Remove build artifacts
- `build_runner_all.sh` - Executa build_runner em todos os pacotes
- `dart_fix_all.sh` - Aplica dart fix em todos os pacotes
- Planejado scripts para:
    - new feature;
    - etc;
