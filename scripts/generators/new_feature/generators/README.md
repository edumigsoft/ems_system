# Geradores de Features - Documentação Completa

## 📋 Visão Geral

Scripts modulares para geração automatizada de código seguindo rigorosamente as regras arquiteturais do projeto.

**Status**: ✅ 100% Implementado (16 geradores + wizard)

---

## 🚀 Como Usar

### Opção 1: Wizard Completo (Recomendado)

```bash
# Navegar para o diretório raiz do projeto
cd /home/anderson/Projects/Working/ems_system

# Executar wizard
./scripts/create_feature_wizard.sh
```

O wizard perguntará:
1. Nome da feature (ex: `library`)
2. Título (ex: `Library Management`)
3. Entidade principal (ex: `Book`)
4. Nome plural (ex: `books`)
5. Campos (ex: `title:String,isbn:String,year:int`)
6. Pacotes a criar (1-5):
   - 1: shared
   - 2: shared + client
   - 3: shared + server
   - 4: shared + client + server
   - 5: shared + client + server + ui (completo)

**Resultado**: Feature completa em 2-3 minutos! ⚡

### Opção 2: Geradores Individuais

```bash
cd scripts/generators

# Shared (sempre necessário)
./01_generate_entities.sh      # Entity
./02_generate_details.sh        # Details
./03_generate_dtos.sh           # DTOs
./04_generate_models.sh         # Models
./06_generate_constants.sh      # Constants

# Server (se necessário)
./07_generate_tables.sh         # Drift Table
./11_generate_routes.sh         # API Routes

# Client (se necessário)
./09_generate_repositories.sh   # Repository
./10_generate_services.sh       # Retrofit Service

# Negócio/UI (se necessário)
./12_generate_use_cases.sh      # Use Cases
./13_generate_validators.sh     # Zard Validators
./14_generate_ui_module.sh      # AppModule DI
./15_generate_ui_components.sh  # ViewModels
./16_generate_ui_widgets.sh     # Widgets
```

Cada script solicita inputs interativamente.

---

## ✅ Scripts Disponíveis

### Fundação (4 scripts + docs)
- **common/utils.sh** - Funções auxiliares (conversores, paths, colors)
- **common/validators.sh** - Validações de input
- **common/templates_engine.sh** - Engine de processamento
- **README.md** (este arquivo)
- **SUMMARY.md** - Resumo da implementação

### Geradores Shared (6/6 - 100%)
1. **01_generate_entities.sh** - Entity SEM id
2. **02_generate_details.sh** - *Details implementando BaseDetails
3. **03_generate_dtos.sh** - DTOs Create e Update
4. **04_generate_models.sh** - Models com JSON manual
5. **05_generate_converters.sh** - ModelConverter opcional
6. **06_generate_constants.sh** - Constants de rotas + validações

### Geradores Server/Client (5/5 - 100%)
7. **07_generate_tables.sh** - Drift Tables
8. **08_generate_type_converters.sh** - TypeConverters para enums
9. **09_generate_repositories.sh** - Repository interface + implementações
10. **10_generate_services.sh** - Retrofit Service
11. **11_generate_routes.sh** - Shelf Routes com constants

### Geradores UI (5/5 - 100%)
12. **12_generate_use_cases.sh** - Use Cases CRUD
13. **13_generate_validators.sh** - Zard Validators
14. **14_generate_ui_module.sh** - AppModule com DI
15. **15_generate_ui_components.sh** - Pages + ViewModels (MVVM)
16. **16_generate_ui_widgets.sh** - Widgets reutilizáveis

### Wizard Orquestrador
- **create_feature_wizard.sh** - Wizard que orquestra tudo

---

## ✨ Regras Arquiteturais Garantidas

Todos os geradores validam e garantem:

### Entity
- ✅ SEM campo `id`
- ✅ SEM serialização JSON
- ✅ Campos `final`
- ✅ `operator==` e `hashCode`

### Details
- ✅ **Implementa** BaseDetails (não estende)
- ✅ Campo `data` contendo Entity
- ✅ Getters de conveniência
- ✅ SEM serialização JSON

### DTOs
- ✅ Create: SEM id, SEM timestamps
- ✅ Update: id required, outros optional
- ✅ Validações usando constants
- ✅ Inclui `isActive` e `isDeleted` no Update

### Models
- ✅ Campo `entity` ou `data`
- ✅ JSON **MANUAL** (sem @JsonSerializable)
- ✅ Métodos: fromJson, toJson, fromDomain, toDomain

### Constants
- ✅ Rotas (Shelf: `/<id>`, OpenAPI: `/{id}`)
- ✅ RegExp compartilhadas
- ✅ Mensagens de erro compartilhadas

