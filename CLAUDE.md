# CLAUDE.md

Este arquivo fornece orientações para o Claude Code (claude.ai/code) ao trabalhar com código neste repositório.

## Visão Geral do Projeto

EMS System (EduMigSoft System) é um monorepo Flutter/Dart multi-serviço para gerenciar usuários, tarefas (Aura), projetos e finanças. A arquitetura usa uma estrutura de pacotes multi-variante consistente que permite compartilhamento de código entre aplicativos Flutter e servidores backend Dart/Shelf.

**Versão Atual:** 1.0.0 (veja arquivo `VERSION`)

### Arquitetura Multi-Serviço

O sistema suporta múltiplos serviços independentes:
- **EMS (EduMigSoft)**: Sistema principal de gerenciamento educacional
  - App: `apps/ems/app_v1/` (produção) e `apps/ems/app_design_draft/` (demonstração)
  - Server: `servers/ems/server_v1/` (backend Dart/Shelf)

- **SMS (School Management System)**: Sistema de gerenciamento escolar
  - App: `apps/sms/app_v1/` (produção)
  - Server: `servers/sms/server_v1/` (backend Dart/Shelf)

Ambos compartilham:
- Pacotes comuns em `/packages`
- Infraestrutura de banco de dados PostgreSQL (`servers/containers/postgres/`)
- Configurações de análise e scripts de automação

## Comandos Comuns

### Gerenciamento de Pacotes

```bash
# Instalar dependências para todos os pacotes
./scripts/pub_get_all.sh

# Limpar todos os pacotes (remove .dart_tool, artefatos de build)
./scripts/clean_all.sh

# Executar build_runner em todos os pacotes que o usam
./scripts/build_runner_all.sh

# Aplicar dart fix em todos os pacotes
./scripts/dart_fix_all.sh
```

### Testes e Análise

```bash
# Executar testes em um pacote específico
cd packages/design_system/design_system_ui
flutter test

# Executar análise em um pacote específico
cd packages/design_system/design_system_shared
dart analyze

# Formatar código
dart format .
```

### Executando Aplicações

```bash
# App de demonstração do design system
cd apps/ems/app_design_draft
flutter pub get
flutter run

# App EMS (produção)
cd apps/ems/app_v1
flutter pub get
flutter run

# App SMS (produção)
cd apps/sms/app_v1
flutter pub get
flutter run
```

### Infraestrutura e Docker

```bash
# Validar arquitetura do projeto
./scripts/validate_architecture.sh

# Verificar completude da documentação
./scripts/check_documentation.sh

# Iniciar banco de dados PostgreSQL compartilhado
cd servers/containers/postgres
docker-compose up -d

# Executar servidor EMS
cd servers/ems/server_v1
dart run bin/server.dart

# Executar servidor SMS
cd servers/sms/server_v1
dart run bin/server.dart
```

**Nota:** Veja `servers/INFRASTRUCTURE.md` para detalhes completos sobre configuração Docker e infraestrutura.

## Arquitetura de Alto Nível

### Padrão de Pacotes Multi-Variante

O monorepo usa uma **estrutura de pacotes com 4 variantes** onde cada pacote é dividido em camadas específicas de plataforma:

```
packages/{package_name}/
├── {package}_shared/    # Dart puro, zero dependências Flutter
├── {package}_ui/        # Widgets Flutter e componentes de UI
├── {package}_client/    # Lógica do lado do cliente (atualmente mínima)
└── {package}_server/    # Lógica do lado do servidor para backend Dart/Shelf
```

**Princípios Arquiteturais Principais:**

1. **Camada Compartilhada é Dart Puro**: Pacotes `*_shared` contêm ZERO dependências Flutter. Eles usam apenas `meta: ^1.17.0` e definem modelos de domínio, objetos de valor e configuração como Plain Old Dart Objects (PODOs).

