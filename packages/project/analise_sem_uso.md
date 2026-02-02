# Análise de Código Não Utilizado - Pacote Project

## Visão Geral
Esta análise verificou o conteúdo do diretório `packages/project`. A estrutura sugere uma divisão em `project_core`, `project` e `task`.

## 1. Classes e Arquivos Não Exportados (`project_core_shared`)
O arquivo de entrada principal da biblioteca `packages/project/project_core/project_core_shared/lib/project_core_share.dart` exporta **apenas** `SimpleTime`.

As seguintes entidades e enums existem no código fonte mas **não estão acessíveis** para consumidores externos do pacote, tornando-os efetivamente "sem uso" fora do escopo interno:

*   **Entidades:**
    *   `Project` (`lib/src/domain/entities/project.dart`)
    *   `Task` (`lib/src/domain/entities/task.dart`)
    *   `Recurrence` (`lib/src/domain/entities/recurrence.dart`)
*   **Enums:**
    *   `ProjectStatus` (`lib/src/domain/enums/project_status.dart`)
    *   `TaskPriority` (`lib/src/domain/enums/task_priority.dart`)
    *   `TaskStatus` (`lib/src/domain/enums/task_status.dart`)
    *   `RecurrenceType` (`lib/src/domain/enums/recurrence_type.dart`)
    *   `CategoryType` (`lib/src/domain/enums/category_type.dart`)

**Recomendação:** Adicionar os exports necessários em `project_core_share.dart` para expor o domínio do projeto.

## 2. Código Definido mas Não Utilizado
*   **`CategoryType`**: O enum `CategoryType` está definido em `lib/src/domain/enums/category_type.dart`.
    *   A entidade `Task` possui um campo `List<String>? categories`, mas não faz referência ao tipo `CategoryType`.
    *   Não foram encontradas outras referências ativas a este enum dentro do código fonte do pacote `project_core_shared`.
    *   **Status:** Candidato a remoção ou refatoração da entidade `Task` para utilizá-lo.

## 3. Módulos Vazios / Scaffold
Os seguintes sub-pacotes contêm apenas estruturas de pastas com arquivos `.gitkeep` ou arquivos padrão de documentação, sem implementação lógica aparente:

*   **`packages/project/project`**:
    *   `project_client`
    *   `project_server`
    *   `project_shared`
    *   `project_ui`
*   **`packages/project/task`**:
    *   `task_client`
    *   `task_server`
    *   `task_shared`
    *   `task_ui`
*   **`packages/project/project_core`**:
    *   `project_core_client`
    *   `project_core_server`

**Observação:** Estes diretórios parecem estar preparados para desenvolvimento futuro (scaffold), mas atualmente não contêm código funcional.
