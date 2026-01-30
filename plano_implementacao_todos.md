# Plano de Implementação de TODOs

Este documento descreve as etapas para resolver os TODOs identificados nos pacotes `@packages/school` e `@packages/user`.

## 1. Módulo School: Padronização de Paginação

O backend do módulo School retorna dados paginados, mas o `SchoolService` no cliente está configurado para retornar uma lista simples, o que causa erros de desserialização ou perda de metadados de paginação.

### Tarefas:
- [ ] **Shared**: Criar `PaginatedResponse<T>` em `school_shared` (seguindo o padrão de `user_shared`).
- [ ] **Client**: Atualizar `SchoolService` para retornar `Future<PaginatedResponse<SchoolDetailsModel>>` em `getAll` e `getDeleted`.
- [ ] **Client**: Executar `build_runner` para regenerar o código do Retrofit.
- [ ] **Client**: Atualizar `SchoolRepositoryClient` para converter `PaginatedResponse` em `PaginatedResult` corretamente.

## 2. Módulo School UI: Edição em Dispositivos Móveis

Atualmente, os layouts de Mobile e Tablet apenas exibem detalhes ou listam escolas, sem navegação para a tela de edição.

### Tarefas:
- [ ] **UI**: Extrair o formulário de edição de `DesktopEditItemWidget` para um widget compartilhado `SchoolFormWidget` para evitar duplicação de lógica.
- [ ] **UI**: Criar `SchoolEditPage` para ser usada em dispositivos móveis.
- [ ] **UI**: Implementar a navegação (`Navigator.push`) nos callbacks de edição do `MobileWidget` e `TabletWidget`.

## 3. Módulo User UI: Gerenciamento de Usuários (Admin)

O diálogo de edição de usuários no painel administrativo ainda não foi implementado.

### Tarefas:
- [ ] **ViewModel**: Garantir que `ManageUsersViewModel` possua métodos para atualizar dados básicos, role e status.
- [ ] **UI**: Implementar `_showEditDialog` em `MobileWidget` e `TabletWidget` (dentro de `manage_users_page.dart`).
- [ ] **UI**: O formulário de edição deve permitir alterar: Nome, Telefone, Role (com guardas de permissão) e Status Ativo.

## 4. Verificação e Qualidade

- [ ] Executar `dart analyze` em todos os pacotes modificados.
- [ ] Executar testes unitários onde existirem.
- [ ] Verificar a integração final no app `ems`.