2. **Direção de Dependências (Em Camadas)**:
   ```
   *_ui     → *_shared
   *_client → *_shared
   *_server → *_shared
   ```
   Sem dependências horizontais entre variantes.

3. **Configuração como Dados**: Conceitos de domínio como temas são representados como classes de dados serializáveis (não singletons), permitindo:
   - Transmissão via API entre backend e frontend
   - Persistência em bancos de dados ou armazenamento local
   - Padrões de UI dirigida por servidor
   - Configuração dinâmica sem alterações de código

### Arquitetura do Design System

O pacote `design_system` demonstra a implementação deste padrão (atualmente com 2/4 variantes implementadas: _shared e _ui):

**design_system_shared** (Dart Puro):
- `ColorValue`: Objeto de valor de cor agnóstico a framework (ARGB int32)
  - Suporta `fromHex()`, `fromARGB()`, `toHex()`, `toCSSRGBA()`
  - Serializável via `toMap()` / `fromMap()`

- `DSThemeConfig`: Classe de dados de configuração de tema imutável
  - Contém `seedColor`, `cardBackground`, `cardBorder`, configurações de tipografia
  - Suporta padrão `copyWith()` para variações
  - Pode ser enviado via API ou persistido

- Presets de Tema: Configurações estáticas (`DefaultPreset`, `BlueGrayPreset`, `AcquaPreset`, `LoloPreset`, `TealPreset`)

- Design Tokens: Constantes para espaçamento, raio, paddings, sombras
  ```dart
  DSSpacing.xs, DSSpacing.small, DSSpacing.medium
  DSRadius.small, DSRadius.medium, DSRadius.large
  DSPaddings.extraSmall, DSPaddings.medium
  ```

**design_system_ui** (Flutter):
- `DSTheme`: Converte `DSThemeConfig` para `ThemeData` do Material 3
  - `DSTheme.fromConfig(config, brightness)` → `ThemeData`
  - `DSTheme.forPreset(DSThemeEnum.lolo, brightness)` → `ThemeData`

- Extensões:
  - `ColorValue.toColor()` ↔ `Color.toColorValue()`
  - `context.dsTheme`, `context.dsColors`, `context.dsTextStyles`

- Componentes: `DSCard`, `DSInfoCard`, `DSActionCard`

**Exemplo de Fluxo de Dados**:
```
Backend (design_system_server)
  → Gera DSThemeConfig
  → Envia via API como JSON

App Flutter (design_system_ui)
  → Recebe JSON
  → Deserializa para DSThemeConfig (fromMap)
  → Converte para ThemeData via DSTheme.fromConfig()
  → Renderiza UI com tema
```

### Opções de Análise

O projeto usa duas configurações de análise:

- **`analysis_options_dart.yaml`**: Para pacotes Dart puro (`*_shared`, `*_client`, `*_server`)
  - Usa `package:lints/recommended.yaml`
  - Aplica tipagem estrita: `strict-casts`, `strict-inference`, `strict-raw-types`
  - Regras específicas de servidor/API: `avoid_dynamic_calls`, `cancel_subscriptions`, `close_sinks`

- **`analysis_options_flutter.yaml`**: Para pacotes Flutter (`*_ui`, apps)
  - Usa `package:flutter_lints/flutter.yaml`
  - Regras específicas do Flutter: `use_key_in_widget_constructors`, `avoid_unnecessary_containers`
  - Regras de performance: `prefer_const_constructors_in_immutables`

Ambos excluem arquivos gerados: `**/*.g.dart`, `**/*.freezed.dart`, `**/*.mocks.dart`

## Organização de Pacotes

### Pacotes Completos (4/4 variantes)
Estes pacotes implementam todas as 4 variantes (_shared, _ui, _client, _server):
- `auth/` - Sistema de autenticação e autorização
- `core/` - Funcionalidade central compartilhada (Result pattern, error handling, base repositories)
- `notebook/` - Gerenciamento de notas/cadernos
- `school/` - Gerenciamento escolar
- `tag/` - Sistema de tags/etiquetas
- `user/` - Gerenciamento de usuários

