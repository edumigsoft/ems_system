# Plano: Notebook UI Responsivo + Nova Feature Dashboard

---

## Parte 1 — Notebook UI: Redesign Responsivo

### Contexto

O pacote `notebook_ui` já usa `ResponsiveLayout` (< 600 mobile / 600-899 tablet / ≥ 900 desktop),
mas duas variantes têm aspecto de app mobile em telas maiores:

1. **`TabletWidget`** usa `Scaffold + AppBar + FAB` dentro da estrutura `DSCard + DSCardHeader`
   da `NotebookListPage` → header duplicado + padrão de navegação mobile em tablet.

2. **`TabletWidget` e `DesktopTableWidget`** usam `Navigator.push(MaterialPageRoute(...))`
   para criar, editar e detalhar notebooks. Os dialogs `NotebookCreateDialog` e `NotebookEditDialog`
   já existem (usados em `NotebookListPage` e `NotebookDetailPage`) mas não nas variantes.

3. **Desktop** não possui layout master-detail — todas as ações abandonam a tela atual.

**Objetivo:** Mobile read-only; Tablet e Desktop com layout master-detail nativo, CRUD via dialogs.

---

### Arquivos de Referência

| Arquivo | Papel |
|---------|-------|
| `lib/pages/notebook_list_page.dart:82` | `ResponsiveLayout` principal — modificar |
| `lib/ui/widgets/components/tablet/tablet_widget.dart` | Remover Scaffold/FAB — refatorar |
| `lib/ui/widgets/components/desktop/desktop_table_widget.dart` | Adicionar callbacks — modificar |
| `lib/ui/widgets/components/desktop/desktop_widget.dart` | Substituir por split widget |
| `lib/widgets/notebook_create_dialog.dart` | Reutilizar para criar via `showDialog()` |
| `lib/widgets/notebook_edit_dialog.dart` | Reutilizar para editar via `showDialog()` |
| `packages/core/core_ui/lib/ui/widgets/responsive_layout.dart` | Breakpoints: 600 / 900 |

---

### Mudanças

#### 1. Refatorar `tablet_widget.dart` — Remover aspecto mobile

- Remover `Scaffold`, `AppBar` e `FloatingActionButton`
- Adicionar toolbar inline (sem Scaffold):
  ```
  Row: [ TextField busca ] + [ PopupMenu sort ] + [ ElevatedButton "Novo Caderno" ]
  ```
- Criar via `showDialog(... builder: (_) => const NotebookCreateDialog())`
- Editar via `showDialog(... builder: (_) => NotebookEditDialog(notebook: n, viewModel: vm))`
- Manter `GridView` 2 colunas com `NotebookCard` + tap para detalhe

#### 2. Modificar `desktop_table_widget.dart` — Adicionar callbacks opcionais

Adicionar parâmetros opcionais para desacoplar navegação:

```dart
final VoidCallback? onCreateTap;                              // null → push MaterialPageRoute
final void Function(NotebookDetails)? onEditTap;             // null → push MaterialPageRoute
final void Function(NotebookDetails)? onViewTap;             // null → push MaterialPageRoute
```

Se callback fornecido → chama callback; senão → comportamento atual (retro-compatível).

#### 3. Criar `desktop_split_widget.dart` — Layout Master-Detail

**Arquivo:** `lib/ui/widgets/components/desktop/desktop_split_widget.dart`

```
┌────────────────────────────────────────────────────────┐
│                  DSCardHeader (existente)               │
├──────────────────────┬─────────────────────────────────┤
│ Painel Esquerdo (45%)│ Painel Direito (55%)            │
│                      │                                  │
│ DesktopTableWidget   │  _EmptyDetailPanel               │
│ (com callbacks)      │  ou                              │
│                      │  conteúdo de NotebookDetailPage  │
│                      │  (sem Scaffold/DSCardHeader)     │
└──────────────────────┴─────────────────────────────────┘
```

- Estado interno: `NotebookDetails? _selectedNotebook`
- `onViewTap(notebook)` → atualiza `_selectedNotebook` → painel direito renderiza detalhe
- `onCreateTap()` → `showDialog(NotebookCreateDialog())` → recarrega lista
- `onEditTap(n)` → `showDialog(NotebookEditDialog(...))` → recarrega lista
- Painel direito vazio: `_EmptyDetailPlaceholder` com ícone + instrução

#### 4. Atualizar `notebook_list_page.dart`

```dart
ResponsiveLayout(
  mobile: MobileWidget(viewModel: widget.viewModel),     // inalterado
  tablet: DesktopSplitWidget(viewModel: widget.viewModel), // novo
  desktop: DesktopSplitWidget(viewModel: widget.viewModel), // novo
)
```

