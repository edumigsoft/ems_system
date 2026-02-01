# Plano: Integração de Tags no Notebook com Gerenciamento Opcional

## Contexto

O pacote `notebook` já possui suporte básico para tags, mas a implementação atual tem limitações:

### Estado Atual (Descobertas da Exploração)

**Notebook Package:**
- ✅ Tags já existem no domínio: `Notebook` possui campo `tags: List<String>?`
- ✅ Armazenamento: JSON array no PostgreSQL via `StringListConverter`
- ✅ UI básica: Input de texto com tags separadas por vírgula
- ⚠️ `NotebookTagTable` (junction M2M) definida mas **NÃO UTILIZADA**
- ❌ Filtro por tags no servidor **NÃO IMPLEMENTADO** (comentado no código)
- ✅ `NotebookDetailViewModel` já importa `TagApiService`
- ✅ `loadAvailableTags()` já implementado para autocomplete

**Tag Package:**
- ✅ Estrutura completa (4/4 variantes)
- ✅ Widgets prontos: `TagSelector`, `TagInputWidget`, `TagChip`, `TagCard`
- ✅ Repository e Use Cases completos
- ✅ UI com autocomplete e seleção múltipla
- ✅ Suporte a cores e descrições

**Padrão M2M Existente:**
```dart
NotebookTagTable {
  primaryKey: (notebookId, tagId)
  notebookId: FK → NotebookTable (CASCADE)
  tagId: FK → TagTable (planejado, não implementado)
  associatedAt: DateTime
}
```

## Objetivos

1. **Melhorar UI de gerenciamento de tags** - Substituir input de texto simples por componentes interativos
2. **Implementar filtro por tags funcional** - Query PostgreSQL para buscar notebooks por tag
3. **Decisão arquitetural** - JSON array vs. normalização M2M
4. **Manter tags opcionais** - Notebooks podem não ter tags
5. **Permitir edição inline** - Adicionar/remover tags diretamente no detalhe do notebook

## Pontos de Decisão Pendentes

### 1. Arquitetura de Armazenamento

**Opção A: Manter JSON Array (Atual)**
- ✅ Simplicidade
- ✅ Menos queries (dados desnormalizados)
- ✅ Funcionamento atual preservado
- ❌ Filtro requer operador PostgreSQL `@>` (complexo)
- ❌ Sem integridade referencial (tags podem não existir)
- ❌ Duplicação de nomes de tags

**Opção B: Migrar para M2M Normalizado**
- ✅ Integridade referencial (FK constraints)
- ✅ Queries simples com JOINs
- ✅ Suporte nativo a filtros complexos
- ✅ Junction table já existe (`NotebookTagTable`)
- ❌ Migração de dados necessária
- ❌ Mais queries (JOIN overhead)
- ❌ Mudança arquitetural significativa

**Recomendação Pendente:** Aguardando decisão do usuário

### 2. Escopo de UI

**Componentes a atualizar:**
- `NotebookFormPage` - Substituir input de texto por `TagSelector` ou `TagInputWidget`
- `NotebookDetailPage` - Exibir tags com `TagChip` + botão de edição
- `NotebookListPage` - Adicionar filtro por tags (sidebar ou dropdown)

**Widgets disponíveis em tag_ui:**
- `TagSelector` - Multi-select com chips e toggle
- `TagInputWidget` - Autocomplete + selected chips
- `TagChip` - Display individual com delete action

## Fases de Implementação (Esboço Inicial)

### Fase 1: Shared Layer (Domain)
- [ ] Decidir estratégia de armazenamento (A ou B)
- [ ] Se M2M: Atualizar `Notebook` entity para referenciar tag IDs
- [ ] Se JSON: Manter estrutura atual
- [ ] Validar DTOs (`NotebookCreate`, `NotebookUpdate`)

### Fase 2: Server Layer
**Se JSON Array:**
- [ ] Implementar filtro PostgreSQL com operador `@>` em `NotebookRepositoryServer`

