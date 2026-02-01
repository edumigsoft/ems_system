# Pendências de Testes - Form Validation Refactor

**Data:** 2026-01-31
**Contexto:** Etapa 6 - Validação e Testes (Parcialmente Concluída)

---

## 📊 Status Geral

| Componente | Testes | Passando | Falhando | % Sucesso |
|------------|--------|----------|----------|-----------|
| **FormValidationMixin** | 38 | 38 ✅ | 0 | **100%** |
| **SchoolFormViewModel** | 12 | 9 ✅ | 3 ❌ | **75%** |
| **NotebookFormViewModel** | - | - | - | **Não criado** |

---

## ✅ Componentes Completos

### FormValidationMixin (core_ui)
**Arquivo:** `packages/core/core_ui/test/core/mixins/form_validation_mixin_test.dart`
**Status:** ✅ **100% dos testes passando (38/38)**

**Cobertura de testes:**
- ✅ Registro de Campos (4 testes)
- ✅ Getters e Setters (3 testes)
- ✅ Gerenciamento de Erros (7 testes)
- ✅ Estado Dirty/Touched (6 testes)
- ✅ Validação de Formulários (4 testes)
- ✅ Submit de Formulários (5 testes)
- ✅ Reset de Formulários (5 testes)
- ✅ Dispose de Recursos (1 teste)
- ✅ Notificações de Mudanças (3 testes)

---

## ⚠️ Componentes com Pendências

### SchoolFormViewModel (school_ui)
**Arquivo:** `packages/school/school_ui/test/ui/view_models/school_form_view_model_test.dart`
**Status:** ⚠️ **75% dos testes passando (9/12)**

#### ✅ Testes Passando (9):
1. ✅ Inicialização em modo criação
2. ✅ Inicialização em modo edição
3. ✅ Registro de campos
4. ✅ Criar nova escola com dados válidos
5. ✅ Falhar validação com dados inválidos
6. ✅ Retornar erro quando CreateUseCase falha
7. ✅ Reset limpar campos em modo criação
8. ✅ Reset restaurar valores em modo edição
9. ✅ Dispose liberar recursos

#### ❌ Testes Falhando (3):

##### 1. **"deve limpar dirty state após criação bem-sucedida"**
**Erro:**
```
Expected: false
  Actual: <true>
```

**Localização:** Linha 213

**Causa Provável:**
- O dirty state não está sendo limpo após submit bem-sucedido
- Pode ser que a validação esteja falhando silenciosamente
- Ou o FormValidationMixin não está limpando o dirty state corretamente

**Como Corrigir:**
1. Verificar se os dados do teste estão realmente válidos
2. Adicionar logs no teste para ver o resultado do submit
3. Verificar se `submitForm()` está retornando Success
4. Debug: Adicionar `print(result)` antes do assert

**Código a investigar:**
```dart
// Linha ~205-213
await viewModel.submit();
expect(viewModel.isFormDirty, isFalse); // ← Falhando aqui
```

---

##### 2. **"deve atualizar escola existente com dados válidos" (Modo Edição)**
**Erro:**
```
Expected: <Instance of 'Success<SchoolDetails>'>
  Actual: Failure<SchoolDetails>:<Failure(DataException: Erro de validação: Telefone inválido - use (XX) XXXXX-XXXX)>
```

**Localização:** Linha 250

**Causa:**
- O `initialData` ainda tem telefone em formato inválido
- Quando faz submit em modo edição, valida com dados do initialData

**Como Corrigir:**
Atualizar o `initialSchool` no teste para ter telefone válido:

```dart
// ANTES (linha ~220)
final initialSchool = SchoolDetails(
  // ...
  phone: '1111-1111',  // ❌ Formato inválido
  // ...
);

// DEPOIS
final initialSchool = SchoolDetails(
  // ...
  phone: '(11) 11111-1111',  // ✅ Formato válido
  // ...
);
```

**Nota:** Esse caso já pode estar corrigido nas últimas edições. Verificar o arquivo.

---

##### 3. **"deve chamar UpdateUseCase ao invés de CreateUseCase em modo edição"**
**Erro:**
```
Expected: not null
  Actual: <null>
```

**Localização:** Linha 288

