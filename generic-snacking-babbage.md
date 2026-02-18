# Plano: Padronização de Design nos Pacotes *_ui

## Contexto

Os pacotes `user_ui`, `tag_ui` e `notebook_ui` usam `Scaffold`+`AppBar` no nível da página, resultando em layout mobile mesmo em desktop. O `school_ui` é o template canônico de referência: página sem `Scaffold`, usando `DSCardHeader`+`DSCard`+`ResponsiveLayout`, com widget específico por breakpoint.

## Decisões de Design (Definitivas)

| Decisão | Regra |
|---|---|
| Todas as páginas (exceto auth) | Sem `Scaffold`/`AppBar` no nível da página |
| Mobile | **Read-only** — apenas visualização (sem FAB, sem ações de edit/delete nos cards) |
| Tablet | Edit completo (FAB, ações edit/delete, GridView) |
| Desktop | Edit completo com `DSDataTableContainer` |
| Formulário ≤ 3 campos | Dialog |
| Formulário > 3 campos | Página separada sem `Scaffold` (usa `DSCardHeader` com `actionButton: IconButton(Icons.arrow_back)`) |
| Auth pages | Mantidas como estão (identidade própria) |

## Padrão Alvo

### Página de Lista (`*_page.dart`)
```dart
// Sem Scaffold — embutida no shell de navegação
ListenableBuilder(
  listenable: viewModel,
  builder: (context, _) => Column(children: [
    DSCardHeader(title: '...', subtitle: '...', showSearch: false),
    Expanded(child: DSCard(child: ResponsiveLayout(
      mobile: MobileWidget(viewModel: viewModel),   // read-only
      tablet: TabletWidget(viewModel: viewModel),   // edit
      desktop: DesktopWidget(viewModel: viewModel), // edit
    ))),
  ]),
)
```

### Página de Formulário (> 3 campos) — sem Scaffold
```dart
Column(children: [
  DSCardHeader(
    title: 'Nova Tag',
    actionButton: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    ),
  ),
  Expanded(child: DSCard(
    child: SingleChildScrollView(child: /* campos do formulário */),
  )),
])
```

### Widgets por Breakpoint
- **Mobile**: `Column` sem `Scaffold`, `ListView.builder` com cards read-only (sem ações)
- **Tablet**: `Scaffold`+`AppBar`+`FAB`, `GridView.builder` 2 colunas, ações de edição
- **Desktop**: sem `Scaffold`, `DSDataTableContainer` com tabela, sorting, filtros, paginação

> **Nota sobre Scaffold em Tablet**: Tablet recebe `Scaffold` próprio porque pode ser acessado standalone (sem shell de navegação), semelhante ao `school_ui`.

---

## Análise de Formulários por Pacote

| Pacote | Formulário | Campos | Padrão |
|---|---|---|---|
| `tag_ui` | Criar tag | nome, descrição, cor | 3 → **Dialog** |
| `tag_ui` | Editar tag | nome, descrição, cor, ativo | 4 → **Página** |
| `user_ui` | Criar usuário | nome, email, username, telefone, role | 5 → **Página** |
| `user_ui` | Editar usuário | nome, telefone, role, ativo | 4 → **Página** |
| `notebook_ui` | Criar/editar notebook | título, tipo, descrição, tags | 4+ → **Página** |

---

## 1. `user_ui` (`packages/user/user_ui/`)

### Arquivos a Modificar

| Arquivo | O que muda |
|---|---|
| `lib/pages/manage_users_page.dart` | Remover `Scaffold`+`AppBar`+action; remover `_showCreateUserDialog`; usar `DSCardHeader`+`DSCard`+`ResponsiveLayout`; importar `DesktopWidget` |
| `lib/ui/widgets/components/mobile/mobile_widget.dart` | Remover `Scaffold`+`AppBar`; tornar read-only (sem `UserSearchField` de escrita, sem edit/delete nos cards, sem FAB); manter lista `ListView.builder` com `UserCard` |
| `lib/ui/widgets/components/tablet/tablet_widget.dart` | Adicionar `Scaffold`+`AppBar`+`FAB` (criar usuário se `isOwner`); FAB navega para `ManageUsersFormPage`; edit via `Navigator.push` para `ManageUsersFormPage(user: user)` |

### Arquivos Novos a Criar

