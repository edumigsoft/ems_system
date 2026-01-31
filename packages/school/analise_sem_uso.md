# Relatório de Análise de Código Sem Uso - @packages/school

Esta análise identificou arquivos e classes dentro do diretório `@packages/school/` que não estão sendo utilizados no projeto atual.

## Resumo dos Achados

Foram identificados **4 itens principais** (arquivos/classes) que não possuem referências externas ou utilidade prática no fluxo atual do sistema.

---

## Itens Sem Uso Identificados

### 1. Entidade `School`
- **Arquivo:** `school_shared/lib/src/domain/entities/school.dart`
- **Motivo:** A entidade `SchoolDetails` é utilizada em todos os fluxos de listagem, busca e visualização. A entidade base `School` não possui referências fora de seu próprio arquivo e do `school_model.dart`.

### 2. Modelo `SchoolModel`
- **Arquivo:** `school_shared/lib/src/data/models/school_model.dart`
- **Motivo:** Segue a mesma lógica da entidade. O sistema utiliza `SchoolDetailsModel` e `SchoolCreateModel` para comunicação com a API e persistência. `SchoolModel` não é instanciado ou referenciado em repositórios ou services.

### 3. DTO `SchoolUpdate`
- **Arquivo:** `school_shared/lib/src/domain/dtos/school_update.dart`
- **Motivo:** Embora exista um `UpdateUseCase`, ele e o `SchoolRepository` (tanto client quanto server) utilizam a entidade `SchoolDetails` diretamente para operações de atualização, ignorando o DTO `SchoolUpdate`.

### 4. Extensão `SchoolDetailsExtension`
- **Arquivo:** `school_shared/lib/src/extensions/school_extensions.dart`
- **Motivo:** A extensão define apenas o método `toDetails()` que retorna `this`. Não há chamadas para este método no codebase, e sua funcionalidade atual é redundante.

---

## Conclusão e Recomendações

Os itens acima podem ser removidos com segurança para reduzir a complexidade e o tamanho do pacote `school_shared`. Recomenda-se:
1. Remover os arquivos `school.dart`, `school_model.dart` e `school_update.dart`.
2. Remover o arquivo `school_extensions.dart` (ou mantê-lo vazio/com outras extensões se houver planos futuros).
3. Atualizar o arquivo de exportação `school_shared.dart` para remover as referências aos arquivos deletados.

> [!NOTE]
> Nenhum arquivo foi alterado durante esta análise, conforme solicitado.
