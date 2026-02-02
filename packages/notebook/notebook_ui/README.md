# Notebook UI

Pacote de interface do usuário para gerenciamento de cadernos (notebooks) e documentos anexados no EMS System.

## Visão Geral

O `notebook_ui` fornece uma interface completa para criação, visualização, edição e exclusão de cadernos, além de gerenciar documentos anexados. Segue o padrão MVVM estabelecido no projeto com injeção de dependências via `get_it`.

## Características

### Funcionalidades Principais

- ✅ **Listagem de Cadernos** - visualização em cards com preview de conteúdo
- ✅ **Detalhes do Caderno** - visualização completa com metadata e documentos
- ✅ **Criação Rápida** - modal para criar notas rapidamente
- ✅ **Formulário Completo** - criar/editar cadernos com todos os campos
- ✅ **Gerenciamento de Documentos** - visualizar e deletar documentos anexados
- ✅ **Tipos de Caderno** - suporte para notas rápidas, organizadas e lembretes
- ✅ **Tags** - organização por tags customizadas
- ✅ **Estados de UI** - loading, erro, vazio e dados

### Tipos de Caderno

- **Nota Rápida** (`NotebookType.quick`) - para anotações rápidas e simples
- **Organizado** (`NotebookType.organized`) - cadernos estruturados
- **Lembrete** (`NotebookType.reminder`) - lembretes e tarefas

## Arquitetura

### Padrões Utilizados

- **MVVM** - Model-View-ViewModel com `ChangeNotifier`
- **Result Pattern** - tratamento de erros tipado
- **Dependency Injection** - `get_it` para gerenciamento de dependências
- **Modular Architecture** - `AppModule` para integração

### Estrutura de Diretórios

```
lib/
├── pages/                      # Páginas principais
│   ├── notebook_list_page.dart
│   ├── notebook_detail_page.dart
│   └── notebook_form_page.dart
├── view_models/                # ViewModels (lógica de negócio)
│   ├── notebook_list_view_model.dart
│   ├── notebook_detail_view_model.dart
│   └── notebook_create_view_model.dart
├── widgets/                    # Widgets reutilizáveis
│   ├── notebook_card.dart
│   ├── document_list_widget.dart
│   └── notebook_create_dialog.dart
├── notebook_module.dart        # Módulo de integração
└── notebook_ui.dart           # Arquivo de exportação
```

## Componentes

### ViewModels

#### NotebookListViewModel

Gerencia a lista de cadernos com operações de leitura e exclusão.

```dart
final viewModel = di.get<NotebookListViewModel>();

// Carregar lista
await viewModel.loadNotebooks();

// Acessar dados
final notebooks = viewModel.notebooks;
final isLoading = viewModel.isLoading;
final error = viewModel.error;

// Deletar
await viewModel.deleteNotebook(id);
```

#### NotebookDetailViewModel

Gerencia detalhes de um caderno específico incluindo documentos anexados.

```dart
final viewModel = di.get<NotebookDetailViewModel>();

// Carregar caderno
await viewModel.loadNotebook(notebookId);

// Acessar dados
final notebook = viewModel.notebook;
final documents = viewModel.documents;

// Atualizar
final update = NotebookUpdate(
  id: notebookId,
  title: 'Novo título',
  content: 'Novo conteúdo',
);
await viewModel.updateNotebook(update);
```

#### NotebookCreateViewModel

Gerencia criação de novos cadernos.

```dart
final viewModel = di.get<NotebookCreateViewModel>();

// Criar nota rápida
await viewModel.createQuickNote(
  title: 'Minha nota',
  content: 'Conteúdo da nota',
);

// Criar caderno completo
final create = NotebookCreate(
  title: 'Título',
  content: 'Conteúdo',
  type: NotebookType.organized,
  tags: ['tag1', 'tag2'],
);
await viewModel.createNotebook(create);
```

### Pages

#### NotebookListPage

Página de listagem com estados de loading, erro, vazio e dados.

- **FAB** para criar nota rápida
- **RefreshIndicator** para atualizar lista
- **NavigationItem** para acessar detalhes
- **Confirmação** antes de deletar

#### NotebookDetailPage

Página de visualização completa do caderno.

Exibe:
- Título e tipo
- Datas de criação e atualização
- Tags
- Conteúdo completo
- Lista de documentos anexados

Ações:
- Editar caderno
- Excluir caderno
- Deletar documentos

#### NotebookFormPage

Formulário para criar ou editar cadernos.

Campos:
- **Título** (obrigatório)
- **Conteúdo** (obrigatório, multilinha)
- **Tipo** (dropdown)
- **Tags** (separadas por vírgula)

