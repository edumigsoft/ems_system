# Relatório de Análise de Código: @packages/user

A análise foi realizada nos diretórios e arquivos do pacote `user` (`user_shared`, `user_server`, `user_client`, `user_ui`). Abaixo estão os itens identificados como não utilizados ou com potencial de limpeza.

## 1. Arquivos e Classes Não Utilizados

### `user_shared`

*   **Arquivo**: `packages/user/user_shared/lib/src/validators/user_validators_zard.dart`
    *   **Classes**: `UserCreateValidatorZard`, `UserUpdateValidatorZard`, `UserCreateAdminValidatorZard`
    *   **Diagnóstico**: Embora o pacote `user_ui` tenha dependência de `zard_form`, a validação nos formulários (ex: `ManageUsersPage.dart`) está sendo feita manualmente com lógica imperativa dentro dos `validator` dos `TextFormField`. No servidor (`UserRoutes.dart`), são utilizados os validadores padrão (`UserUpdateValidator`, `UserCreateAdminValidator`) e não as versões Zard.
    *   **Recomendação**: Remover se não houver planos de migração para Zard, ou refatorar a UI/Server para utilizá-los.

*   **Classe**: `UserCreateValidator` (em `user_validators.dart`)
    *   **Diagnóstico**: Dentro do pacote `@packages/user`, esta classe não possui referências diretas de uso.
        *   O `user_server` utiliza `UserCreateAdminValidator` para criação administrativa.
        *   O `user_client` não implementa criação pública (`create` lança exceção).
    *   **Observação**: É provável que esta classe seja utilizada pelo pacote `auth` (fluxo de registro público), dada a natureza compartilhada do módulo. Se o `auth_server` a consome, ela **deve ser mantida**.

## 2. Métodos Não Utilizados

### `user_client`

*   **Classe**: `SettingsStorage` (`packages/user/user_client/lib/src/storage/settings_storage.dart`)
    *   **Método**: `clearSettings()`
        *   **Diagnóstico**: Definido para limpar as configurações (útil em logout), mas não é chamado em nenhum lugar do `SettingsViewModel` ou `ProfileViewModel`. O `UserModule` também não parece orquestrar uma limpeza de configurações ao sair.
    *   **Método**: `hasSettings()`
        *   **Diagnóstico**: Definido para verificar existência, mas não há referências de uso no código fornecido.

## 3. Observações de Implementação

*   **Duplicidade de Lógica de Validação**:
    *   A UI (`ManageUsersPage`) reimplementa lógica de validação (tamanho de nome, formato de email, username) que já existe nos Validators do `user_shared`. Isso viola o princípio DRY (Don't Repeat Yourself) e pode gerar inconsistências entre Front e Back.
    *   **Sugestão**: Utilizar os validadores do `user_shared` dentro da UI para garantir consistência.

*   **Definição de `UsersListResponse`**:
    *   A classe `UsersListResponse` em `user_shared` é usada para tipagem no Client (Retrofit), mas no Server (`UserRoutes.dart`), a resposta JSON é construída manualmente (`jsonEncode({...})`) em vez de utilizar `UsersListResponse(...).toJson()`. Isso aumenta o risco de desalinhamento entre contrato e implementação.

---
**Conclusão**: O pacote está bem estruturado, mas contém artefatos de validação (Zard) que parecem ser "código morto" ou de uma refatoração incompleta, além de métodos utilitários de storage que ainda não foram conectados aos fluxos de UI.