### Routes
- ✅ Extends `Routes` do core_server
- ✅ Usa `Loggable` mixin
- ✅ Usa constants do _shared
- ✅ Anotações OpenAPI

### Validators
- ✅ Zard com constants compartilhadas
- ✅ Mesmas regras dos DTOs

### ViewModels
- ✅ Extends ChangeNotifier
- ✅ FormValidationMixin
- ✅ Validação via Zard

---

## 📝 Exemplo Completo

### Usando o Wizard

```bash
$ ./scripts/create_feature_wizard.sh

🚀 Wizard de Criação de Features

Coletando informações da feature...
Nome da feature (snake_case, ex: book): library
Título da feature (ex: Book Management): Library Management
Nome da entidade principal (PascalCase, ex: Book): Book
Nome da entidade (plural, ex: books): books
Informe os campos da entidade (formato: nome:Tipo,nome2:Tipo2)
Exemplo: title:String,isbn:String,publishYear:int
Campos: title:String,isbn:String,publishYear:int
Quais pacotes deseja criar?
  1. shared (obrigatório)
  2. shared + client
  3. shared + server  
  4. shared + client + server
  5. shared + client + server + ui (completo)
Opção (1-5) [5]: 5

🚀 Criando estrutura base com scaffold_feature.sh...
✅ Estrutura base criada!

🚀 Gerando código shared...
✅ Shared gerado!

🚀 Gerando código server...
✅ Server gerado!

🚀 Gerando código client...
✅ Client gerado!

🚀 Gerando código UI...
✅ UI gerada!

🚀 Executando build_runner...
✅ Build runner concluído!

==========================================================
✅ Feature 'library' criada com sucesso!
==========================================================

Próximos passos:
  1. Revisar código gerado
  2. Adicionar lógica de negócio específica
  3. Implementar validações customizadas em Constants
  4. Completar UI pages e widgets
  5. Executar testes

Localização: packages/library/
```

### Estrutura Gerada

```
packages/library/
├── library_shared/
│   ├── lib/src/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── book.dart              ← 01
│   │   │   │   └── book_details.dart      ← 02
│   │   │   ├── dtos/
│   │   │   │   ├── book_create.dart       ← 03
│   │   │   │   └── book_update.dart       ← 03
│   │   │   └── use_cases/                 ← 12
│   │   ├── data/
│   │   │   ├── models/                    ← 04
│   │   │   ├── converters/                ← 05
│   │   │   └── repositories/              ← 09
│   │   ├── constants/                     ← 06
│   │   │   └── library_constants.dart
│   │   └── validators/                    ← 13
│   └── pubspec.yaml
├── library_client/                        ← 09, 10
├── library_server/                        ← 07, 11
└── library_ui/                            ← 14, 15, 16
```

---

## 🔧 Próximos Passos Após Gerar

1. **Revisar código gerado**
2. **Adicionar lógica de negócio** na Entity
3. **Completar validações** em Constants:
   ```dart
   // library_constants.dart
   final RegExp isbnPattern = RegExp(r'^\d{10}(\d{3})?$');
   const String isbnInvalidMessage = 'ISBN deve ter 10 ou 13 dígitos';
   const int titleMinLength = 3;
   const int titleMaxLength = 200;
   ```
4. **Implementar DTOs validations**:
   ```dart
   String? validate() {
     if (title.length < titleMinLength) return titleMinLengthMessage;
     if (!isbnPattern.hasMatch(isbn)) return isbnInvalidMessage;
     return null;
   }
   ```
5. **Usar constants nos Zard Validators**
6. **Implementar UI pages e widgets**
7. **Registrar module no app principal**
8. **Adicionar testes**

---

## 🎯 Benefícios

- ⚡ **Velocidade**: 2-3 minutos vs 2-4 horas
- ✅ **Qualidade**: 100% conformidade arquitetural
- 🎯 **Consistência**: Código padronizado
- 🔒 **Segurança**: Validações automáticas
- 📚 **Documentação**: Auto-documentado
- 🔧 **Manutenção**: Fácil de atualizar

---

## 📚 Referências

- [ADR-0005](../../docs/adr/0005-standard-package-structure.md) - Estrutura de pacotes
- [entity_patterns.md](../../docs/rules/entity_patterns.md) - Padrões de entidades

---

## 🆘 Troubleshooting

### Erro: "Pacote não encontrado"
Execute `scaffold_feature.sh` primeiro para criar a estrutura base.

### Erro: "build_runner failed"
Verifique se todas as dependências foram adicionadas ao `pubspec.yaml`.

### Código gerado não compila
Revise os campos informados e execute novamente o gerador específico.

### Validação falhou
Execute `./scripts/validate_architecture.sh` para ver detalhes dos erros.

---

**Versão**: 1.0.0  
**Última atualização**: 2026-01-01  
**Status**: Produc tion Ready ✅