**Causa:**
- `mockUpdateUseCase.lastExecutedWith` está null
- Significa que o UpdateUseCase não foi chamado
- Provavelmente porque a validação falhou (erro em cascata do teste #2)

**Como Corrigir:**
1. Garantir que todos os dados do `initialSchool` estejam válidos
2. Se o teste #2 for corrigido, este deve passar automaticamente
3. Alternativa: Simplificar o teste para apenas verificar o submit sem validação

**Código a investigar:**
```dart
// Linha ~270-290
final initialSchool = SchoolDetails(
  id: 'school-123',
  // ... verificar TODOS os campos
  phone: '(11) 12345-6789',  // ← Deve estar no formato correto
);

await viewModel.submit();
expect(mockUpdateUseCase.lastExecutedWith, isNotNull);  // ← Falhando
```

---

## 📝 Componentes Não Criados

### NotebookFormViewModel (notebook_ui)
**Arquivo:** `packages/notebook/notebook_ui/test/ui/view_models/notebook_form_view_model_test.dart`
**Status:** ⏳ **Não criado**

**O que criar:**
1. Estrutura de diretórios: `mkdir -p packages/notebook/notebook_ui/test/ui/view_models`
2. Arquivo de teste com cobertura similar ao SchoolFormViewModel
3. Mocks de UseCases (se aplicável)
4. Testes de:
   - Inicialização (modo criação e edição)
   - Submit com validação
   - Reset
   - Dispose

**Referência:** Usar `school_form_view_model_test.dart` como template

---

## 🔧 Plano de Correção

### Prioridade Alta
1. **Corrigir teste #2** (atualizar escola em modo edição)
   - Garantir que TODOS os campos do `initialSchool` estejam válidos
   - Executar teste isolado: `flutter test --plain-name "deve atualizar escola existente"`
   - Tempo estimado: 5-10 minutos

2. **Corrigir teste #3** (chamar UpdateUseCase)
   - Deve ser corrigido automaticamente após correção do teste #2
   - Se não: adicionar logs/debug para ver o fluxo
   - Tempo estimado: 5 minutos

3. **Corrigir teste #1** (limpar dirty state)
   - Debug: Verificar o que `submit()` retorna
   - Verificar se validação está passando
   - Pode requerer ajuste no FormValidationMixin
   - Tempo estimado: 10-15 minutos

### Prioridade Média
4. **Criar testes do NotebookFormViewModel**
   - Copiar estrutura do SchoolFormViewModel
   - Adaptar para NotebookValidator
   - Criar mocks necessários
   - Tempo estimado: 30-45 minutos

### Prioridade Baixa
5. **Aumentar cobertura**
   - Adicionar testes de edge cases
   - Testes de notificação de listeners
   - Testes de validação de campos específicos

---

## 🚀 Como Retomar os Testes

### Executar testes do SchoolFormViewModel:
```bash
cd /home/anderson/Projects/Working/ems_system/packages/school/school_ui
flutter test test/ui/view_models/school_form_view_model_test.dart
```

### Executar um teste específico:
```bash
flutter test test/ui/view_models/school_form_view_model_test.dart \
  --plain-name "deve atualizar escola existente"
```

### Ver output detalhado:
```bash
flutter test test/ui/view_models/school_form_view_model_test.dart -r expanded
```

---

## 📋 Checklist de Validação

Antes de marcar os testes como completos:

- [ ] FormValidationMixin: 38/38 testes passando ✅ (já completo)
- [ ] SchoolFormViewModel: 12/12 testes passando (9/12 atualmente)
- [ ] NotebookFormViewModel: Criar e validar testes
- [ ] Executar `flutter analyze` em todos os pacotes (0 warnings)
- [ ] Cobertura > 80% (verificar com `flutter test --coverage`)

---

## 🔗 Referências

- **Plano de Refatoração:** `/home/anderson/Projects/Working/ems_system/FORM_VALIDATION_REFACTOR_PLAN.md`
- **ADR-0004:** `docs/adr/0004-use-form-validation-mixin-and-zard.md`
- **FormValidationMixin:** `packages/core/core_ui/lib/core/mixins/form_validation_mixin.dart`
- **SchoolFormViewModel:** `packages/school/school_ui/lib/ui/view_models/school_form_view_model.dart`
- **NotebookFormViewModel:** `packages/notebook/notebook_ui/lib/ui/view_models/notebook_form_view_model.dart`

---

**Última Atualização:** 2026-01-31 23:30
**Responsável:** Claude Code
