# Plano de Refatoração: Validação de Formulários

**Data de Criação:** 2026-01-31
**Status:** Em andamento
**Versão:** 1.0.0

---

## 📋 Contexto

O projeto atualmente possui três abordagens de validação de formulários coexistindo:

1. **CoreValidator** (core_shared) - Interface abstrata para validação
2. **FormValidationMixin** (core_ui) - Mixin que usa Zard diretamente (validação simples)
3. **zard_form** (pacote wrapper) - Gerenciamento completo de estado de formulários

**Problema:** `zard_form` expõe o Zard diretamente na UI, quebrando a camada de abstração que o `FormValidationMixin` deveria fornecer.

**Solução:** Expandir `FormValidationMixin` para ser a solução completa de validação + gerenciamento de estado, isolando completamente o Zard.

---

## 🎯 Objetivos

### Primários:
- ✅ Isolar completamente o Zard (permitir substituição futura)
- ✅ Manter schema em `*_shared` (Dart puro, usado em UI e servidor)
- ✅ Gerenciar estado completo de formulários (erros, dirty, touched, controllers)
- ✅ Consistência com Result Pattern do projeto

### Secundários:
- ✅ Remover dependência de `zard_form` (após validações)
- ✅ Documentar novo padrão em ADRs e guias

---

## 📐 Arquitetura Alvo

```
*_shared (Dart Puro)
  └─ FeatureValidator extends CoreValidator
      ├─ schema (static ZMap) ← Usado por FormValidationMixin
      └─ validate(T) → CoreValidationResult

core_ui (Abstração)
  └─ FormValidationMixin ← CAMADA DE ISOLAMENTO COMPLETA
      ├─ Registra campos (registerField)
      ├─ Gerencia TextEditingControllers
      ├─ Gerencia erros por campo
      ├─ Gerencia dirty/touched state
      ├─ Valida usando schema (isolando Zard)
      └─ Submete formulário com validação

*_ui (Consumidores)
  ├─ ViewModels with FormValidationMixin
  │   └─ NUNCA importam Zard ou zard_form
  └─ Widgets
      └─ ListenableBuilder + ViewModel
```

---

## 🗓️ Etapas de Implementação

### ✅ Etapa 0: Planejamento e Análise
- [x] Análise da arquitetura atual
- [x] Identificação de problemas
- [x] Proposta de solução
- [x] Aprovação do plano
- [x] Criação deste documento

### ✅ Etapa 1: Expandir FormValidationMixin
**Status:** Concluída
**Arquivo:** `packages/core/core_ui/lib/core/mixins/form_validation_mixin.dart`

**Alterações Implementadas:**
1. ✅ Gerenciamento de TextEditingControllers
   - `Map<String, TextEditingController> _controllers`
   - `registerField(String name, {String? initialValue, bool validateOnChange})`
   - `getFieldValue(String name)`
   - `setFieldValue(String name, String value)`

2. ✅ Gerenciamento de erros por campo
   - `Map<String, String?> _errors`
   - `getFieldError(String name)`
   - `setFieldError(String name, String error)`
   - `clearErrors([String? name])`

3. ✅ Gerenciamento de estado
   - `Map<String, bool> _dirtyFields`
   - `Map<String, bool> _touchedFields`
   - `bool _isSubmitting`
   - `bool _isValidating`
   - Getters: `isFormDirty`, `hasErrors`, `isSubmitting`, `isFormValid`
   - Métodos auxiliares: `isFieldDirty()`, `isFieldTouched()`, `setFieldTouched()`

4. ✅ Método de submit com validação integrada
   - `submitForm<T>({data, schema, onValid})`
   - Valida antes de executar callback
   - Gerencia estado de loading
   - Limpa dirty state em sucesso

5. ✅ Métodos de lifecycle
   - `resetForm([Map<String, String>? initialValues])`
   - `disposeFormResources()`

6. ✅ Mapeamento automático de erros do Zard para estado interno

