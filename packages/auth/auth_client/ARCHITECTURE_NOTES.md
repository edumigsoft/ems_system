# Architecture Notes - auth_client

## Exceção Arquitetural: Dependência do Flutter

### Contexto

De acordo com ADR-0005 (Package Structure), pacotes `*_client` devem ser **Dart puro** sem dependências do Flutter. No entanto, `auth_client` possui dependência do Flutter SDK.

### Justificativa

Esta é uma **exceção documentada e aceitável** pelos seguintes motivos:

1. **Plugins Flutter**: O pacote usa `flutter_secure_storage`, que é um **plugin Flutter** e requer o Flutter SDK para funcionar em todas as plataformas (Android, iOS, Web, Desktop).

2. **Sem Código de UI**: Apesar da dependência do Flutter SDK, o código em `auth_client`:
   - ❌ **NÃO usa** widgets ou componentes de UI
   - ❌ **NÃO depende** de `BuildContext` ou ciclo de vida de widgets
   - ✅ **USA apenas** plugins de plataforma (secure storage)
   - ✅ **É logicamente** código de cliente/repository

3. **Separação Lógica Mantida**: A separação arquitetural permanece clara:
   - `auth_shared`: Domínio puro, entidades, regras de negócio
   - `auth_client`: **Repositories, HTTP clients, storage** (este pacote)
   - `auth_ui`: Widgets, ViewModels, UI state
   - `auth_server`: Backend, rotas, controllers

### Alternativas Consideradas

#### Opção 1: Mover Storages para auth_ui
**Rejeitada**: Repositories em `auth_client` precisariam acessar storage de `auth_ui`, criando dependência inversa.

#### Opção 2: Abstração com Injeção de Dependência
**Complexidade desnecessária**: Criaria interfaces em `auth_shared` e implementações em `auth_ui`, aumentando significativamente a complexidade para pouco ganho.

#### Opção 3: Usar SharedPreferences ao invés de SecureStorage
**Inseguro**: Tokens de autenticação devem ser armazenados de forma segura, especialmente em mobile.

### Regra Atualizada

**Pacotes `*_client` podem depender do Flutter SDK quando necessário para plugins**, desde que:
- ✅ Não usem código de UI (widgets, BuildContext, etc.)
- ✅ A dependência seja apenas para plugins de plataforma
- ✅ Esteja documentado neste arquivo

### Pacotes Afetados

- ✅ `auth_client` - Usa `flutter_secure_storage`
- ⚠️ `user_client` - **NÃO** usa Flutter (usa apenas dependências transitivas)

### Referências

- ADR-0005: Package Structure
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- Issue: Web compatibility fixes (2026-02-17)