**Se M2M:**
- [ ] Ativar `NotebookTagTable` no schema Drift
- [ ] Criar migration para converter dados existentes
- [ ] Implementar queries com JOIN para filtro por tags
- [ ] Adicionar operações CRUD para associações

### Fase 3: Client Layer
- [ ] Atualizar `NotebookApiService` se necessário (query params para filtro)
- [ ] Garantir compatibilidade de DTOs

### Fase 4: UI Layer
- [ ] Substituir input de texto por `TagInputWidget` em `NotebookFormViewModel`
- [ ] Adicionar gerenciamento de tags em `NotebookDetailViewModel`
- [ ] Implementar filtro por tags em `NotebookListViewModel`
- [ ] Atualizar widgets para exibir tags visualmente

### Fase 5: Testes e Validação
- [ ] Testes unitários para filtro de tags
- [ ] Testes de integração (criar/editar/filtrar)
- [ ] Validação de migration (se M2M)

## Arquivos Críticos (Caminhos Validados)

**Server (CRÍTICO - Implementar Filtro PostgreSQL):**
- `/home/anderson/Projects/Working/ems_system/packages/notebook/notebook_server/lib/src/repository/notebook_repository_server.dart`
  - Linhas 115-117: Comentário indicando filtro por tags NÃO implementado
  - Método `getAll()` recebe `List<String>? tags` mas ignora o parâmetro
  - **Ação:** Implementar query com operador PostgreSQL `@>`

**UI ViewModels (CRÍTICO - Refatorar para TagDetails):**
- `/home/anderson/Projects/Working/ems_system/packages/notebook/notebook_ui/lib/ui/view_models/notebook_form_view_model.dart`
  - Linha 49-50: Registra `notebookTagsField` como string separada por vírgula
  - Linha 71-78: Método `_parseTags()` faz parsing manual
  - **Ação:** Adicionar `TagApiService`, gerenciar `List<TagDetails>`, remover parsing manual

- `/home/anderson/Projects/Working/ems_system/packages/notebook/notebook_ui/lib/ui/view_models/notebook_detail_view_model.dart`
  - Já tem `_availableTags` e `loadAvailableTags()`
  - **Ação:** Adicionar métodos `addTagToNotebook()` e `removeTagFromNotebook()`

- `/home/anderson/Projects/Working/ems_system/packages/notebook/notebook_ui/lib/ui/view_models/notebook_list_view_model.dart`
  - **Ação:** Adicionar `TagApiService`, implementar filtro server-side, remover filtro client-side

**Tag Widgets Disponíveis (Reutilização):**
- `/home/anderson/Projects/Working/ems_system/packages/tag/tag_ui/lib/ui/widgets/tag_selector.dart` ✅ Validado
  - Widget pronto com `List<TagDetails>` e callback `onChanged`
- `/home/anderson/Projects/Working/ems_system/packages/tag/tag_ui/lib/ui/widgets/tag_input_widget.dart`
- `/home/anderson/Projects/Working/ems_system/packages/tag/tag_ui/lib/ui/widgets/tag_chip.dart`

## Verificação End-to-End

Após implementação:
1. Criar notebook sem tags → ✅ Deve permitir salvar
2. Criar notebook com 3 tags → ✅ Deve exibir chips na lista
3. Editar notebook e adicionar/remover tags → ✅ Deve refletir mudanças
4. Filtrar notebooks por uma tag específica → ✅ Deve retornar apenas notebooks com essa tag
5. Deletar tag → ✅ Verificar comportamento (depende de arquitetura escolhida)
6. Testes unitários → ✅ 0 erros no `dart analyze`

## Plano de Implementação Detalhado

### Decisões Arquiteturais Confirmadas

