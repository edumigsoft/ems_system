# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [1.0.0] - 2026-01-24

### Adicionado

#### ViewModels
- `NotebookListViewModel` para gerenciar lista de cadernos
  - Método `loadNotebooks()` para carregar lista
  - Método `deleteNotebook(String id)` para deletar caderno
  - Estado: `notebooks`, `isLoading`, `error`
  
- `NotebookDetailViewModel` para gerenciar detalhes e documentos
  - Método `loadNotebook(String id)` para carregar caderno
  - Método `loadDocuments(String notebookId)` para carregar documentos
  - Método `updateNotebook(NotebookUpdate)` para atualizar
  - Método `deleteDocument(String documentId)` para deletar documento
  - Estado: `notebook`, `documents`, `isLoading`, `error`
  
- `NotebookCreateViewModel` para criação de cadernos
  - Método `createNotebook(NotebookCreate)` para criar caderno completo
  - Método `createQuickNote({title, content})` para nota rápida
  - Método `reset()` para limpar estado
  - Estado: `isCreating`, `error`, `createdNotebook`

#### Pages
- `NotebookListPage` - listagem de cadernos
  - Estados: loading, erro, vazio, dados
  - RefreshIndicator para atualizar
  - FAB para criar nota rápida
  - Navegação para detalhes
  - Confirmação antes de deletar
  
- `NotebookDetailPage` - visualização completa
  - Exibição de título, tipo, datas, tags e conteúdo
  - Lista de documentos anexados
  - Ações: editar e excluir
  - Confirmação para exclusões
  
- `NotebookFormPage` - formulário de criação/edição
  - Campos: título, conteúdo, tipo, tags
  - Validação de campos obrigatórios
  - Modo criar/editar baseado em contexto

#### Widgets
- `NotebookCard` - card de preview para listagem
  - Ícone do tipo de caderno
  - Título e preview do conteúdo
  - Tags (até 3 visíveis)
  - Data de criação
  - Botão deletar
  
- `DocumentListWidget` - lista de documentos
  - Ícone baseado no tipo de arquivo
  - Informações: nome, tamanho, tipo de armazenamento
  - Ações: abrir link (URL), deletar
  - Estado vazio personalizado
  
- `NotebookCreateDialog` - modal para nota rápida
  - Formulário simplificado (título e conteúdo)
  - Validação inline
  - Feedback visual de loading

#### Infraestrutura
- `NotebookModule` - módulo de integração
  - Registro de dependências (services e ViewModels)
  - Configuração de rotas
  - Itens de navegação para sidebar
  
- `notebook_ui.dart` - arquivo de exportação pública
  - Exports de ViewModels, Pages e Widgets
  - Export do módulo

#### Integração com API
- Integração com `NotebookApiService`
  - `getAll()` - listar cadernos
  - `getById(String id)` - detalhes do caderno
  - `create(Map)` - criar caderno
  - `update(String id, Map)` - atualizar caderno
  - `delete(String id)` - deletar caderno
  - `getDocuments(String id)` - listar documentos
  
- Integração com `DocumentReferenceApiService`
  - `delete(String id)` - deletar documento

#### Padrões e Qualidade
- Implementação do padrão MVVM com `ChangeNotifier`
- Uso do `Result Pattern` para tratamento de erros
- `DioErrorHandler` mixin para conversão de exceções
- Dependency Injection via `get_it`
- Conversões Domain ↔ Model adequadas
- Estados de UI consistentes (loading, erro, vazio, dados)
- Validação de formulários
- Confirmações para ações destrutivas

#### Documentação
- README.md completo com exemplos
- CHANGELOG.md com histórico de mudanças
- Comentários dartdoc em APIs públicas
- Walkthrough de implementação

### Dependências
- `flutter` - SDK base
- `notebook_shared` - modelos de domínio
- `notebook_client` - cliente API
- `core_shared`, `core_client`, `core_ui` - pacotes core
- `design_system_shared`, `design_system_ui` - design system
- `localizations_ui`, `localizations_shared` - i18n
- `zard_form` - formulários (preparado para uso futuro)
- `auth_client`, `auth_ui` - autenticação
- `get_it` - DI
- `dio` - HTTP client
- `logging` - logs

### Verificado
- ✅ Análise de código (`flutter analyze`) sem erros
- ✅ Build executado com sucesso (`flutter pub get`)
- ✅ Conversões de API adequadas
- ✅ Tratamento de erros implementado
- ✅ Estados de UI testados

### Limitações Conhecidas
- Formulários ainda não utilizam `zard_form`
- Upload de arquivos não implementado
- Preview de documentos não disponível
- Paginação não implementada
- Cache offline não disponível

## [Unreleased]

### Planejado
- Migração de formulários para `zard_form`
- Upload de arquivos e documentos
- Preview inline de PDFs e imagens
- Filtros avançados (tipo, tags, projeto)
- Busca textual
- Hierarquia de páginas/seções
- Compartilhamento entre usuários
- Paginação na listagem
- Cache offline com sqflite
- Testes unitários e de widget

---

**Formato**: Este changelog segue o padrão [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

**Versionamento**: Este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).