**Critérios de Aceitação:**
- [x] FormValidationMixin gerencia estado completo
- [x] Zard permanece isolado (não exposto)
- [ ] Testes unitários passando (pendente)
- [x] Documentação inline completa (DartDoc com exemplos)
- [x] Zero avisos de análise
- [x] CHANGELOG atualizado
- [x] README atualizado com exemplos completos

### ⏳ Etapa 2: Criar ViewModel de Exemplo
**Status:** Pendente
**Arquivo:** `packages/school/school_ui/lib/ui/view_models/school_form_view_model.dart`

**Alterações:**
1. Criar `SchoolFormViewModel extends ChangeNotifier with FormValidationMixin`
2. Registrar campos no construtor
3. Implementar método `submit()`
4. Implementar dispose com `disposeFormResources()`

**Critérios de Aceitação:**
- [ ] ViewModel funcional
- [ ] Não importa zard_form
- [ ] Usa apenas FormValidationMixin
- [ ] Testes unitários

### ⏳ Etapa 3: Migrar SchoolFormWidget
**Status:** Pendente
**Arquivo:** `packages/school/school_ui/lib/ui/widgets/forms/school_form_widget.dart`

**Alterações:**
1. Remover dependência de `zard_form`
2. Usar `SchoolFormViewModel`
3. Usar `ListenableBuilder` ao invés de `ZFormBuilder`
4. Usar `viewModel.registerField()` ao invés de `form.register()`
5. Usar `viewModel.getFieldError()` ao invés de `state.errors`

**Critérios de Aceitação:**
- [ ] Widget funcional
- [ ] Não importa zard_form
- [ ] UX equivalente ou melhor
- [ ] Testes de widget

### ⏳ Etapa 4: Migrar NotebookFormPage
**Status:** Pendente
**Arquivo:** `packages/notebook/notebook_ui/lib/pages/notebook_form_page.dart`

**Alterações:**
1. Criar `NotebookFormViewModel with FormValidationMixin`
2. Migrar de `GlobalKey<FormState>` para ViewModel
3. Usar padrão consistente com SchoolFormWidget

**Critérios de Aceitação:**
- [ ] Formulário funcional
- [ ] Usa FormValidationMixin
- [ ] Consistente com novo padrão

### ⏳ Etapa 5: Atualizar Documentação
**Status:** Pendente

**Arquivos a atualizar:**
1. `docs/adr/0004-use-form-validation-mixin-and-zard.md`
   - Adicionar seção sobre gerenciamento de estado
   - Documentar novo padrão de uso
   - Exemplos de código atualizados

2. `docs/rules/new_feature.md`
   - Adicionar template de ViewModel com FormValidationMixin
   - Adicionar exemplo de widget de formulário
   - Atualizar seção de validação

3. `CLAUDE.md`
   - Atualizar seção "Validação de Formulários"
   - Remover menção a zard_form como solução primária
   - Adicionar exemplo de uso do FormValidationMixin

4. `packages/core/core_ui/README.md`
   - Documentar FormValidationMixin expandido
   - Exemplos de uso
   - Migration guide de zard_form

**Critérios de Aceitação:**
- [ ] Toda documentação atualizada
- [ ] Exemplos testados e funcionais
- [ ] Migration guide completo

### ⏳ Etapa 6: Validação e Testes
**Status:** Pendente

**Atividades:**
1. Testes unitários de FormValidationMixin
2. Testes de integração com ViewModels
3. Testes de widgets
4. Validação manual em diferentes cenários
5. Code review

**Critérios de Aceitação:**
- [ ] Cobertura de testes > 80%
- [ ] Todos os testes passando
- [ ] Validação manual OK
- [ ] Code review aprovado

### ⏳ Etapa 7: Remoção de zard_form (MANUAL)
**Status:** Pendente
**Ação:** MANUAL - Após validação completa

**Atividades:**
1. Verificar que nenhum pacote usa zard_form
2. Remover pacote `packages/zard_form/`
3. Remover entrada do `pubspec.yaml` raiz
4. Executar `./scripts/pub_get_all.sh`
5. Verificar build completo