1. ✅ **Manter JSON Array** - Sem migração de dados, mais simples
2. ✅ **Usar TagSelector** - Widget do pacote tag_ui para multi-select
3. ✅ **Implementar filtro PostgreSQL** - Operador `@>` para JSON containment

### Ordem de Implementação (ADR-0005)

**Fase 1: notebook_shared (Domain)**
- ✅ **Nenhuma mudança necessária** - Domain já suporta `tags: List<String>?`
- Validação: `cd packages/notebook/notebook_shared && dart analyze`

**Fase 2: notebook_client (API)**
- ✅ **Nenhuma mudança necessária** - API service já tem parâmetro `tags` em `getAll()`
- Validação: `cd packages/notebook/notebook_client && flutter analyze`

**Fase 3: notebook_server (Database & Filtering) ⚠️ CRÍTICO**

Arquivo: `packages/notebook/notebook_server/lib/src/repository/notebook_repository_server.dart`

**Mudança nas linhas 115-117:**
```dart
// ANTES (comentado):
// Filtro por tags (requer busca em array JSON)
// Isso requer uma query customizada com operador PostgreSQL @>
// Por enquanto, vamos pular este filtro

// DEPOIS (implementado):
// Filtro por tags usando operador PostgreSQL @> para JSON arrays
if (tags != null && tags.isNotEmpty) {
  final tagsJson = jsonEncode(tags);
  query.where((t) => CustomExpression<bool>(
    "(tags::jsonb @> '$tagsJson'::jsonb)",
  ));
}
```

**Adicionar import:**
```dart
import 'dart:convert' show jsonEncode;
```

**Criar índice GIN (performance):**
```sql
-- Migration: packages/notebook/notebook_server/migrations/002_add_tags_gin_index.sql
CREATE INDEX IF NOT EXISTS idx_notebooks_tags_gin
ON notebooks USING GIN ((tags::jsonb));
```

**Validação:**
- `cd packages/notebook/notebook_server && dart analyze` → 0 erros
- Testar: `curl "http://localhost:8080/api/notebooks?tags=tag_id_1,tag_id_2"`

**Fase 4: notebook_ui (Presentation) ⚠️ EXTENSO**

**4.1 - Adicionar dependências ao pubspec.yaml:**
```yaml
dependencies:
  tag_shared:
    path: ../../tag/tag_shared
  tag_client:
    path: ../../tag/tag_client
  tag_ui:
    path: ../../tag/tag_ui
```

**4.2 - Refatorar NotebookFormViewModel:**

Arquivo: `packages/notebook/notebook_ui/lib/ui/view_models/notebook_form_view_model.dart`

Principais mudanças:
1. Adicionar `TagApiService _tagService` como dependência no construtor
2. Adicionar estado: `List<TagDetails> _selectedTags = []`, `List<TagDetails> _availableTags = []`
3. Adicionar métodos: `loadAvailableTags()`, `addTag()`, `removeTag()`, `setTags()`
4. Modificar `_initializeFields()` para carregar tags de IDs com `_loadTagDetailsFromIds()`
5. Atualizar `createNotebookCreate()` e `createNotebookUpdate()` para usar `_selectedTags.map((t) => t.id).toList()`
6. **REMOVER** `notebookTagsField` do FormValidationMixin
7. **REMOVER** método `_parseTags()` (não mais necessário)

**4.3 - Atualizar NotebookFormPage:**

Arquivo: `packages/notebook/notebook_ui/lib/ui/pages/notebook_form_page.dart`

1. Adicionar imports: `tag_ui`, `tag_shared`, `tag_client`
2. Injetar `TagApiService` no `initState()`
3. Substituir TextField de tags por `TagSelector`:
   ```dart
   TagSelector(
     availableTags: _viewModel.availableTags,
     selectedTags: _viewModel.selectedTags,
     onChanged: (newTags) => _viewModel.setTags(newTags),
   )
   ```

**4.4 - Atualizar NotebookDetailViewModel:**

