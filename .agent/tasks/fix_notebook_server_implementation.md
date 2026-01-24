---
status: completed
priority: high
assignee: assistant
created_at: 2026-01-24T17:17:14-03:00
completed_at: 2026-01-24T18:30:00-03:00
---

# Correção da Implementação do notebook_server

## Contexto
O pacote `packages/notebook/notebook_server` não foi implementado corretamente. Está faltando:
1. Uso de `@UseRowClass` nas tabelas do banco de dados
2. Implementação do `NotebookRepositoryServer`
3. Implementação das rotas HTTP (NotebookRoutes)

## Referência
O pacote `packages/user/user_server` serve como referência para a implementação correta.

## Tarefas

### 1. Corrigir Tabelas do Banco de Dados ✅
- [x] **notebook_table.dart**: Adicionar `@UseRowClass(NotebookDetails, constructor: 'create')`
  - Removido userId da tabela (não faz parte do NotebookDetails)
  - Adicionado campo para tags (array de strings)
  - Adicionado campo para documentIds (array de strings)
  
- [x] **document_reference_table.dart**: Adicionar `@UseRowClass(DocumentReferenceDetails, constructor: 'create')`
  - Verificada compatibilidade de campos com o entity

- [x] **notebook_tag_table.dart**: 
  - Esta é uma tabela de junção (junction table)
  - NÃO deve usar @UseRowClass
  - Mantida como estava (já correta)

### 2. Criar NotebookRepositoryServer ✅
- [x] Criar arquivo `/packages/notebook/notebook_server/lib/src/repository/notebook_repository_server.dart`
- [x] Implementar interface `NotebookRepository` do notebook_shared
- [x] Métodos a implementar:
  - `create(NotebookCreate data)` - Criar notebook
  - `getById(String id)` - Buscar por ID
  - `getAll(...)` - Listar com filtros (activeOnly, search, projectId, parentId, type, tags, overdueOnly)
  - `update(NotebookUpdate data)` - Atualizar notebook
  - `delete(String id)` - Soft delete
  - `restore(String id)` - Restaurar notebook deletado

### 3. Criar NotebookRoutes ✅
- [x] Criar arquivo `/packages/notebook/notebook_server/lib/src/routes/notebook_routes.dart`
- [x] Estender `Routes` do core_server
- [x] Configurar rotas:
  - `POST /notebooks` - Criar notebook (autenticado)
  - `GET /notebooks` - Listar notebooks (autenticado, com filtros)
  - `GET /notebooks/:id` - Buscar por ID (autenticado)
  - `PUT /notebooks/:id` - Atualizar (autenticado, verificar ownership)
  - `DELETE /notebooks/:id` - Soft delete (autenticado, verificar ownership)
  - `POST /notebooks/:id/restore` - Restaurar (autenticado, verificar ownership)
- [x] Implementar middleware de autenticação
- [x] Implementar verificação de ownership (usuário só pode editar/deletar seus próprios notebooks ou admin pode tudo)

### 4. Atualizar Exports ✅
- [x] Atualizar `/packages/notebook/notebook_server/lib/notebook_server.dart` para exportar:
  - NotebookRepositoryServer
  - NotebookRoutes
  - StringListConverter
  - NotebookDatabase (já exportado)

### 5. Testes e Validação ✅
- [x] Executar `dart analyze` no pacote
- [x] Executar `dart run build_runner build` para gerar código Drift
- [x] Verificar se há erros de compilação
- [x] Sem issues encontrados!

## Observações Importantes

### Sobre @UseRowClass
- Permite mapear diretamente entre tabela Drift e entity de domínio
- Evita duplicação de classes
- Requer um construtor nomeado 'create' na entity
- A entity deve ter todos os campos da tabela

### Sobre Ownership
De acordo com a conversa anterior (ID: 643bbf8d):
- Um owner (usuário dono do notebook) pode editar/deletar
- OU o usuário autenticado que é o dono do notebook pode editar/deletar
- Admins do sistema também podem gerenciar qualquer notebook
