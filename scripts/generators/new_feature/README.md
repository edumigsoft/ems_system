# Scripts de Validação e Qualidade

Este diretório contém scripts para validação e manutenção da qualidade do código do projeto EMS System.

## 📋 Scripts Disponíveis

### 1. `validate_architecture.sh`

Script de validação arquitetural que verifica conformidade com os padrões estabelecidos no projeto.

**O que valida:**
- ✅ Estrutura de pacotes seguindo ADR-0005 (Domain/Data separados)
- ✅ Presença de arquivos obrigatórios (README, CHANGELOG, analysis_options)
- ✅ Import correto de analysis_options da raiz
- ✅ Pureza de entidades (sem fromJson/toJson em domain/entities)
- ✅ **Entities sem campo `id`** (apenas EntityDetails deve ter id)
- ✅ Implementação de BaseDetails em classes *Details
- ✅ **`createdAt` e `updatedAt` non-nullable** (DateTime, não DateTime?)
- ✅ **DTOs Update sem `createdAt`/`updatedAt`** (campos imutáveis)
- ✅ Hierarquia correta de Features vs Sub-Features
- ✅ Ausência de CONTRIBUTING.md duplicado em sub-features

**Como usar:**
```bash
# Da raiz do projeto (modo quiet - apenas erros/avisos)
./scripts/validate_architecture.sh

# Modo verboso (mostra todas as validações)
./scripts/validate_architecture.sh -v
# ou
./scripts/validate_architecture.sh --verbose
```

**Códigos de Saída:**
- `0` - Validação passou sem erros
- `1` - Validação falhou com erros críticos

**Interpretação de Resultados:**
- ✅ Verde: Conformidade total
- ⚠️  Amarelo: Avisos (não bloqueiam CI, mas devem ser revisados)
- ❌ Vermelho: Erros críticos (bloqueiam CI)

**Exemplo de Output:**
```
╔════════════════════════════════════════════════════════════╗
║           Validação de Arquitetura - EMS System            ║
╚════════════════════════════════════════════════════════════╝

════════════════════════════════════════════════════════════
Validando feature: user
════════════════════════════════════════════════════════════

✅ user: README.md presente
✅ user: CONTRIBUTING.md presente
✅ user_core: Estrutura Domain/Data presente
✅ user_core: Todas as entidades são puras (sem JSON)
✅ user_core: Todas as classes *Details implementam BaseDetails

════════════════════════════════════════════════════════════
           RELATÓRIO FINAL DE VALIDAÇÃO
════════════════════════════════════════════════════════════

Sucessos: 42
Avisos:   3
Erros:    0

╔════════════════════════════════════════════════════════════╗
║   ⚠️  VALIDAÇÃO COM AVISOS - Revisar itens marcados       ║
╚════════════════════════════════════════════════════════════╝
```

**Integração CI/CD:**

Adicione ao `.github/workflows/ci.yml`:
```yaml
name: CI

on: [push, pull_request]

jobs:
  validate-architecture:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate Architecture
        run: ./scripts/validate_architecture.sh
```

---

### 2. `check_documentation.sh`

Script de validação de documentação que verifica a presença e qualidade de docstrings no código.