| Arquivo | Propósito |
|---|---|
| `lib/pages/manage_users_form_page.dart` | Página de formulário (criar/editar) **sem Scaffold**; usa `DSCardHeader` com `actionButton` de back; campos: nome, email, username, telefone, role (criar) / nome, telefone, role, ativo (editar) |
| `lib/ui/widgets/components/desktop/desktop_widget.dart` | Wrapper `ListenableBuilder` → `DesktopTableWidget` |
| `lib/ui/widgets/components/desktop/desktop_table_widget.dart` | `DSDataTableContainer`; colunas: Usuário (nome+username), Email+Telefone, Função, Status, Ações (editar→form page, deletar→dialog, reset senha→dialog); botão "Adicionar" (se `isOwner`) → navega para form page |
| `lib/ui/widgets/dialogs/user_delete_confirm_dialog.dart` | AlertDialog confirmação de delete |
| `lib/ui/widgets/dialogs/user_reset_password_dialog.dart` | AlertDialog confirmação de reset de senha |
| `lib/ui/widgets/dialogs/dialogs.dart` | Barrel export |

> **Nota**: Não há dialog de formulário para usuário (todos os forms têm > 3 campos → página).

### Filtros Desktop (`DSTableFilterBar`)
```dart
[
  DSTableFilter(id: 'role_admin',   label: 'Admin',   predicate: (u) => u.role == UserRole.admin),
  DSTableFilter(id: 'role_manager', label: 'Manager', predicate: (u) => u.role == UserRole.manager),
  DSTableFilter(id: 'role_user',    label: 'Usuário', predicate: (u) => u.role == UserRole.user),
]
```

### Ordem de Implementação
1. Criar `user_delete_confirm_dialog.dart`, `user_reset_password_dialog.dart`, `dialogs.dart`
2. Criar `manage_users_form_page.dart` (sem Scaffold)
3. Modificar `mobile_widget.dart` (read-only)
4. Modificar `tablet_widget.dart` (Scaffold+FAB+push para form page)
5. Criar `desktop_table_widget.dart`, `desktop_widget.dart`
6. Modificar `manage_users_page.dart`

---

## 2. `tag_ui` (`packages/tag/tag_ui/`)

### Arquivos a Modificar

| Arquivo | O que muda |
|---|---|
| `lib/ui/pages/tag_list_page.dart` | Remover `Scaffold`+`AppBar`+`FAB`+lógica de ações; usar `DSCardHeader`+`DSCard`+`ResponsiveLayout` |
| `lib/ui/pages/tag_form_page.dart` | Remover `Scaffold`+`AppBar`; adicionar `DSCardHeader` com `actionButton: IconButton(back)`; corpo do form permanece (serve para edição: 4 campos) |

### Arquivos Novos a Criar

| Arquivo | Propósito |
|---|---|
| `lib/ui/widgets/components/mobile/mobile_widget.dart` | `Column` **sem Scaffold**, read-only; `TextField` de busca; `FilterChip` "Apenas ativas"; `ListView.builder` com `TagCard` sem ações |
| `lib/ui/widgets/components/tablet/tablet_widget.dart` | `Scaffold`+`AppBar`+`FAB`; push para `TagFormPage` (editar); dialog `TagCreateDialog` (criar — 3 campos); `GridView.builder` 2 colunas com `TagCard` com ações |
| `lib/ui/widgets/components/desktop/desktop_widget.dart` | Wrapper `ListenableBuilder` → `DesktopTableWidget` |
| `lib/ui/widgets/components/desktop/desktop_table_widget.dart` | `DSDataTableContainer`; colunas: Tag (círculo colorido+nome), Descrição, Status, Ações; criar → `TagCreateDialog`; editar → `Navigator.push(TagFormPage)` |
| `lib/ui/widgets/dialogs/tag_create_dialog.dart` | Dialog com 3 campos (nome, descrição, cor) para criação |
| `lib/ui/widgets/dialogs/tag_delete_confirm_dialog.dart` | AlertDialog confirmação de delete |
| `lib/ui/widgets/dialogs/dialogs.dart` | Barrel export |

### Ordem de Implementação
1. Modificar `tag_form_page.dart` (remover Scaffold, adicionar DSCardHeader com back)
2. Criar `tag_create_dialog.dart`, `tag_delete_confirm_dialog.dart`, `dialogs.dart`
3. Criar `mobile_widget.dart` (read-only)
4. Criar `tablet_widget.dart`
5. Criar `desktop_table_widget.dart`, `desktop_widget.dart`
6. Modificar `tag_list_page.dart`

---

## 3. `notebook_ui` (`packages/notebook/notebook_ui/`)

### Arquivos a Modificar

