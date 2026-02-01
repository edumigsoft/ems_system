# Plano: CRUD Completo para School UI

## Contexto

O pacote `packages/school/school_ui` já possui **CRUD funcionalmente completo** (Create, Read, Update, Delete, Restore) mas com **inconsistências de integração e código deprecated**:

**Estado Atual:**
- ✅ Mobile/Tablet: Funcionando bem com formulários modernos
- ⚠️ Desktop: Tabela excelente, mas create/edit não integrados
- ❌ `DesktopEditItemWidget`: Usa `zard_form` (DEPRECATED), não está integrado
- ❌ `DesktopViewItemWidget`: Existe mas não está sendo usado
- ❌ Sem botão "Adicionar Escola" visível

**Componentes Modernos Já Existentes:**
- `SchoolFormWidget`: Form moderno com `FormValidationMixin` ✅
- `SchoolFormViewModel`: Gerenciamento de estado completo ✅
- `SchoolViewModel`: CRUD commands via use cases ✅

## Objetivo

Completar a integração do CRUD no desktop e adicionar pontos de entrada para criação em todas as plataformas, seguindo padrões do projeto (notebook_ui, tag_ui).

## Abordagem Arquitetural

**Padrão Escolhido: Dialog-Based Create/Edit (Desktop)**

**Justificativa:**
- ✅ Consistente com `notebook_ui` (usa dialogs)
- ✅ Mantém contexto da tabela (filtros, ordenação, paginação)
- ✅ Workflow rápido sem navegação
- ✅ Reutiliza `SchoolFormWidget` existente (zero duplicação)
- ✅ UX moderna para gerenciamento de dados

## Fases de Implementação

### **FASE 1: Criar Dialog Wrapper** 🆕

**Arquivo a criar:** `lib/ui/widgets/dialogs/school_form_dialog.dart`

Criar widget de dialog que:
- Envolve `SchoolFormWidget` em `Dialog` responsivo
- Suporta modo create (`initialData = null`) e edit (`initialData = school`)
- Constraints: `maxWidth: 600px`, `maxHeight: 90vh`
- Inclui título dinâmico (`l10n.createSchool` vs `l10n.editSchool`)
- Scroll automático se conteúdo exceder altura
- Retorna `SchoolDetails?` ao fechar (null se cancelado)

**Assinatura esperada:**
```dart
class SchoolFormDialog extends StatelessWidget {
  final CreateUseCase createUseCase;
  final UpdateUseCase updateUseCase;
  final SchoolDetails? initialData;

  const SchoolFormDialog({
    required this.createUseCase,
    required this.updateUseCase,
    this.initialData,
  });
}
```

**Barrel export:** `lib/ui/widgets/dialogs/dialogs.dart`

---

### **FASE 2: Integrar Create no Desktop** 🔧

**2.1 - Adicionar botão "Adicionar Escola" na tabela**

**Arquivo:** `lib/ui/widgets/components/desktop/desktop_table_widget.dart`

**Mudanças:**
- Adicionar `ElevatedButton.icon` próximo ao botão de refresh (~linha 284)
- Label: "Adicionar Escola" + Icon: `Icons.add`
- Callback: `_showCreateDialog()`

**2.2 - Implementar método `_showCreateDialog()`**

```dart
Future<void> _showCreateDialog() async {
  final createUseCase = GetIt.I<CreateUseCase>();
  final updateUseCase = GetIt.I<UpdateUseCase>();

  final result = await showDialog<SchoolDetails>(
    context: context,
    builder: (context) => SchoolFormDialog(
      createUseCase: createUseCase,
      updateUseCase: updateUseCase,
    ),
  );

  if (result != null && mounted) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.schoolCreateSuccess)),
    );
    widget.viewModel.fetchAllCommand.execute();
  }
}
```

---

### **FASE 3: Integrar Edit no Desktop** 🔧

**Arquivo:** `lib/ui/widgets/components/desktop/desktop_table_widget.dart`

**Mudanças:**
- Modificar método `_editSchool(SchoolDetails school)` (existente ~linha 182)
- Substituir lógica atual por abertura de dialog:

```dart
Future<void> _editSchool(SchoolDetails school) async {
  final createUseCase = GetIt.I<CreateUseCase>();
  final updateUseCase = GetIt.I<UpdateUseCase>();

  final result = await showDialog<SchoolDetails>(
    context: context,
    builder: (context) => SchoolFormDialog(
      createUseCase: createUseCase,
      updateUseCase: updateUseCase,
      initialData: school, // ← Modo de edição
    ),
  );

  if (result != null && mounted) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.schoolUpdateSuccess)),
    );
    widget.viewModel.fetchAllCommand.execute();
  }
}
```

---

### **FASE 4: Adicionar Create em Mobile/Tablet** 🔧

**4.1 - Mobile**

**Arquivo:** `lib/ui/widgets/components/mobile/mobile_widget.dart`

**Mudanças:**
- Adicionar `FloatingActionButton` no `Scaffold`:
  ```dart
  floatingActionButton: FloatingActionButton(
    onPressed: _navigateToCreate,
    child: const Icon(Icons.add),
  ),
  ```

- Implementar navegação:
  ```dart
  Future<void> _navigateToCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SchoolEditPage(
          viewModel: widget.viewModel,
          school: null, // ← Create mode
        ),
      ),
    );

    if (result == true && mounted) {
      widget.viewModel.fetchAllCommand.execute();
    }
  }
  ```

**4.2 - Tablet**

**Arquivo:** `lib/ui/widgets/components/tablet/tablet_widget.dart`

Implementar lógica idêntica ao mobile (FAB + navegação).

**4.3 - Atualizar SchoolEditPage para modo create**

**Arquivo:** `lib/ui/pages/school_edit_page.dart`

**Mudanças:**
- Tornar parâmetro `school` opcional (`SchoolDetails? school`)
- Título dinâmico:
  ```dart
  title: Text(widget.school == null ? AppLocalizations.of(context).createSchool : AppLocalizations.of(context).editSchool)
  ```
- Passar `initialData: widget.school` para `SchoolFormWidget`

---

### **FASE 5: Remover Código Deprecated** 🗑️

**5.1 - Deletar DesktopEditItemWidget**

**Arquivo a deletar:** `lib/ui/widgets/components/desktop/desktop_edit_item_widget.dart`

**Motivo:** Usa `zard_form` (deprecated), substituído por `SchoolFormDialog`

**5.2 - Limpar imports e referências**

- Remover import de `desktop_edit_item_widget.dart` em `desktop_widget.dart` (se existir)
- Remover código comentado em `desktop_widget.dart` (linhas 19-26)

**5.3 - Remover dependência zard_form**

**Arquivo:** `pubspec.yaml`

Remover `zard_form` das dependencies (após confirmar que não há mais usos).

**Verificação:**
```bash
cd packages/school/school_ui
grep -r "zard_form" lib/
# Deve retornar vazio após cleanup
```

---

Substituir strings hardcoded por `AppLocalizations.of(context)`.

**Novas chaves adicionadas em `packages/localizations/localizations_ui/l10n/`:**
- `schoolCreateSuccess`: "Escola criada com sucesso!"
- `schoolUpdateSuccess`: "Escola atualizada com sucesso!"
- `schoolDeleteSuccess`: "Escola excluída!"
- `schoolRestoreSuccess`: "Escola restaurada com sucesso!"
- `schoolDeleteConfirm`: "Deseja realmente excluir a escola?"
- `schoolRestoreConfirm`: "Deseja restaurar a escola?"

**Comando para girar localização:**
```bash
cd packages/localizations/localizations_ui
flutter gen-l10n
```

**6.2 - Extrair dialogs de confirmação**

Criar widgets reutilizáveis:
- `lib/ui/widgets/dialogs/school_delete_confirm_dialog.dart`
- `lib/ui/widgets/dialogs/school_restore_confirm_dialog.dart`

Atualizar usos em `mobile_widget.dart`, `tablet_widget.dart`, `desktop_table_widget.dart`.

---

## Arquivos Críticos

### Novos
1. `lib/ui/widgets/dialogs/school_form_dialog.dart` - Dialog wrapper
2. `lib/ui/widgets/dialogs/dialogs.dart` - Barrel export

### Modificados
3. `lib/ui/widgets/components/desktop/desktop_table_widget.dart` - Add create button, integrate dialogs
4. `lib/ui/widgets/components/mobile/mobile_widget.dart` - Add FAB
5. `lib/ui/widgets/components/tablet/tablet_widget.dart` - Add FAB
6. `lib/ui/pages/school_edit_page.dart` - Support create mode
7. `pubspec.yaml` - Remove zard_form dependency