### Pacotes Parciais (implementação em andamento)
- `design_system/` (2/4) - Design system com configurações de tema, valores de cor e componentes
  - ✓ `design_system_shared`, `design_system_ui`
  - ⚠ `design_system_client`, `design_system_server` (diretórios existem, sem pubspec.yaml)

- `localizations/` (3/4) - Sistema de internacionalização (i18n)
  - ✓ `localizations_shared`, `localizations_ui`, `localizations_server`
  - ⚠ `localizations_client` (diretório existe, sem pubspec.yaml)

- `open_api/` (2/4) - Definições e geração de código de API
  - ✓ `open_api_shared`, `open_api_server`
  - ⚠ `open_api_client`, `open_api_ui` (diretórios existem, sem pubspec.yaml)

- `images/` (1/4) - Gerenciamento de ativos de imagem
  - ✓ `images_ui`
  - ⚠ Outras variantes (diretórios existem, sem pubspec.yaml)

### Estrutura Especial: Pacote Project
O pacote `project/` tem uma estrutura hierárquica única:
```
packages/project/
├── project_core/          # Funcionalidade principal de projetos (2/4 variantes)
│   ├── project_core_shared/
│   ├── project_core_ui/
│   ├── project_core_client/  (diretório, sem pubspec.yaml)
│   └── project_core_server/  (diretório, sem pubspec.yaml)
├── project/               # Sub-feature (esqueleto)
└── task/                  # Sub-feature para tarefas (esqueleto)
```

### Pacotes Especiais
- `zard_form/` - Biblioteca standalone de validação de formulários
  - Não segue o padrão de 4 variantes
  - Usado em todo o sistema para validação de formulários
  - Depende de `zard: ^0.0.23`

### Aplicações
- `apps/ems/app_design_draft/` - App de demonstração do design system com troca dinâmica de tema
- `apps/ems/app_v1/` - Aplicação EMS em produção
- `apps/sms/app_v1/` - Aplicação SMS em produção

### Servidores Backend
- `servers/ems/server_v1/` - Servidor EMS (Dart/Shelf)
- `servers/sms/server_v1/` - Servidor SMS (Dart/Shelf)
- `servers/containers/postgres/` - Banco de dados PostgreSQL compartilhado (Docker)

## Diretrizes de Desenvolvimento

### Implementação de Novas Features

**IMPORTANTE:** Este projeto usa uma arquitetura chamada **"Great Schism Refined"** que divide cada feature em 4 pacotes isolados com responsabilidades claras.

Para implementar uma nova feature, **consulte o guia completo**:
- `docs/rules/new_feature.md` - Template detalhado passo a passo para implementação

**Resumo do processo:**

1. **Ordem de Implementação** (OBRIGATÓRIA - ADR-0005):
   ```
   1. {feature}_core    → Validar (0 linters)
   2. {feature}_client  → Validar (0 linters)
   3. {feature}_server  → Validar (0 linters)
   4. {feature}_ui      → Validar (0 linters)
   ```
   **NÃO** prosseguir para o próximo pacote sem validar o anterior.

2. **Estrutura de Cada Pacote:**

   **{feature}_core** (Domain & Business):
   ```
   lib/src/
   ├── domain/
   │   ├── entities/      # Entidades de domínio + {Entity}Details
   │   ├── repositories/  # Interfaces de repositórios (retornam Result<T>)
   │   └── use_cases/     # Casos de uso (retornam Result<T>)
   ├── data/
   │   └── models/        # DTOs com @Schema() para OpenAPI
   ├── validators/        # Validações Zard
   └── constants/         # Constantes de domínio
   ```

   **{feature}_client** (HTTP Client):
   ```
   lib/src/
   ├── repositories/      # Implementações com Dio/Retrofit + Result
   └── services/          # API services
   ```

   **{feature}_server** (Backend/DB):
   ```
   lib/src/
   ├── database/          # Tabelas Drift
   ├── handlers/          # Handlers Shelf/API
   └── repositories/      # Implementações server-side
   ```

   **{feature}_ui** (Presentation):
   ```
   lib/
   ├── {feature}_module.dart  # AppModule com DI e navegação
   └── ui/
       ├── pages/         # Telas
       ├── view_models/   # ViewModels (MVVM)
       └── widgets/       # Widgets reutilizáveis
   ```