| Arquivo | O que muda |
|---|---|
| `lib/pages/notebook_list_page.dart` | Remover `Scaffold`+`AppBar`+`FAB`+lógica de ações; usar `DSCardHeader`+`DSCard`+`ResponsiveLayout`; manter `initState` com `loadNotebooks()`+`loadAvailableTags()` |
| `lib/pages/notebook_form_page.dart` | Remover `Scaffold`+`AppBar`; adicionar `DSCardHeader` com `actionButton: IconButton(back)` |
| `lib/pages/notebook_detail_page.dart` | Remover `Scaffold`+`AppBar`; adicionar `DSCardHeader` com `actionButton: IconButton(back)` |

### Arquivos Novos a Criar

| Arquivo | Propósito |
|---|---|
| `lib/ui/widgets/components/mobile/mobile_widget.dart` | `Column` **sem Scaffold**, read-only; busca+filtros por tipo e tags; `ListView.builder` com `NotebookCard` sem ações (apenas tap para detalhe via push) |
| `lib/ui/widgets/components/tablet/tablet_widget.dart` | `Scaffold`+`AppBar`(sort+refresh)+`FAB`; push para `NotebookFormPage`; `GridView.builder` 2 colunas; tap abre detalhe |
| `lib/ui/widgets/components/desktop/desktop_widget.dart` | Wrapper `ListenableBuilder` → `DesktopTableWidget` |
| `lib/ui/widgets/components/desktop/desktop_table_widget.dart` | `DSDataTableContainer`; colunas: Caderno (ícone tipo+título), Tipo, Tags (chips), Data, Ações (editar→push `NotebookFormPage`, deletar→dialog); botão "Novo" → push `NotebookFormPage` |
| `lib/ui/widgets/dialogs/notebook_delete_confirm_dialog.dart` | AlertDialog confirmação de delete |
| `lib/ui/widgets/dialogs/dialogs.dart` | Barrel export |

### Filtros Desktop (`DSTableFilterBar`)
```dart
NotebookType.values.map((type) => DSTableFilter<NotebookDetails>(
  id: 'type_${type.name}',
  label: _getTypeLabel(type),  // 'Rápida' | 'Organizada' | 'Lembrete'
  predicate: (n) => n.type == type,
)).toList()
```

### Ordem de Implementação
1. Modificar `notebook_form_page.dart` e `notebook_detail_page.dart` (remover Scaffold, DSCardHeader+back)
2. Criar `notebook_delete_confirm_dialog.dart`, `dialogs.dart`
3. Criar `mobile_widget.dart` (read-only)
4. Criar `tablet_widget.dart`
5. Criar `desktop_table_widget.dart`, `desktop_widget.dart`
6. Modificar `notebook_list_page.dart`

---

## Widgets do Design System a Reutilizar

- **Layout**: `DSCardHeader`, `DSCard` — `design_system_ui`
- **Responsive**: `ResponsiveLayout` — `core_ui` (mobile < 600, tablet 600–900, desktop ≥ 900)
- **Tabela**: `DSDataTableContainer`, `DSDataTable<T>`, `DSDataTableColumn<T>`, `DSDataTableSortState`
- **Filtros**: `DSTableSearchField`, `DSTableFilterBar`, `DSTableFilter`
- **Células**: `DSTableCellWithIcon`, `DSTableCellTwoLines`, `DSTableStatusIndicator`
- **Seleção**: `DSTableSelectionState<T>`, `DSTableSelectionToolbar`
- **Ações**: `DSTableActions`, `DSTableAction`
- **Paginação**: `DSPagination`, `DSPaginationController<T>`

---

## Arquivos Críticos de Referência

| Arquivo | Uso |
|---|---|
| `packages/school/school_ui/lib/ui/pages/school_page.dart` | Template canônico da página sem Scaffold |
| `packages/school/school_ui/lib/ui/widgets/components/desktop/desktop_table_widget.dart` | Template do `DSDataTableContainer` com sorting/filtros/paginação |
| `packages/school/school_ui/lib/ui/widgets/components/mobile/mobile_widget.dart` | Template do mobile widget |
| `packages/school/school_ui/lib/ui/widgets/components/tablet/tablet_widget.dart` | Template do tablet widget |
| `packages/design_system/design_system_ui/lib/design_system_ui.dart` | Exports de todos os widgets do design system |

---

## Verificação (por pacote)

1. `flutter analyze packages/{pkg}/{pkg}_ui` — zero erros
2. Desktop (≥900px): página de lista mostra `DSCardHeader` + tabela com sorting/filtros/paginação; "Adicionar/Editar" → abre nova página com back button (se form page) ou dialog (se ≤3 campos)
3. Tablet (600–900px): `GridView` com FAB; edit/delete funcionando; formulário abre via push
4. Mobile (<600px): `ListView` sem ações de edição; nenhum botão de criar/editar visível
5. Navegação back em form pages: `DSCardHeader` com `actionButton` de `Icons.arrow_back` funcional