**O que valida:**
- ✅ Presença de docstrings (///) em classes públicas
- ✅ Presença de docstrings em métodos públicos
- ✅ Detecção de comentários redundantes
- ✅ Cálculo de cobertura de documentação
- ✅ Ignora arquivos gerados (.g.dart, .freezed.dart)
- ✅ Relatório detalhado por arquivo e pacote

**Como usar:**
```bash
# Da raiz do projeto (modo quiet - apenas problemas)
./scripts/check_documentation.sh

# Modo verboso (mostra todos os arquivos analisados)
./scripts/check_documentation.sh -v

# Ver relatório detalhado
./scripts/check_documentation.sh 2>&1 | tee doc_report.txt
```

**Códigos de Saída:**
- `0` - Meta de documentação atingida (100%)
- `0` - Documentação boa (≥70%)
- `1` - Documentação insuficiente (<70%)

**Métricas:**
- **Meta**: 100% de documentação
- **Limite de Aviso**: 70%
- **Crítico**: <70%

**Exemplo de Output:**
```
╔════════════════════════════════════════════════════════════╗
║    Validação de Documentação - School Manager System      ║
╚════════════════════════════════════════════════════════════╝

════════════════════════════════════════════════════════════
Analisando pacote: school_core
════════════════════════════════════════════════════════════

Analisando: packages/school/school_core/lib/src/domain/entities/school.dart
⚠️  school.dart:5 - Classe 'School' sem docstring
⚠️  school.dart:15 - Método público 'isValid' sem docstring
  Classes: 0/1 (0%)
  Métodos: 0/1 (0%)

════════════════════════════════════════════════════════════
           RELATÓRIO FINAL DE DOCUMENTAÇÃO
════════════════════════════════════════════════════════════

Estatísticas de Documentação:
  Classes Públicas:  42/58 (72%)
  Métodos Públicos:  105/156 (67%)
  Cobertura Geral:   147/214 (69%)

Avisos: 67

Meta de Documentação:
  Objetivo:  100%
  Atual:     69%

╔════════════════════════════════════════════════════════════╗
║   ⚠️  DOCUMENTAÇÃO BOA - Próximo da meta                  ║
╚════════════════════════════════════════════════════════════╝

Adicione docstrings nas classes/métodos marcados acima.
```

**Padrão de Docstring:**
```dart
/// Resumo breve da classe ou método em uma linha.
///
/// Detalhes adicionais após linha vazia.
/// Pode incluir exemplos, parâmetros, returns, etc.
///
/// Exemplo:
/// ```dart
/// final school = School(name: 'ABC', address: '123');
/// ```
class School {
  // ...
}
```

**Integração CI/CD:**
```yaml
name: Documentation Check

on: [push, pull_request]

jobs:
  check-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check Documentation
        run: ./scripts/check_documentation.sh
```

---

### 3. `generate_coverage_report.sh`

Script de geração de relatório consolidado de cobertura de testes para todos os pacotes.

**O que faz:**
- ✅ Executa testes com cobertura em todos os pacotes
- ✅ Gera relatórios HTML individuais e consolidado
- ✅ Calcula métricas de cobertura por pacote
- ✅ Valida metas de cobertura por tipo de pacote
- ✅ Cria relatório textual resumido
- ✅ Mescla coberturas em arquivo único

**Metas de Cobertura:**
- **Core** (Domain/UseCases): **90%**
- **Client/Server** (Data): **80%**
- **UI** (Widgets): **50%**

**Como usar:**
```bash
# Da raiz do projeto
./scripts/generate_coverage_report.sh

# Ver relatório HTML consolidado
# Abrir: coverage_reports/latest/html/index.html
```

**Códigos de Saída:**
- `0` - Todos os testes passaram
- `1` - Falhas nos testes detectadas

**Estrutura de Saída:**
```
coverage_reports/
└── YYYYMMDD_HHMMSS/
    ├── summary.txt                    # Relatório textual
    ├── merged_lcov.info               # Cobertura consolidada
    ├── html/                          # HTML consolidado
    │   └── index.html
    ├── <package>_lcov.info            # Cobertura por pacote
    ├── <package>_html/                # HTML por pacote
    │   └── index.html
    └── <package>_test.log             # Log de execução
```

**Exemplo de Output:**
```
╔════════════════════════════════════════════════════════════╗
║     Relatório de Cobertura - School Manager System        ║
╚════════════════════════════════════════════════════════════╝

════════════════════════════════════════════════════════════
Testando: school_core
════════════════════════════════════════════════════════════

Encontrados 15 arquivo(s) de teste
Executando testes...
✅ Testes executados com sucesso
Cobertura: 85%
⚠️  Abaixo da meta (90%)
✅ HTML gerado em: coverage_reports/.../school_core_html/index.html

═══════════════════════════════════════════════════════════════
  COBERTURA POR PACOTE
═══════════════════════════════════════════════════════════════

school_core                               85%  [Meta: 90%] ⚠️  Core
user_core                                 92%  [Meta: 90%] ✅ Core
auth_core                                 45%  [Meta: 90%] ⚠️  Core
school_client                             82%  [Meta: 80%] ✅ Client/Server
dashboard_ui                              65%  [Meta: 50%] ✅ UI

════════════════════════════════════════════════════════════
           RELATÓRIO FINAL
════════════════════════════════════════════════════════════

Pacotes Testados: 14/14
Pacotes com Falha: 0

Relatórios gerados em:
  • Consolidado: coverage_reports/latest/html/index.html
  • Resumo:      coverage_reports/latest/summary.txt
  • Último:      coverage_reports/latest/
```

**Dependências:**
- `genhtml` (opcional) - Para gerar HTML
  ```bash
  # Ubuntu/Debian
  sudo apt-get install lcov
  
  # macOS
  brew install lcov
  ```

**Integração CI/CD:**
```yaml
name: Test Coverage

on: [push, pull_request]

jobs:
  coverage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Install lcov
        run: sudo apt-get install -y lcov
      - name: Generate Coverage Report
        run: ./scripts/generate_coverage_report.sh
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage_reports/latest/merged_lcov.info
```

---

## 🔧 Scripts Futuros (Planejados)

### `validate_base_details_sync.sh`
Valida sincronização entre BaseDetails e DriftTableMixin (ADR-0006)

### `analyze_dependencies.sh`
Analisa dependências entre pacotes e detecta violações arquiteturais

---

## 📚 Referências

- [ADR-0005: Estrutura Padrão de Pacotes](../docs/adr/0005-standard-package-structure.md)
- [ADR-0006: Sincronização BaseDetails](../docs/adr/0006-base-details-sync.md)
- [Análise Técnica Completa](../analise_tecnica_completa.md)
- [Regras Flutter/Dart](../docs/rules/flutter_dart_rules.md)

---

## 🤝 Contribuindo

Ao criar novos scripts de validação:
1. Use bash para compatibilidade
2. Adicione cores para output legível
3. Forneça mensagens de erro claras
4. Documente no README
5. Torne executável com `chmod +x`
6. Teste localmente antes de commitar

---

**Última atualização:** 31/12/2025
