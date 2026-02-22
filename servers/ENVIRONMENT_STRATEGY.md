# Estratégia de Variáveis de Ambiente (Build × Runtime)

Este documento define a estratégia oficial de separação de variáveis de ambiente do projeto (EMS e SMS), distinguindo claramente o que pertence à fase de compilação (build-time via `envied`) e o que pertence à execução (runtime via Docker e sistema operacional).

> **Status:** 🟢 **Esta estratégia já está ativa e consolidada através do repositório.** As chaves de desenvolvimento foram extraídas, isolando efetivamente o código compilado da infraestrutura em runtime.

---

## 1. Como a Aplicação Trata Variáveis Atualmente

Existem três contextos onde variáveis de ambiente são utilizadas sob essa arquitetura:

1. **Build-time:** Variáveis capturadas pelo `build_runner` (gerador `env.g.dart`) via pacote `envied` a partir do arquivo `.env.defaults`.
2. **Runtime Local:** Quando o desenvolvedor roda sem docker, extrai as variáveis de um arquivo `.env` local oculto.
3. **Runtime Docker (VPS / Produção):** Quando o container roda, o Docker-compose injeta variáveis do host/arquivo de ambiente diretamente para a instância provisionada.

### A Política de Separação

- **`Envied` / Build-time:** O `envied` injeta rigorosamente apenas **parâmetros de infraestrutura genéricos não sensíveis** (`SERVER_PORT`, paths API e Rate limits). Isso impede que `urls` e `tokens` fiquem *baked* (presos) ao binário gerado, especialmente quando compilamos no dev e publicamos no GitHub Container Registry (GHCR). 
- **Sistema Local (`Platform.environment`) / Runtime:** Os elementos **secretos** de arquitetura (`JWT_KEY`, configurações do BD) ou dinâmicos dependem de que a injeção em execução exista, assumindo precedência sob as configurações geradas pelo `envied`.

---

## 2. Posição Estrutural de Arquivos Relacionados

**`server_v1/.env.defaults`**
- Arquivo rastreado pelo Git (`git tracked`).
- Lido pelo `build_runner` e pacote `envied` em etapa de build.
- Contém: `BACKEND_PATH_API`, `SERVER_PORT`, `ACCESS_TOKEN_EXPIRES_MINUTES`, etc.
- **Regra de Ouro:** Não inserir segredos ou URIs base absolutas aqui.

**`server_v1/.env`**
- Arquivo ignorado no controle de versão (`.gitignore`).
- Usado para iniciar o servidor localmente (bare-metal) definindo tokens sigilosos para dev.
- É por aqui que os e-mails mock (`Mailhog/Mailpit`) para envio local são configurados.

**`container/.env`** e **`container/.env_example`**
- Usados unicamente no gerenciamento de contêiners docker (`docker-compose.yml`).
- Gerencia portas de orquestração interna e chaves blindadas na VPS. Devem possuir estrita segurança local (`chmod 600`).

---

## 3. Leitura Segura no Gerenciador de Dependências (`injector.dart`)

É através da validação das entradas via `Platform.environment` que a solidez de segurança do sistema se sustenta:

**A. Para Segredos Críticos (Falha Rígida):**
```dart
// Se o valor não está no Platform.environment (via deploy real ou local),
// a aplicação intencionalmente falha e aborta a execução! Não existe envied aqui.
final jwtKey = Platform.environment['JWT_KEY'] ?? (throw StateError('JWT_KEY is required'));
final verificationUrl = Platform.environment['VERIFICATION_LINK_BASE_URL'] ?? (throw StateError('URL is required'));
```

**B. Para Configurações Base (Falha Flexível / Fallback Envied):**
```dart
// Lê primeiro as variáveis locais em execução. Caso não declaradas, recorre às configurações
// básicas que foram embutidas pelo 'envied' no arquétipo '.env.defaults'.
final port = int.tryParse(Platform.environment['SERVER_PORT'] ?? '') ?? Env.serverPort;
final backendPath = Platform.environment['BACKEND_PATH_API'] ?? Env.backendPathApi;
```