Remove o `actionButton` do `DSCardHeader` (o botão de criar migra para o split widget).

---

### Arquivos — Parte 1

| Arquivo | Ação |
|---------|------|
| `lib/ui/widgets/components/tablet/tablet_widget.dart` | Refatorar (remover Scaffold/FAB/push) |
| `lib/ui/widgets/components/desktop/desktop_table_widget.dart` | Modificar (callbacks opcionais) |
| `lib/ui/widgets/components/desktop/desktop_split_widget.dart` | **Criar** (master-detail) |
| `lib/pages/notebook_list_page.dart` | Modificar (tablet+desktop → DesktopSplitWidget) |

---

## Parte 2 — Nova Feature: Dashboard Configurável

### Contexto

O app precisa de uma página Dashboard que agregue widgets de qualquer feature registrada.
Atualmente existem `notebook` e `tag`; no futuro virão mais features.
A solução deve ser configurável via injeção de dependência — cada módulo declara seus widgets.

---

### Arquitetura

O padrão adota a interface `AppModule` existente em `core_ui` como ponto de extensão,
e uma camada de registro em `core_ui`. O pacote `dashboard_ui` fornece a página.

```
core_ui (modificar)
└── DashboardWidgetEntry     ← interface que feature UIs implementam
└── DashboardRegistry        ← singleton que coleta os widgets registrados

packages/dashboard/          ← novo pacote (apenas _ui, pois é puramente frontend)
└── dashboard_ui/
    ├── DashboardPage        ← página responsiva que lê o DashboardRegistry
    ├── DashboardViewModel   ← obtém widgets do registry
    ├── DashboardModule      ← registra página, rota, nav item
    └── DashboardWidgetCard  ← card padrão de container para cada entry

notebook_ui (modificar)
└── NotebookRemindersEntry   ← implementa DashboardWidgetEntry
└── NotebookQuickNotesEntry  ← implementa DashboardWidgetEntry
└── NotebookModule           ← registra as duas entries no DashboardRegistry

apps/ems/app_v1 (modificar)
└── injector.dart            ← adiciona DashboardModule à lista de módulos
```

---

### Detalhes de Implementação

#### A. `core_ui` — Adicionar `DashboardWidgetEntry` e `DashboardRegistry`

```dart
// packages/core/core_ui/lib/core/dashboard/dashboard_widget_entry.dart
abstract class DashboardWidgetEntry {
  String get id;       // Identificador único (ex: 'notebook_reminders')
  String get title;    // Título exibido no card
  IconData get icon;   // Ícone do card
  Widget build(BuildContext context);
}

// packages/core/core_ui/lib/core/dashboard/dashboard_registry.dart
class DashboardRegistry {
  final List<DashboardWidgetEntry> _entries = [];
  void register(DashboardWidgetEntry entry) => _entries.add(entry);
  List<DashboardWidgetEntry> get entries => List.unmodifiable(_entries);
}
```

Exportar de `core_ui.dart`.

#### B. Novo pacote `packages/dashboard/dashboard_ui`

> **Posição no monorepo:** `packages/dashboard/dashboard_ui/`
> — e não em `design_system/`, pois `design_system` contém primitivas visuais
> (tokens, componentes, temas), enquanto Dashboard é uma **feature de aplicação**.
> Seguindo ADR-0005, mesmo que apenas a variante `_ui` exista agora, a pasta pai
> `packages/dashboard/` permite adicionar `dashboard_server` (analytics/stats) no futuro
> sem mover arquivos. Análogo a `images/` (1/4) e `open_api/` (2/4) que mantêm a pasta pai.

Estrutura mínima:
```
dashboard_ui/
├── pubspec.yaml
└── lib/
    ├── dashboard_ui.dart          (exports)
    ├── dashboard_module.dart      (AppModule)
    ├── pages/
    │   └── dashboard_page.dart    (ResponsiveLayout mobile/desktop)
    ├── view_models/
    │   └── dashboard_view_model.dart
    └── widgets/
        └── dashboard_widget_card.dart  (card container padrão)
```

**`DashboardPage`** usa `ResponsiveLayout`:
- **Mobile** (< 600 px): `ListView` de cards (largura total), um por linha
- **Tablet/Desktop** (≥ 600 px): `Wrap` ou `GridView` — 2 colunas no tablet, 3 no desktop

**`DashboardWidgetCard`**: card com `DSCard + DSCardHeader(title, icon)` + conteúdo do entry.

