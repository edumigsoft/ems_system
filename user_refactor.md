# Você é um especialista em arquitetura de software e autorização de sistema.

---

# Modelo de Autorização Baseado em Papéis em Níveis Global e Granular (Modular e Isolado por Contexto)

## Visão Geral

Este modelo define um sistema de autorização composto por:

- **`UserRole`**: Papel global do usuário no sistema (ex: `owner`, `admin`, `manager`, `user`).
- **`FeatureUserRole`**: Papel do usuário em um contexto específico de uma feature (ex: `project`, `finance`), armazenado em tabelas dedicadas por feature (ex: `project_user_role`, `finance_user_role`).

Essa abordagem mantém a simplicidade dos papéis, ao mesmo tempo que garante **modularidade, isolamento e reutilização de código**.

---

## Componentes

### `UserRole`

- Associado diretamente ao usuário globalmente.
- Define o limite máximo de privilégios do usuário no sistema.
- Exemplos: `owner`, `admin`, `manager`, `user`.

### `FeatureUserRole`

- Define o papel do usuário em um contexto específico de uma feature (ex: projeto, empresa).
- Armazenado em tabelas dedicadas por feature (ex: `project_user_role`, `finance_user_role`).
- Estrutura comum entre todas as features:
  - `user_id`
  - `feature_id` (ex: `project_id`, `company_id`)
  - `role` (ex: `owner`, `admin`, `member`, `viewer`)

---

## Estrutura de Dados (Conceitual)

### Tabela de Usuários (única)

**Aproveitar a entidade User e a estrutura atual do banco de dados**

```sql
users # exemplo
├── id
├── name
├── email
└── user_role (ex: 'owner', 'admin', 'user')
```

### Tabelas de Papéis por Feature

**Nova entidade FeatureUserRole**

```dart
class FeatureUserRole {
  final String id;
  final String userId;
  final String featureId;
  final String role;
  final DateTime createdAt; # Somente na Details/Models/Dtos conforme documentação
  final DateTime updatedAt; # Somente na Details/Models/Dtos conforme documentação
}
```

```sql
project_user_role
├── id
├── user_id
├── project_id
├── role (ex: 'owner', 'admin', 'member', 'viewer')
└── created_at

finance_user_role
├── id
├── user_id
├── company_id
├── role (ex: 'owner', 'manager', 'viewer')
└── created_at
```

Outras tabelas da feature (ex: `project_*`, `finance_*`) são mantidas separadamente.

---

## Regras de Isolamento e Controle

- Cada feature tem sua própria tabela de papéis, com isolamento de dados.
- Um `UserRole.owner` tem privilégios máximos em todas as features.
- Um `FeatureUserRole.owner` tem precedência sobre outros papéis **dentro do contexto da feature**.
- A permissão final é determinada pela combinação de `UserRole` e `FeatureUserRole` no contexto atual.

---

## Estrutura de Código (Conceitual)

- Classes e interfaces genéricas podem ser criadas para manipular `FeatureUserRole`, comuns a todas as features.
- Exemplo:
  - Interface: `FeatureUserRoleRepository`
  - Entidade: `FeatureUserRole`
  - Implementações: `ProjectUserRoleRepository`, `FinanceUserRoleRepository`, etc.

---

## Vantagens

- **Simplicidade**: Usa papéis em vez de permissões baseadas em ações.
- **Modularidade**: Cada feature tem suas próprias tabelas e lógica.
- **Reutilização de Código**: Interfaces e entidades genéricas podem ser reaproveitadas.
- **Isolamento e Segurança**: Cada feature mantém suas permissões separadas.
- **Manutenibilidade**: Fácil de evoluir e auditar.

---

## Desvantagens

- **Multiplicação de Tabelas**: Cada nova feature pode exigir uma nova tabela de papéis.
- **Consistência de Nomenclatura**: É importante manter padrões claros (ex: `feature_user_role`).

---

## Definições de Papéis (Roles)

### Nível Global (`UserRole`)

#### `owner`
- Tem **acesso total e irrestrito** ao sistema.
- Pode gerenciar todos os usuários, configurações e recursos.
- Pode sobrepor qualquer restrição de outros papéis.
- Pode excluir ou alterar contas de outros `owners` (se aplicável).
- Exemplo: fundador ou superadministrador.

#### `admin`
- Tem amplas permissões de gerenciamento.
- Pode gerenciar usuários, configurações e recursos, exceto funções de `owner`.
- Não pode excluir ou alterar contas de `owners`.
- Pode conceder ou revogar papéis a outros usuários (exceto `owner`).
- Exemplo: administrador de sistema.

#### `manager`
- Tem permissões de gerenciamento limitado.
- Pode gerenciar recursos e usuários dentro de seu escopo (ex: equipe, departamento).
- Não pode alterar papéis de `admin` ou `owner`.
- Não pode excluir ou alterar dados de outros managers/admins.
- Exemplo: gerente de equipe ou projeto.

#### `user`
- Usuário comum do sistema.
- Pode acessar e modificar apenas seus próprios dados e recursos compartilhados.
- Não pode gerenciar outros usuários ou configurações.
- Exemplo: colaborador ou membro comum.

---

### Nível Granular (`FeatureUserRole`)

As definições abaixo são **genéricas**, podendo ser adaptadas para diferentes features (ex: `project`, `finance`, `inventory`).

#### `owner`
- Tem **controle total** sobre o contexto da feature (ex: projeto, empresa).
- Pode editar, excluir e gerenciar membros e configurações.
- Pode conceder ou revogar papéis dentro do contexto.
- Tem precedência sobre todos os outros papéis no contexto.
- Exemplo: dono de um projeto.

#### `admin`
- Tem permissões de gerenciamento dentro do contexto.
- Pode editar, excluir e gerenciar membros e configurações, exceto funções de `owner`.
- Não pode alterar papéis de `owner`.
- Exemplo: administrador de um projeto.

#### `manager`
- Pode gerenciar recursos e membros com permissões limitadas.
- Pode editar conteúdo e atribuir tarefas, mas não excluir membros ou alterar configurações críticas.
- Não pode alterar papéis de `admin` ou `owner`.
- Exemplo: coordenador de tarefas.

#### `member`
- Pode ler e contribuir com conteúdo.
- Pode criar/editar tarefas ou itens, mas não gerenciar membros ou configurações.
- Exemplo: colaborador do projeto.

#### `viewer`
- Apenas visualiza o conteúdo do contexto.
- Não pode editar, excluir ou gerenciar nada.
- Exemplo: observador ou stakeholder.

---

## Exemplo de Uso

- Usuário `AnderDev`:
  - `UserRole = admin`
  - `project_user_role` → `role = owner` no projeto `123`
  - `finance_user_role` → `role = viewer` na empresa `456`

---

# Dicas

- o sistema possue geradores de código por script bash para diversas funcionalidades, como criação de tabelas, models, repositories, etc.
