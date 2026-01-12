# Exemplo: Criando Sub-Feature Academic Structure

## Contexto
Demonstração de criação de sub-feature usando o wizard, seguindo o padrão de `packages/finance`.

## Passo a Passo

### 1. Executar Wizard
```bash
cd /home/anderson/Projects/Working/ems_system
./scripts/create_feature_wizard.sh
```

### 2. Inputs do Wizard

```
🚀 Wizard de Criação de Features
✨ Suporta sub-features (ex: finance/billing)
✨ Usa pubspec.yaml.templates com versões fixas

Nome da feature: finance/billing
✓ Sub-feature detectada: finance/billing

Título da feature: Billing Management

Nome da entidade principal: Invoice

Nome da entidade (plural): invoices

Campos: name:String,code:String,workload:int

Pacotes a criar (1-5): 5
```

### 3. Estrutura Gerada

```
packages/finance/
├── billing/
│   ├── billing_shared/
│   │   ├── lib/src/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── invoice.dart
│   │   │   │   │   └── invoice_details.dart
│   │   │   │   ├── dtos/
│   │   │   │   │   ├── invoice_create.dart
│   │   │   │   │   └── invoice_update.dart
│   │   │   │   └── use_cases/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   ├── converters/
│   │   │   │   └── repositories/
│   │   │   ├── constants/
│   │   │   │   └── billing_constants.dart
│   │   │   └── validators/
│   │   └── pubspec.yaml  ← Com versões do template
│   ├── billing_client/
│   │   └── pubspec.yaml  ← retrofit: 4.9.1
│   ├── billing_server/
│   │   └── pubspec.yaml  ← build_runner: 2.10.4
│   └── billing_ui/
│       └── pubspec.yaml
```

### 4. Templates Pubspec Usados

O `scaffold_feature.sh` converteu:

**Template** (`docs/templates/client/pubspec.yaml.template`):
```yaml
name: {{FEATURE_NAME}}_client
dependencies:
  {{FEATURE_NAME}}_shared:
    path: ../{{FEATURE_NAME}}_shared
  core_client:
    path: {{REL_PATH}}packages/core/core_client
  retrofit: 4.9.1  ← Versão fixa
```

**Gerado** (`billing_client/pubspec.yaml`):
```yaml
name: billing_client
dependencies:
  billing_shared:
    path: ../billing_shared
  core_client:
    path: ../../../core/core_client  ← Path relativo calculado
  retrofit: 4.9.1  ← Mantido
```

### 5. Benefícios

✅ **Hierarquia Organizada**: Sub-features agrupadas logicamente  
✅ **Versões Consistentes**: retrofit, build_runner, etc sempre iguais  
✅ **Paths Automáticos**: Calculados corretamente para qualquer profundidade  
✅ **Reutilização**: Múltiplas sub-features podem compartilhar pacote pai

---

## Comparação: Feature vs Sub-Feature

### Feature Simples
```bash
Nome: library
Path: packages/library/library_shared/
```

### Sub-Feature
```bash
Nome: finance/billing  
Path: packages/finance/billing/billing_shared/
```

Ambos funcionam perfeitamente com o wizard! 🎉