3. **Padrões Obrigatórios:**
   - **Result Pattern**: Repositórios e Use Cases devem retornar `Result<T, Exception>` (ADR-0001)
   - **Entidades Details**: Use `{Entity}Details` para persistência com Drift (veja seção 2.2 de `new_feature.md`)
   - **TypeConverters**: Necessário para enums e tipos customizados no Drift
   - **DateTimeConverter**: Obrigatório para campos `DateTime` em tabelas Drift
   - **Injeção de Dependência**: Use `AppModule` (não mapas de rotas estáticos)
   - **Validação Zard**: Use `zard_form` para validação de formulários (ADR-0004)

4. **Documentação Obrigatória:**
   - Nível Feature (`packages/{feature}/`):
     - `README.md` - Visão geral da feature completa
     - `CONTRIBUTING.md` - Guia de contribuição (ÚNICO para a feature)
     - `CHANGELOG.md` - Histórico agregado

   - Nível Subpacote (cada `_core`, `_client`, `_server`, `_ui`):
     - `README.md` - Documentação específica do pacote
     - `CHANGELOG.md` - Histórico do pacote
     - `analysis_options.yaml` - Config de linting (importar da raiz)

5. **Definição de Pronto (DoD):**
   - ✅ `dart analyze` ou `flutter analyze` → **0 warnings/errors**
   - ✅ Cobertura de testes: Core (90%), Client/Server (80%), UI (50%)
   - ✅ 100% dos membros públicos documentados (DartDoc)
   - ✅ Swagger exibindo endpoints (se aplicável)
   - ✅ Validação arquitetural: `_ui` não importa `_server`

**Erros Comuns:**
- Veja seção 5 de `docs/rules/new_feature.md` para lista completa de erros frequentes e soluções

### Adicionando Novos Pacotes (Estrutura Básica)

Se você precisa criar um pacote simples (não uma feature completa), siga o padrão de 4 variantes:

1. Criar estrutura de diretórios do pacote:
   ```
   packages/{feature}/
   ├── {feature}_shared/    # Apenas Dart puro
   ├── {feature}_ui/        # Widgets Flutter
   ├── {feature}_client/    # Lógica do cliente
   └── {feature}_server/    # Lógica do servidor
   ```

2. **Em `*_shared`**: Use apenas dependência `meta`. Defina:
   - Modelos de domínio como classes de dados imutáveis
   - Objetos de valor com serialização (`toMap`/`fromMap`)
   - Interfaces abstratas
   - Constantes e enums

3. **Em `*_ui`**: Dependa de `{feature}_shared`. Adicione:
   - Widgets Flutter
   - Extensões de tema
   - Lógica específica de UI

4. **Em `*_client`/`*_server`**: Dependa de `{feature}_shared` para implementações específicas de plataforma.

### Padrões de Codificação

Do CONTRIBUTING.md:

- Siga as [Diretrizes Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use formato Conventional Commits:
  - `feat:` - Nova funcionalidade
  - `fix:` - Correção de bug
  - `docs:` - Documentação
  - `refactor:` - Refatoração de código
  - `test:` - Testes
  - `chore:` - Manutenção

- Formate antes de fazer commit: `dart format`
- Execute análise: `dart analyze` ou `flutter analyze`
- Mantenha cobertura de testes acima de 80%
- Testes em `test/` devem espelhar a estrutura de `lib/`

### Análise de Código Não Usado

Vários pacotes contêm arquivos `analise_sem_uso.md` (análise de código não usado):
- `packages/project/analise_sem_uso.md`
- `packages/open_api/analise_sem_uso.md`

Estes documentos são gerados por análises automáticas para identificar:
- Classes não utilizadas
- Arquivos que podem ser removidos
- Código duplicado ou redundante

Antes de remover código identificado nestes arquivos, verifique se:
1. O código realmente não é usado (análise pode ter falsos positivos)
2. O código não faz parte de uma API pública do pacote
3. O código não é usado por outros pacotes via dependência

### Trabalhando com Múltiplos Serviços

O projeto suporta múltiplos serviços (EMS, SMS) que compartilham pacotes:

**Ao adicionar features:**
- Determine se a feature é específica de um serviço ou compartilhada
- Features compartilhadas vão em `/packages`
- Features específicas ficam no app/server correspondente

**Ao modificar pacotes compartilhados:**
- Lembre-se que mudanças afetam TODOS os serviços (EMS e SMS)
- Execute testes em todos os apps afetados
- Verifique compatibilidade com todos os servidores

**Ao trabalhar com banco de dados:**
- PostgreSQL é compartilhado entre EMS e SMS
- Migrations devem considerar ambos os serviços
- Veja `servers/INFRASTRUCTURE.md` para detalhes

### Trabalhando com Design Tokens

Ao criar componentes de UI, use design tokens de `design_system_shared`:

```dart
// Use constantes de espaçamento
padding: EdgeInsets.all(DSSpacing.medium)

// Use constantes de raio
borderRadius: BorderRadius.circular(DSRadius.medium)

// Use presets de padding
padding: DSPaddings.medium
```

### Trabalhando com Temas

Para adicionar um novo preset de tema:

1. Defina em `design_system_shared/lib/src/theme/presets/`:
   ```dart
   class NewPreset {
     static final DSThemeConfig config = DSThemeConfig(
       seedColor: ColorValue.fromHex('#HEXCODE'),
       // ... outras configurações
     );
   }
   ```

2. Adicione ao `DSThemeEnum` em `design_system_shared`

3. Atualize `DSTheme.forPreset()` em `design_system_ui`

### Padrão de Objeto de Valor

Ao criar conceitos de domínio (cores, moedas, etc.), siga o padrão `ColorValue`:

```dart
class YourValue {
  final int _value;
  const YourValue._(this._value);

  // Factory constructors
  factory YourValue.fromX(...) => ...;

  // Serialization
  Map<String, dynamic> toMap() => {...};
  factory YourValue.fromMap(Map<String, dynamic> map) => ...;

  // Equality
  @override
  bool operator ==(Object other) => ...;

  @override
  int get hashCode => _value.hashCode;

  // Utilities
  YourValue copyWith(...) => ...;
}
```

### Validação de Formulários (Zard Form)

O projeto usa o pacote `zard_form` para validação de formulários. Este é um pacote **especial** que NÃO segue o padrão de 4 variantes.

**Localização:** `packages/zard_form/`

**Uso:**
```dart
// Importar validadores
import 'package:zard_form/zard_form.dart';

// Criar validador
final validator = ZardValidator()
  .required('Campo obrigatório')
  .email('Email inválido')
  .minLength(6, 'Mínimo 6 caracteres');

// Validar
final result = validator.validate(value);
if (result.isValid) {
  // Valor válido
} else {
  // Mostrar result.error
}
```

**Características:**
- Depende de `zard: ^0.0.23`
- Usado em todos os apps (EMS e SMS)
- Possui sub-projeto de exemplo: `packages/zard_form/example/`
- Documentado em `docs/adr/0004-form-validation-zard.md`

**Não modifique este pacote** sem considerar impacto em todos os formulários do sistema.

## Estrutura do Projeto

```
ems_system/
├── VERSION                             # Versão atual (2.1.0)
├── CLAUDE.md                           # Este arquivo (instruções para Claude)
├── ARCHITECTURE.md                     # Documentação detalhada de arquitetura
├── CONTRIBUTING.md                     # Diretrizes de contribuição
├── README.md, CHANGELOG.md, LICENSE.md # Documentação padrão
│
├── apps/                               # Aplicações Flutter
│   ├── ems/
│   │   ├── app_design_draft/          # App de demonstração do design system
│   │   └── app_v1/                    # App EMS em produção
│   └── sms/
│       └── app_v1/                    # App SMS em produção
│
├── servers/                            # Servidores backend Dart/Shelf
│   ├── containers/
│   │   └── postgres/                  # Banco de dados PostgreSQL compartilhado
│   ├── ems/
│   │   ├── server_v1/                 # Servidor EMS em produção
│   │   └── container/                 # Docker setup para EMS
│   └── sms/
│       ├── server_v1/                 # Servidor SMS em produção
│       └── container/                 # Docker setup para SMS
│   └── INFRASTRUCTURE.md              # Documentação de infraestrutura Docker
│
├── packages/                          # Pacotes compartilhados (padrão 4 variantes)
│   ├── auth/                          # Autenticação (completo 4/4)
│   ├── core/                          # Funcionalidade central (completo 4/4)
│   ├── design_system/                 # Design system (parcial 2/4)
│   ├── images/                        # Gerenciamento de imagens (parcial 1/4)
│   ├── localizations/                 # i18n (parcial 3/4)
│   ├── notebook/                      # Notas/cadernos (completo 4/4)
│   ├── open_api/                      # Definições de API (parcial 2/4)
│   ├── project/                       # Projetos (estrutura hierárquica especial)
│   │   ├── project_core/              # Core de projetos (parcial 2/4)
│   │   ├── project/                   # Sub-feature (esqueleto)
│   │   └── task/                      # Sub-feature de tarefas (esqueleto)
│   ├── school/                        # Gerenciamento escolar (completo 4/4)
│   ├── tag/                           # Sistema de tags (completo 4/4)
│   ├── user/                          # Gerenciamento de usuários (completo 4/4)
│   └── zard_form/                     # Validação de formulários (standalone)
│
├── scripts/                           # Scripts de automação
│   ├── pub_get_all.sh                # Instalar dependências
│   ├── clean_all.sh                  # Limpar artefatos
│   ├── build_runner_all.sh           # Executar build_runner
│   ├── dart_fix_all.sh               # Aplicar dart fix
│   ├── check_documentation.sh        # Validar documentação
│   ├── validate_architecture.sh      # Validar arquitetura
│   └── generators/                   # Ferramentas de geração de código
│
├── docs/                              # Documentação detalhada
│   ├── core_package_analysis.md      # Análise do pacote core
│   ├── adr/                          # Architecture Decision Records
│   │   ├── 0001-result-pattern.md
│   │   ├── 0002-dio-error-handler.md
│   │   ├── 0003-base-repository.md
│   │   ├── 0004-form-validation-zard.md
│   │   ├── 0005-package-structure.md
│   │   └── 0006-base-details-sync.md
│   ├── architecture/                 # Guias de arquitetura
│   │   ├── architecture_patterns.md
│   │   ├── design_system_guide.md
│   │   ├── entity_patterns.md
│   │   └── features_hierarchy.md
│   └── rules/                        # Regras e convenções
│       ├── new_feature.md
│       └── flutter_dart_rules.md
│
├── openspec/                          # Sistema de especificações e propostas
│   ├── AGENTS.md                     # Instruções para agentes IA
│   ├── project.md                    # Especificação do projeto
│   ├── changes/                      # Propostas de mudança
│   └── specs/                        # Especificações detalhadas
│
├── analysis_options_dart.yaml         # Linting para Dart puro
├── analysis_options_flutter.yaml      # Linting para Flutter
├── devtools_options.yaml             # Configuração DevTools
└── pubspec.yaml                      # Workspace root (define todos os membros)
```

## Arquivos Importantes

**Documentação Principal:**
- `CLAUDE.md` - Este arquivo (instruções específicas para Claude Code)
- `ARCHITECTURE.md` - Documentação completa de arquitetura (37.5 KB, em português)
- `CONTRIBUTING.md` - Diretrizes de contribuição e padrões de código
- `VERSION` - Versão atual do sistema (2.1.0)
- `servers/INFRASTRUCTURE.md` - Documentação de infraestrutura Docker e PostgreSQL

**Especificações e Propostas (OpenSpec):**
- `openspec/AGENTS.md` - Instruções detalhadas para agentes IA trabalhando no projeto
- `openspec/project.md` - Especificação do projeto
- `openspec/changes/` - Propostas de mudança
- `openspec/specs/` - Especificações técnicas detalhadas

**Architecture Decision Records (ADRs):**
- `docs/adr/0001-result-pattern.md` - Pattern Result para tratamento de erros
- `docs/adr/0002-dio-error-handler.md` - Mixin Dio error handler
- `docs/adr/0003-base-repository.md` - Padrão base repository
- `docs/adr/0004-form-validation-zard.md` - Validação de formulários com Zard
- `docs/adr/0005-package-structure.md` - Estrutura padrão de pacotes
- `docs/adr/0006-base-details-sync.md` - Sincronização base details

**Guias de Arquitetura:**
- `docs/architecture/architecture_patterns.md` - Padrões arquiteturais do sistema
- `docs/architecture/design_system_guide.md` - Guia do design system
- `docs/architecture/entity_patterns.md` - Padrões de entidades
- `docs/architecture/features_hierarchy.md` - Hierarquia de features

**Referências de Código (Design System):**
- `packages/design_system/design_system_shared/lib/src/theme/ds_theme_config.dart` - Configuração de tema
- `packages/design_system/design_system_ui/lib/theme/ds_theme.dart` - Provedor de tema Flutter
- `packages/design_system/design_system_shared/lib/src/colors/color_value.dart` - Padrão de objeto de valor

**Referências de Código (Core):**
- `packages/core/core_shared/lib/src/result/` - Implementação do Result pattern
- `packages/core/core_client/lib/src/repositories/` - Base repositories
- `packages/zard_form/` - Sistema de validação de formulários

**Aplicações de Demonstração:**
- `apps/ems/app_design_draft/lib/main.dart` - Demo de troca dinâmica de tema
- `apps/ems/app_v1/` - App EMS em produção
- `apps/sms/app_v1/` - App SMS em produção

**Configuração de Workspace:**
- `pubspec.yaml` (root) - Define todos os pacotes membros do workspace
  - **Nota:** Alguns pacotes estão comentados (não ativos no workspace)
  - Veja o arquivo para detalhes sobre quais variantes estão ativas

## Configuração de Workspace e Pacotes Ativos

O arquivo `pubspec.yaml` na raiz define o workspace com todos os pacotes membros. **Importante:** Nem todos os pacotes com diretórios estão ativos no workspace.

### Pacotes Comentados (Não Ativos)
Os seguintes pacotes têm diretórios mas estão comentados no `pubspec.yaml`:
- `design_system_client`, `design_system_server`
- `images_client`, `images_server`, `images_shared`
- `localizations_client`
- `open_api_client`, `open_api_ui`
- `project_core_client`, `project_core_server`
- Todos os pacotes `project/*` (sub-features)
- Todos os pacotes `task/*` (sub-features)

Estes pacotes podem ter diretórios e alguns arquivos, mas não possuem `pubspec.yaml` válido e não estão incluídos no workspace ativo.

### Quando Ativar Pacotes Comentados
Antes de trabalhar em um pacote comentado:
1. Verifique se o diretório possui `pubspec.yaml`
2. Se não possuir, crie seguindo o padrão de 4 variantes
3. Descomente a entrada correspondente no `pubspec.yaml` raiz
4. Execute `./scripts/pub_get_all.sh`

## Architecture Decision Records (ADRs)

O projeto mantém registros de decisões arquiteturais importantes em `docs/adr/`. Estes documentos explicam o contexto, decisões e consequências de padrões adotados:

1. **ADR-0001: Result Pattern** (`docs/adr/0001-result-pattern.md`)
   - Pattern para tratamento de erros sem exceções
   - Implementação em `packages/core/core_shared/lib/src/result/`
   - Use `Result<T, E>` ao invés de `throw` em lógica de negócio

2. **ADR-0002: Dio Error Handler Mixin** (`docs/adr/0002-dio-error-handler.md`)
   - Mixin para tratamento consistente de erros HTTP
   - Converte exceções Dio em objetos Result

3. **ADR-0003: Base Repository Pattern** (`docs/adr/0003-base-repository.md`)
   - Padrão base para todos os repositórios
   - Implementação em `packages/core/core_client/lib/src/repositories/`
   - Todos os novos repositórios devem estender `BaseRepository`

4. **ADR-0004: Form Validation com Zard** (`docs/adr/0004-form-validation-zard.md`)
   - Escolha do Zard para validação de formulários
   - Implementação em `packages/zard_form/`
   - Use este padrão para todos os formulários

5. **ADR-0005: Estrutura Padrão de Pacotes** (`docs/adr/0005-package-structure.md`)
   - Define o padrão de 4 variantes (_shared, _ui, _client, _server)
   - Regras de dependências entre variantes
   - **Leia antes de criar novos pacotes**

6. **ADR-0006: Base Details Sync** (`docs/adr/0006-base-details-sync.md`)
   - Padrão de sincronização entre listagens e detalhes
   - Evita inconsistências de estado

**Ao tomar decisões arquiteturais significativas**, considere criar um novo ADR seguindo o formato existente.

## Documentação Adicional

Para informações mais detalhadas sobre:
- **Arquitetura completa**: Consulte `ARCHITECTURE.md` (documentação de 37.5 KB em português)
- **Padrões de código**: Consulte ADRs em `docs/adr/` (listados acima)
- **Infraestrutura Docker**: Consulte `servers/INFRASTRUCTURE.md`
- **Propostas e especificações**: Consulte `openspec/AGENTS.md`
- **Regras de features**: Consulte `docs/rules/new_feature.md`
- **Padrões de entidades**: Consulte `docs/architecture/entity_patterns.md`
- **Hierarquia de features**: Consulte `docs/architecture/features_hierarchy.md`

## Scripts de Validação

O projeto inclui scripts de validação para garantir qualidade:

```bash
# Validar arquitetura (verifica padrão de 4 variantes, dependências corretas, etc.)
./scripts/validate_architecture.sh

# Verificar completude da documentação
./scripts/check_documentation.sh
```

Estes scripts são executados automaticamente em hooks de CI/CD.

<!-- OPENSPEC:START -->
# Instruções OpenSpec

Estas instruções são para assistentes de IA trabalhando neste projeto.

Sempre abra `@/openspec/AGENTS.md` quando a solicitação:
- Mencionar planejamento ou propostas (palavras como proposta, especificação, mudança, plano)
- Introduzir novas capacidades, mudanças disruptivas, mudanças arquiteturais ou grande trabalho de performance/segurança
- Parecer ambígua e você precisar da especificação autoritativa antes de codificar

Use `@/openspec/AGENTS.md` para aprender:
- Como criar e aplicar propostas de mudança
- Formato e convenções de especificação
- Estrutura e diretrizes do projeto

Mantenha este bloco gerenciado para que 'openspec update' possa atualizar as instruções.

<!-- OPENSPEC:END -->