Arquivo: `packages/notebook/notebook_ui/lib/ui/view_models/notebook_detail_view_model.dart`

Adicionar métodos:
- `addTagToNotebook(TagDetails tag)` - Atualiza servidor + estado local
- `removeTagFromNotebook(String tagId)` - Atualiza servidor + estado local
- `notebookTagsWithDetails` getter - Resolve IDs para entidades TagDetails

**4.5 - Atualizar NotebookDetailPage:**

Arquivo: `packages/notebook/notebook_ui/lib/ui/pages/notebook_detail_page.dart`

1. Adicionar seção de tags com `Wrap` de `TagChip`
2. Botão "Adicionar tag" que abre dialog de seleção
3. Chips com botão de delete para remoção inline
4. Dialogs de confirmação para adição/remoção

**4.6 - Refatorar NotebookListViewModel:**

Arquivo: `packages/notebook/notebook_ui/lib/ui/view_models/notebook_list_view_model.dart`

1. Adicionar `TagApiService _tagService` no construtor
2. Adicionar `List<TagDetails> _allAvailableTags` e `loadAvailableTags()`
3. Modificar `_executeLoadNotebooks()` para passar `tags` como query param ao servidor
4. **REMOVER** filtro client-side por tags em `filteredNotebooks` getter
5. Atualizar `toggleTagFilter()` para recarregar dados do servidor

**4.7 - Atualizar NotebookListPage:**

Arquivo: `packages/notebook/notebook_ui/lib/ui/pages/notebook_list_page.dart`

Adicionar UI de filtro (escolher entre):
- **Opção A:** Sidebar com FilterChips (desktop)
- **Opção B:** ExpansionTile com FilterChips (mobile)

### Ordem de Validação por Pacote

1. **notebook_shared**: `dart analyze` → 0 erros ✅
2. **notebook_client**: `flutter analyze` → 0 erros ✅
3. **notebook_server**: `dart analyze` → 0 erros, teste manual com curl ✅
4. **notebook_ui**: `flutter analyze` → 0 erros, teste E2E ✅

## Verificação End-to-End

Após implementação completa, testar:

1. ✅ **Criar notebook sem tags** → Deve permitir salvar
2. ✅ **Criar notebook com 3 tags** → Chips exibidos na lista
3. ✅ **Editar notebook e modificar tags** → Mudanças refletidas
4. ✅ **Filtrar notebooks por tag** → Apenas notebooks com a tag aparecem
5. ✅ **Adicionar tag inline (detail page)** → Tag adicionada imediatamente
6. ✅ **Remover tag inline (detail page)** → Tag removida imediatamente
7. ✅ **Filtro múltiplo (2+ tags)** → AND logic funciona (todas as tags)
8. ✅ **Performance** → Query < 100ms com índice GIN

## Notas Técnicas Importantes

**PostgreSQL `@>` Operator:**
- Verifica se JSON array à esquerda CONTÉM JSON array à direita
- Requer cast para `jsonb`: `tags::jsonb @> '["tag1"]'::jsonb`
- GIN index melhora performance em 10-100x dependendo do dataset

**TagSelector vs TagInputWidget:**
- `TagSelector`: Exibe todas as tags como FilterChips (multi-select visual)
- `TagInputWidget`: Input com autocomplete + chips removíveis (melhor para muitas tags)
- **Escolha recomendada:** TagSelector para formulários (mais intuitivo)

**Tag IDs vs Tag Names:**
- Sempre armazenar IDs, não nomes (permite renomear tags sem quebrar referências)
- UI resolve IDs para TagDetails via `TagApiService.getAll()`
- Filtro usa IDs para garantir consistência

## Próximos Passos

1. ✅ Plano detalhado aprovado pelo usuário
2. Executar implementação seguindo ordem: server → ui
3. Validar cada fase com `analyze` antes de prosseguir
4. Testes E2E finais
5. Atualizar documentação e CHANGELOG
