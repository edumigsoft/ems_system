# Relatório de Análise de Código Não Utilizado - Design System

**Data:** 31 de Janeiro de 2026
**Escopo:** `@packages/design_system` (shared e ui)

Este relatório identifica arquivos, classes e estruturas que aparentam não estar sendo utilizados, estão comentados ou possuem problemas de visibilidade (não exportados) dentro do pacote `design_system`.

## 1. Código Comentado ou Inativo

### `design_system_shared`

*   **`lib/src/constants/ds_text_style.dart`**
    *   **Status:** O arquivo contém a classe `DsTextStyle` totalmente comentada.
    *   **Recomendação:** Se os estilos de texto estão sendo gerenciados via `DSTableTextStyles` ou `ThemeData` (Flutter), este arquivo deve ser removido ou implementado corretamente se houver intenção de uso para tokens puros.

## 2. Tokens Definidos mas Não Utilizados Internamente

### `design_system_shared`

*   **`DSBoxShadow` (`lib/src/constants/ds_box_shadow.dart`)**
    *   **Status:** A classe define constantes de sombra (`extraSmall`, `small`, etc.) e é exportada publicamente. No entanto, uma busca no código do `design_system_ui` mostra que componentes como `DSCard` e `_NavHeader` definem suas sombras manualmente (ex: `BoxShadow(blurRadius: 10, ...)` ou usando `theme.colorScheme.shadow`) em vez de consumir este token.
    *   **Recomendação:** Refatorar os componentes do `design_system_ui` para utilizarem `DSBoxShadow` para garantir consistência, ou remover o token se a estratégia de sombras for dinâmica via `ThemeData`.

## 3. Problemas de Visibilidade (Arquivos Não Exportados)

Estes arquivos contêm código funcional, mas não são exportados pelo arquivo "barrel" principal da biblioteca (`lib/design_system_ui.dart`). Isso obriga o consumidor do pacote a importar o caminho completo do arquivo, o que quebra o encapsulamento do pacote.

### `design_system_ui`

*   **`lib/widgets/ds_side_navigation.dart` (`DSSideNavigation`)**
    *   **Status:** Componente de navegação completo e complexo, mas não consta na lista de exports em `lib/design_system_ui.dart`.
    *   **Impacto:** Consumidores não conseguem usar `DSSideNavigation` apenas importando `package:design_system_ui/design_system_ui.dart`.

*   **`lib/theme/ds_theme_extension.dart` (`DSThemeExtension`)**
    *   **Status:** Define extensões úteis em `BuildContext` (ex: `context.dsTheme`, `context.dsColors`). Não consta na lista de exports.
    *   **Impacto:** As extensões de conveniência não estão disponíveis para os desenvolvedores, reduzindo a ergonomia de uso do Design System.

## 4. Estruturas Placeholder / Vazias

As seguintes pastas/pacotes parecem ser estruturas iniciais sem implementação ativa, conforme observado também no README do projeto.

*   **`design_system_client/`**
    *   Contém apenas estrutura básica (`.gitkeep`, `.gitignore`). Não possui código fonte ativo.
*   **`design_system_server/`**
    *   Contém apenas estrutura básica.

---
**Conclusão:** Recomenda-se uma limpeza do código comentado e a revisão dos exports do pacote `design_system_ui` para incluir a navegação e as extensões de tema, que parecem ser recursos valiosos do sistema.