### Widgets

#### NotebookCard

Card de preview para listagem.

Exibe:
- Ícone do tipo
- Título (truncado)
- Preview do conteúdo
- Data de criação
- Tags (até 3 visíveis)
- Botão deletar

#### DocumentListWidget

Lista de documentos anexados.

Exibe para cada documento:
- Ícone baseado no tipo de arquivo
- Nome do documento
- Tipo de armazenamento
- Tamanho do arquivo
- Ações (abrir/deletar)

#### NotebookCreateDialog

Modal para criação rápida de notas.

Campos simplificados:
- Título
- Conteúdo

## Integração

### 1. Adicionar Dependência

No `pubspec.yaml` do seu app:

```yaml
dependencies:
  notebook_ui:
    path: ../../packages/notebook/notebook_ui
```

### 2. Registrar Módulo

No setup de DI da aplicação:

```dart
import 'package:notebook_ui/notebook_ui.dart';

// Criar e registrar módulo
final notebookModule = NotebookModule(di: di);
notebookModule.registerDependencies(di);

// Adicionar rotas
final routes = {
  ...notebookModule.routes,
  // outras rotas
};

// Adicionar itens de navegação
final navItems = [
  ...notebookModule.navigationItems,
  // outros itens
];
```

### 3. Navegação

Acessar a página de cadernos:

```dart
Navigator.pushNamed(context, '/notebooks');
```

## Dependências

### Principais

- `flutter` - Framework UI
- `notebook_shared` - Modelos de domínio
- `notebook_client` - Cliente API
- `core_shared` - Core compartilhado
- `core_client` - Core cliente
- `core_ui` - Core UI

### Auxiliares

- `get_it` - Dependency Injection
- `dio` - Cliente HTTP
- `localizations_ui` - Traduções
- `design_system_ui` - Design system
- `auth_ui` - Autenticação

## Rotas

- `/notebooks` - Lista de cadernos (NotebookListPage)
- `/notebooks/:id` - Detalhes do caderno (via navegação dinâmica)
- `/notebooks/edit/:id` - Editar caderno (via navegação dinâmica)

## Estados de UI

Todas as páginas implementam estados consistentes:

1. **Loading** - `CircularProgressIndicator` centralizado
2. **Erro** - Mensagem de erro com botão "Tentar novamente"
3. **Vazio** - Mensagem informativa quando não há dados
4. **Dados** - Exibição normal do conteúdo

## Tratamento de Erros

Todos os ViewModels utilizam:

- **Result Pattern** - `Success<T>` ou `Failure`
- **DioErrorHandler** - conversão de exceções HTTP
- **Error State** - `String? error` para exibir mensagens

## Validações

### Formulários

- **Título**: obrigatório, máximo 255 caracteres
- **Conteúdo**: obrigatório
- **Tags**: opcional, separadas por vírgula

### Confirmações

Ações destrutivas requerem confirmação:
- Deletar caderno
- Deletar documento

## Testes

Para executar os testes:

```bash
cd packages/notebook/notebook_ui
flutter test
```

## Análise de Código

Verificar qualidade do código:

```bash
cd packages/notebook/notebook_ui
flutter analyze
```

## Convenções de Código

- **Nomenclatura**: camelCase para variáveis, PascalCase para classes
- **Imports**: ordenados (dart, flutter, packages, relative)
- **Documentação**: dartdoc para classes e métodos públicos
- **Formatação**: `flutter format .`

## Limitações Conhecidas

1. **Formulário manual** - ainda não migrado para `zard_form`
2. **Upload de arquivos** - implementação futura
3. **Preview de documentos** - não disponível ainda
4. **Paginação** - lista carrega todos os itens
5. **Cache offline** - não implementado

## Roadmap

### Próximas Funcionalidades

- [ ] Upload de arquivos/documentos
- [ ] Preview inline de PDFs e imagens
- [ ] Filtros avançados (por tipo, tags, projeto)
- [ ] Busca textual
- [ ] Hierarquia de páginas/seções
- [ ] Compartilhamento entre usuários
- [ ] Paginação na listagem
- [ ] Cache offline com sqflite
- [ ] Migração para zard_form

## Contribuindo

Ao contribuir:

1. Siga os padrões arquiteturais estabelecidos
2. Mantenha a documentação atualizada
3. Execute `flutter analyze` antes de commit
4. Adicione testes para novas funcionalidades

## Licença

Propriedade da EduMigSoft.

## Suporte

Para questões ou problemas, consulte a equipe de desenvolvimento.