**`DashboardModule`**:
```dart
static const String routeName = '/dashboard';

@override Map<String, Widget> get routes => { routeName: di.get<DashboardPage>() };

@override List<AppNavigationItem> get navigationItems => [
  AppNavigationItem(
    labelBuilder: (_) => 'Dashboard',
    icon: Icons.dashboard,
    section: AppNavigationSection.dashboard,
    route: routeName,
  ),
];
```

#### C. Notebook UI — Implementar `DashboardWidgetEntry`

**`NotebookRemindersEntry`** (`lib/dashboard/notebook_reminders_entry.dart`):
- Título: "Lembretes"
- Mostra: vencidos (badge vermelho) + próximos 3 itens com data
- Tap no item → `Navigator.push` para `NotebookDetailPage`

**`NotebookQuickNotesEntry`** (`lib/dashboard/notebook_quick_notes_entry.dart`):
- Título: "Notas Rápidas"
- Mostra: últimas 3 notas rápidas com trecho do conteúdo
- Tap no item → `Navigator.push` para `NotebookDetailPage`

Ambas dependem de `NotebookApiService` (injetado pelo `NotebookModule`).

**`NotebookModule.registerDependencies()`** — adicionar ao final:

```dart
final registry = di.get<DashboardRegistry>();
registry.register(NotebookRemindersEntry(service: di.get<NotebookApiService>()));
registry.register(NotebookQuickNotesEntry(service: di.get<NotebookApiService>()));
```

#### D. App `injector.dart` — Registrar DashboardRegistry e DashboardModule

```dart
// Antes dos módulos de feature:
di.registerSingleton<DashboardRegistry>(DashboardRegistry());

// Na lista de módulos:
final List<AppModule> appModules = [
  UserModule(di: _diMain),
  AuthModule(di: _diMain),
  TagModule(di: _diMain),
  NotebookModule(di: _diMain),
  DashboardModule(di: _diMain), // ← novo (registrar por último)
];
```

---

### Arquivos — Parte 2

**Novos:**
| Arquivo | Descrição |
|---------|-----------|
| `packages/core/core_ui/lib/core/dashboard/dashboard_widget_entry.dart` | Interface abstrata |
| `packages/core/core_ui/lib/core/dashboard/dashboard_registry.dart` | Registry singleton |
| `packages/dashboard/dashboard_ui/pubspec.yaml` | Novo pacote |
| `packages/dashboard/dashboard_ui/lib/dashboard_module.dart` | AppModule |
| `packages/dashboard/dashboard_ui/lib/pages/dashboard_page.dart` | Página responsiva |
| `packages/dashboard/dashboard_ui/lib/view_models/dashboard_view_model.dart` | ViewModel |
| `packages/dashboard/dashboard_ui/lib/widgets/dashboard_widget_card.dart` | Card container |
| `packages/notebook/notebook_ui/lib/dashboard/notebook_reminders_entry.dart` | Entry reminders |
| `packages/notebook/notebook_ui/lib/dashboard/notebook_quick_notes_entry.dart` | Entry quick notes |

**Modificados:**
| Arquivo | Mudança |
|---------|---------|
| `packages/core/core_ui/lib/core_ui.dart` | Exportar DashboardWidgetEntry + DashboardRegistry |
| `packages/notebook/notebook_ui/lib/notebook_module.dart` | Registrar entries no registry |
| `packages/notebook/notebook_ui/lib/notebook_ui.dart` | Exportar entries |
| `pubspec.yaml` (root workspace) | Adicionar `dashboard_ui` aos membros |
| `apps/ems/app_v1/pubspec.yaml` | Adicionar dependência `dashboard_ui` |
| `apps/ems/app_v1/lib/config/di/injector.dart` | Registrar DashboardRegistry + DashboardModule |

---

## Verificação (ambas as partes)

1. `dart analyze` em `packages/core/core_ui`
2. `dart analyze` em `packages/notebook/notebook_ui`
3. `dart analyze` em `packages/dashboard/dashboard_ui`
4. `flutter analyze` em `apps/ems/app_v1`
5. Checklist visual:
   - **Mobile**: lista read-only, tap navega para detalhe
   - **Tablet**: sem AppBar própria, toolbar integrada, criar/editar via dialog, grid 2 colunas
   - **Desktop**: tabela à esquerda, painel de detalhe à direita, criar/editar via dialog
   - **Dashboard (mobile)**: cards empilhados, reminders + quick notes
   - **Dashboard (tablet/desktop)**: grid de cards, responsivo por número de colunas
   - Novo módulo registrável sem alterar `core_ui` novamente