### Deletados
8. `lib/ui/widgets/components/desktop/desktop_edit_item_widget.dart` - Deprecated (uses zard_form)

### Referência (não modificar)
9. `lib/ui/widgets/forms/school_form_widget.dart` - Modern form (will be wrapped in dialog)
10. `lib/ui/view_models/school_form_view_model.dart` - Form state management

---

## Estratégia de Testes

### Testes Unitários
- **Novo:** `test/ui/widgets/dialogs/school_form_dialog_test.dart`
  - Renderização em modo create
  - Renderização em modo edit
  - Retorno de dados ao fechar
  - Tratamento de cancelamento

### Testes de Widget
- Estender `test/ui/widgets/components/desktop/desktop_table_widget_test.dart`:
  - Botão de create visível
  - Dialog abre ao clicar
  - Feedback após sucesso

### Checklist de Teste Manual

**Desktop:**
- [ ] Botão "Adicionar Escola" visível e funcional
- [ ] Dialog abre com formulário vazio (create)
- [ ] Validação funciona no dialog
- [ ] Criar escola adiciona à tabela
- [ ] SnackBar de sucesso aparece
- [ ] Ícone de editar abre dialog com dados pré-preenchidos
- [ ] Editar escola atualiza tabela
- [ ] Filtros/ordenação persistem após criar/editar

**Mobile:**
- [ ] FAB visível
- [ ] FAB navega para página de criação
- [ ] Título = "Criar Escola"
- [ ] Criação funciona e retorna à lista

**Tablet:**
- [ ] Mesmo que mobile (layout grid)

**Análise:**
- [ ] `flutter analyze` → 0 erros
- [ ] Sem imports de `zard_form`

---

## Verificação Final

### Antes de Começar
```bash
cd /home/anderson/Projects/Working/ems_system/packages/school/school_ui
flutter analyze
flutter test
```

### Após Completar Cada Fase
```bash
flutter analyze
# Verificar 0 issues antes de prosseguir
```

### Após Conclusão
```bash
# Verificar que zard_form foi removido
grep -r "zard_form" lib/
# Resultado esperado: vazio

# Executar testes
flutter test

# Executar app de demonstração
cd ../../../../apps/ems/app_v1 # ou app_design_draft
flutter run
```

---

## Trade-offs e Decisões

### Dialog vs Full Page (Desktop)
- **Escolhido:** Dialog
- **Motivo:** Mantém contexto, workflow rápido, padrão do projeto
- **Trade-off aceito:** Espaço limitado (mitigado: form é compacto)

### Reusar SchoolFormWidget vs Criar Novo
- **Escolhido:** Reusar
- **Motivo:** DRY, mesma validação, manutenibilidade
- **Benefício:** Zero duplicação de código

### Quando Remover zard_form
- **Escolhido:** Após deletar DesktopEditItemWidget
- **Verificação:** Confirmar que não há outros usos no pacote

---

## Notas de Implementação

1. **GetIt/DI:** Use `GetIt.I.get<T>()` para obter use cases nos dialogs
2. **Mounted checks:** Sempre verificar `if (mounted)` antes de `setState`/`SnackBar`
3. **Refresh:** Chamar `widget.viewModel.fetchAllCommand.execute()` após CUD
4. **L10n:** Usar `AppLocalizations.of(context)` para todas as strings de interface e mensagens.
5. **Result Pattern:** SchoolFormWidget já retorna `Result<SchoolDetails>` via callbacks

---

## Critério de Sucesso

### Funcional
- ✅ Criar escola funciona em desktop (dialog), mobile, tablet (page)
- ✅ Editar escola funciona em desktop (dialog), mobile, tablet (page)
- ✅ Feedback visual (SnackBar) após operações
- ✅ Tabela/lista atualiza após criar/editar

### Técnico
- ✅ Zero dependências de `zard_form`
- ✅ `flutter analyze` sem erros
- ✅ Código deprecated removido
- ✅ Padrões consistentes com notebook_ui

### UX
- ✅ Botões de create visíveis em todas as plataformas
- ✅ Validação funciona corretamente
- ✅ Experiência fluída sem perda de contexto (desktop)