**Critérios de Aceitação:**
- [ ] zard_form não é mais usado
- [ ] Build passa sem erros
- [ ] Todos os testes passam
- [ ] Apps funcionam normalmente

---

## 📊 Checklist Geral

### Implementação
- [x] **Etapa 1: Expandir FormValidationMixin** ✅
- [ ] Etapa 2: Criar ViewModel de exemplo
- [ ] Etapa 3: Migrar SchoolFormWidget
- [ ] Etapa 4: Migrar NotebookFormPage
- [ ] Etapa 5: Atualizar documentação
- [ ] Etapa 6: Validação e testes

### Validação
- [ ] Zero avisos de análise (`dart analyze`)
- [ ] Cobertura de testes adequada
- [ ] Build de apps funcionando
- [ ] Validação manual OK
- [ ] Code review aprovado

### Remoção (MANUAL)
- [ ] Etapa 7: Remover zard_form

---

## 🔍 Pontos de Atenção

### 1. Compatibilidade com ChangeNotifier
`FormValidationMixin` usa `on ChangeNotifier` - ViewModels devem estender `ChangeNotifier`.

### 2. Isolamento do Zard
O Zard deve permanecer como detalhe de implementação em `FormValidationMixin`. Nenhum código externo deve importar `package:zard/zard.dart` diretamente.

### 3. Schema em *_shared
Schemas permanecem em `*_shared` (Dart puro) para serem usados tanto em UI quanto em servidor/UseCases.

### 4. Result Pattern
Todos os métodos de validação/submit retornam `Result<T>` para consistência com o padrão do projeto.

### 5. Backward Compatibility
Durante migração, zard_form e FormValidationMixin coexistem. Apenas após validação completa o zard_form é removido.

---

## 📚 Referências

### ADRs Relacionados
- `docs/adr/0001-use-result-pattern-for-error-handling.md` - Result Pattern
- `docs/adr/0004-use-form-validation-mixin-and-zard.md` - Validação com Zard
- `docs/adr/0005-standard-package-structure.md` - Estrutura de pacotes

### Arquivos Chave
- `packages/core/core_shared/lib/src/validators/validators.dart` - CoreValidator
- `packages/core/core_ui/lib/core/mixins/form_validation_mixin.dart` - FormValidationMixin
- `packages/zard_form/` - Pacote a ser removido
- `packages/school/school_ui/lib/ui/widgets/forms/school_form_widget.dart` - Exemplo atual

### Exemplos de Validadores
- `packages/school/school_shared/lib/src/validators/school_validators.dart`
- `packages/user/user_shared/lib/src/validators/user_validators_zard.dart`

---

## 📝 Log de Mudanças

### 2026-01-31

#### Manhã
- ✅ Criação do plano
- ✅ Análise completa da arquitetura atual
- ✅ Definição da solução
- ✅ Aprovação do plano

#### Tarde
- ✅ **Etapa 1 CONCLUÍDA:** Expandir FormValidationMixin
  - ✅ Implementação completa de gerenciamento de estado
  - ✅ Isolamento do Zard mantido
  - ✅ Documentação inline com exemplos
  - ✅ Zero avisos de análise (flutter analyze)
  - ✅ CHANGELOG atualizado (v1.1.0)
  - ✅ README atualizado com exemplos completos
- 🔄 **Próximo:** Etapa 2 - Criar ViewModel de exemplo (SchoolFormViewModel)

---

## 🎯 Definição de Pronto

Este refactor será considerado completo quando:

1. ✅ `FormValidationMixin` gerencia estado completo de formulários
2. ✅ Zard está completamente isolado (não exposto)
3. ✅ Todos os formulários migrados para novo padrão
4. ✅ Documentação atualizada e completa
5. ✅ Testes com cobertura adequada (>80%)
6. ✅ Zero avisos de análise
7. ✅ Validação manual aprovada
8. ✅ `zard_form` removido (manual, após validações)

---

**Responsável:** Claude Code
**Última Atualização:** 2026-01-31
