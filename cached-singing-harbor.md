# Plano: Integração dos Servidores EMS e SMS com GitHub Container Registry (GHCR)
## Abordagem Híbrida: Build Local + Workflows Manuais

## Context

Os servidores EMS e SMS atualmente usam build local de imagens Docker. Este plano estabelece uma **abordagem híbrida** que combina:
- ✅ **Build local** para desenvolvimento (rápido, sem custos)
- ✅ **Workflows manuais** para releases oficiais (qualidade garantida)
- ✅ **GHCR** como registry centralizado (produção)

### Benefícios da Abordagem Híbrida

1. **Custo Zero**: Builds locais durante desenvolvimento, workflows apenas para releases
2. **Versionamento Independente**: Cada servidor com sua própria versão semântica via `pubspec.yaml`
3. **Flexibilidade**: Build local rápido + CI/CD para releases oficiais
4. **Deploy Simplificado**: Pull direto de imagens do GHCR na VPS
5. **Rollback Facilitado**: Versões anteriores disponíveis no registry
6. **Rastreabilidade**: Imagens taggeadas com versão e commit SHA

### Estratégia de Build

```
┌─────────────────────────────────────────────────────────┐
│              DESENVOLVIMENTO (90% do tempo)             │
│  • Build local no computador                           │
│  • Teste com docker-compose                            │
│  • Push manual para GHCR (opcional)                    │
│  • Custo: $0                                            │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│              RELEASES OFICIAIS (10% do tempo)           │
│  • Workflow manual via GitHub Actions                  │
│  • Build limpo e reproduzível                          │
│  • Push automático para GHCR                           │
│  • Custo: ~$0.03-0.05 por release                      │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                   PRODUÇÃO (VPS)                        │
│  • Pull de imagens do GHCR                             │
│  • Deploy via scripts automatizados                    │
│  • Rollback para versões anteriores                    │
└─────────────────────────────────────────────────────────┘
```

**Situação Atual:**
- Dockerfiles multi-stage otimizados (dart:stable → scratch)
- **EMS**: Faltam pacotes `tag` e `notebook` no Dockerfile
- **SMS**: Caminho incorreto e falta pacote `school` no Dockerfile
- docker-compose.yml usa build local
- Sem workflows GitHub Actions configurados
- Sem scripts de build/push padronizados

**Objetivo:**
Configurar infraestrutura híbrida para desenvolvimento local e CI/CD manual, com publicação de imagens no GHCR, versionamento independente e custo zero/mínimo.

---

## Arquivos Críticos

### Arquivos a Criar

**Scripts de Build Local:**

1. **`scripts/build-local.sh`**
   - Script para build local de imagens Docker
   - Suporte para EMS e SMS
   - Validação de argumentos e feedback visual

2. **`scripts/push-to-ghcr.sh`**
   - Script para push manual de imagens para GHCR
   - Login automático no GHCR
   - Tagging automático (versão + latest)

**Guia de Operações:**

3. **`servers/OPERATIONS.md`** ⭐ **NOVO**
   - **Guia completo de operações** em ordem de execução
   - Build local para desenvolvimento
   - Push manual para GHCR
   - Trigger de workflows manuais
   - Deploy em VPS
   - Rollback e troubleshooting
   - FAQs e boas práticas

**Workflows GitHub Actions (Manuais):**

4. **`.github/workflows/docker-ems-server.yml`**
   - Workflow de CI/CD para servidor EMS
   - **Trigger apenas manual** (`workflow_dispatch`)
   - Versão lida de `servers/ems/server_v1/pubspec.yaml`
   - Tags: latest, semver (1.1.0), major.minor (v1.1), sha

5. **`.github/workflows/docker-sms-server.yml`**
   - Workflow de CI/CD para servidor SMS
   - **Trigger apenas manual** (`workflow_dispatch`)
   - Versão lida de `servers/sms/server_v1/pubspec.yaml`
   - Tags: latest, semver, major.minor, sha

**Configurações de Produção:**

6. **`servers/ems/container/docker-compose.prod.yml`**
   - Configuração para produção usando imagem do GHCR
   - Pull de `ghcr.io/edumigsoft/ems-server:latest`
   - Healthcheck e labels para monitoramento

7. **`servers/sms/container/docker-compose.prod.yml`**
   - Configuração para produção usando imagem do GHCR
   - Pull de `ghcr.io/edumigsoft/sms-server:latest`
   - Porta 8080 (diferente do EMS)

**Scripts de Deploy:**

8. **`servers/ems/container/deploy-prod.sh`**
   - Script automatizado de deploy na VPS
   - Seleção de versão (latest ou específica)
   - Login no GHCR com PAT

9. **`servers/sms/container/deploy-prod.sh`**
   - Script de deploy para SMS
   - Mesma estrutura do EMS, adaptado para SMS

10. **`servers/ems/container/rollback.sh`**
    - Script para rollback de versões do EMS
    - Lista de versões disponíveis

11. **`servers/sms/container/rollback.sh`**
    - Script para rollback de versões do SMS

**Documentação:**

12. **`servers/ems/container/DEPLOY.md`**
    - Documentação específica de deploy do EMS
    - Autenticação GHCR
    - Instruções de deploy e rollback

13. **`servers/sms/container/DEPLOY.md`**
    - Documentação específica de deploy do SMS
    - Diferenças em relação ao EMS

### Arquivos a Atualizar

6. **`servers/ems/container/Dockerfile`**
   - Adicionar pacotes faltantes: `tag_shared`, `tag_server`, `notebook_shared`, `notebook_server`
   - Otimizar cache: copiar `pubspec.yaml` antes do código fonte
   - Adicionar labels OCI (source, description, licenses)

7. **`servers/ems/container/docker-compose.yml`**
   - Renomear container para `ems_server_dev` (distinguir de prod)
   - Adicionar labels para identificar ambiente de desenvolvimento

8. **`.dockerignore`**
   - Remover duplicações (linhas 1-8 e 9-15 são idênticas)
   - Adicionar exclusões para otimizar build (apps, scripts, docs, etc.)

---

## Implementação Detalhada

### Etapa 1: Criar Scripts de Build Local

**Arquivo:** `scripts/build-local.sh`

**Propósito:** Facilitar build local durante desenvolvimento sem custos.

**Características:**
- Suporte para EMS e SMS via argumento
- Leitura automática de versão do `pubspec.yaml`
- Validação de argumentos
- Feedback visual do progresso
- Tagging automático

**Uso:**
```bash
./scripts/build-local.sh ems    # Build do servidor EMS
./scripts/build-local.sh sms    # Build do servidor SMS
```

**Arquivo:** `scripts/push-to-ghcr.sh`

**Propósito:** Push manual de imagens para GHCR quando necessário.

**Características:**
- Login automático no GHCR
- Leitura de versão do `pubspec.yaml`
- Push com múltiplas tags (versão + latest)
- Validação de autenticação

**Uso:**
```bash
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX
./scripts/push-to-ghcr.sh ems    # Push do servidor EMS
./scripts/push-to-ghcr.sh sms    # Push do servidor SMS
```

### Etapa 2: Criar Guia de Operações

**Arquivo:** `servers/OPERATIONS.md`

**Propósito:** Guia completo de operações em ordem de execução.

**Seções:**
1. **Build Local (Desenvolvimento)**
   - Como fazer build local
   - Teste com docker-compose
   - Quando fazer push para GHCR

2. **Push Manual para GHCR**
   - Configuração de autenticação
   - Uso do script push-to-ghcr.sh
   - Verificação de imagens publicadas

3. **Workflows Manuais (Releases)**
   - Como triggerar workflows via GitHub UI
   - Como triggerar via GitHub CLI
   - Quando usar workflows vs push manual

4. **Deploy em VPS**
   - Uso dos scripts de deploy
   - Seleção de versões
   - Verificação de saúde

5. **Rollback e Troubleshooting**
   - Como fazer rollback
   - Problemas comuns e soluções
   - FAQs

### Etapa 3: Criar Workflows GitHub Actions (Manuais)

**Arquivo:** `.github/workflows/docker-ems-server.yml`

**Características:**
- **Trigger apenas manual** (`workflow_dispatch`) - **SEM push automático**
- Build apenas quando você decidir (releases oficiais)
- Custo: ~$0.03-0.05 por build (ou $0 se repositório público)
  - Código do servidor EMS (`servers/ems/server_v1/**`)
  - Dockerfile/compose (`servers/ems/container/**`)
  - Pacotes `_shared` e `_server` usados pelo EMS
  - Próprio workflow

- Versionamento:
  - Lê versão de `servers/ems/server_v1/pubspec.yaml`
  - Gera tags: `latest`, `1.1.0`, `v1.1`, `develop`, `sha-abc1234`
  - Versionamento independente do servidor SMS

- Otimizações:
  - Cache de camadas Docker via GitHub Actions cache
  - Build para plataforma `linux/amd64`

- Metadados:
  - Labels OCI para rastreabilidade

- Implementação de Leitura de Versão:
  ```yaml
  - name: Read EMS version from pubspec.yaml
    id: version
    run: |
      VERSION=$(grep '^version:' servers/ems/server_v1/pubspec.yaml | sed 's/version: *//' | tr -d ' ')
      echo "version=$VERSION" >> $GITHUB_OUTPUT
      echo "major_minor=v$(echo $VERSION | cut -d. -f1,2)" >> $GITHUB_OUTPUT
      echo "EMS Version: $VERSION"
  
  # Usar nos tags:
  # - ghcr.io/edumigsoft/ems-server:${{ steps.version.outputs.version }}
  # - ghcr.io/edumigsoft/ems-server:${{ steps.version.outputs.major_minor }}
  # - ghcr.io/edumigsoft/ems-server:latest
  ```

### Etapa 2: Atualizar Dockerfile

**Arquivo:** `servers/ems/container/Dockerfile`

**Mudanças:**

1. **Adicionar pacotes tag e notebook** (após linha 22):
```dockerfile
# Tag
COPY packages/tag/tag_shared /app/packages/tag/tag_shared
COPY packages/tag/tag_server /app/packages/tag/tag_server

# Notebook
COPY packages/notebook/notebook_shared /app/packages/notebook/notebook_shared
COPY packages/notebook/notebook_server /app/packages/notebook/notebook_server
```

2. **Otimizar cache de dependências** (substituir linhas 25-34):
```dockerfile
# --- 2. OTIMIZAÇÃO: Cachear camada de dependências ---
WORKDIR /app/servers/ems/server_v1

# Copiar apenas pubspec para instalar dependências primeiro
COPY servers/ems/server_v1/pubspec.yaml .

# Remover workspace e instalar deps (essa camada será cacheada)
RUN sed -i '/resolution: workspace/d' pubspec.yaml
RUN dart pub get

# --- 3. COPIAR CÓDIGO FONTE ---
COPY servers/ems/server_v1 /app/servers/ems/server_v1
```

3. **Adicionar labels** (após linha 40):
```dockerfile
# Metadados
LABEL org.opencontainers.image.source="https://github.com/edumigsoft/ems_system"
LABEL org.opencontainers.image.description="EMS Server - Backend Dart/Shelf"
LABEL org.opencontainers.image.licenses="MIT"
```

### Etapa 3: Criar docker-compose para Produção

**Arquivo:** `servers/ems/container/docker-compose.prod.yml`

**Características:**
- Container name: `ems_server_prod`
- Image: `ghcr.io/edumigsoft/ems-server:latest`
- Healthcheck para monitoramento
- Labels para identificar ambiente de produção
- Mesma configuração de rede e env_file do desenvolvimento

### Etapa 4: Atualizar docker-compose de Desenvolvimento

**Arquivo:** `servers/ems/container/docker-compose.yml`

**Mudanças:**
- Container name: `ems_server_dev` (ao invés de `ems_server`)
- Adicionar labels: `com.ems.environment=development`

### Etapa 5: Criar Scripts de Deploy

**Arquivos:**
- `servers/ems/container/deploy-prod.sh`: Deploy automatizado com seleção de versão
- `servers/ems/container/rollback.sh`: Rollback para versão anterior

**Recursos:**
- Validação de diretório e arquivo .env
- Login automático no GHCR com PAT
- Seleção interativa de versão
- Pull, down, up automático
- Exibição de logs e status

### Etapa 6: Criar Documentação de Deploy

**Arquivo:** `servers/ems/container/DEPLOY.md`

**Conteúdo:**
- Pré-requisitos (criação de PAT)
- Configuração inicial na VPS
- Instruções de deploy e atualização
- Comandos de rollback
- Troubleshooting comum
- Estrutura de tags
- Considerações de segurança

### Etapa 7: Atualizar .dockerignore

**Arquivo:** `.dockerignore` (raiz)

**Mudanças:**
- Remover duplicações (consolidar linhas 1-15)
- Adicionar exclusões adicionais:
  - Apps e servidores não relacionados ao EMS
  - Scripts de automação
  - Documentação
  - Arquivos de desenvolvimento (.env, *.sh)
  - Diretórios do GitHub

---

## Estrutura de Versionamento

**Estratégia: Versionamento Independente por Servidor**

Cada servidor mantém sua própria versão no respectivo `pubspec.yaml`:
- **EMS**: `servers/ems/server_v1/pubspec.yaml` → `version: 1.1.0`
- **SMS**: `servers/sms/server_v1/pubspec.yaml` → `version: 1.1.0`

**Tags Geradas (por servidor):**
- `latest` → Última versão estável (branch main)
- `1.1.0` → Versão específica do pubspec.yaml
- `v1.1` → Major.minor (facilita upgrades de patch)
- `develop` → Branch de desenvolvimento
- `sha-abc1234` → Commit específico (rastreabilidade)

**Workflow de Release:**
1. Mudanças pushadas para `develop` → Imagem `develop` publicada (se paths relevantes mudaram)
2. Merge para `main` → Imagens `latest`, `1.1.0`, `v1.1` publicadas
3. Incrementar versão no `pubspec.yaml` → Novas tags geradas no próximo push

**Vantagens:**
- ✅ EMS e SMS evoluem independentemente
- ✅ Builds apenas quando servidor específico muda
- ✅ Semver correto por servidor
- ✅ Deploy independente (EMS v1.3.0, SMS v1.1.5)

---

## Autenticação na VPS

**Personal Access Token (PAT):**
1. Criar em: https://github.com/settings/tokens
2. Scope: `read:packages` (mínimo necessário para pull)
3. Validade: 90 dias (rotacionar regularmente)

**Configurar na VPS:**
```bash
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX
echo "$GITHUB_TOKEN" | docker login ghcr.io -u SEU_USUARIO_GITHUB --password-stdin
```

**Variável Persistente (opcional):**
```bash
echo 'export GITHUB_TOKEN=ghp_XXX' >> ~/.bashrc
source ~/.bashrc
```

---

## Verificação End-to-End

### 1. Validar Build Local

```bash
cd servers/ems/container
docker build -f Dockerfile -t ems-server-test:local ../../..
docker images | grep ems-server-test
```

**Esperado:** Imagem criada com sucesso (~20-50MB devido a scratch)

### 2. Testar Desenvolvimento Local

```bash
cd servers/ems/container
docker-compose up --build -d
docker-compose logs -f
```

**Esperado:**
- Container `ems_server_dev` iniciado
- Logs mostrando servidor rodando na porta 8181

### 3. Testar Workflow GitHub Actions

**Trigger de Teste:**
```bash
# Criar branch de teste
git checkout -b test/ghcr-integration

# Fazer commit de mudanças
git add .
git commit -m "ci: Add GitHub Container Registry integration"

# Push para ativar workflow
git push origin test/ghcr-integration
```

**Validação:**
1. Acessar: https://github.com/edumigsoft/ems_system/actions
2. Verificar workflow "Build and Publish EMS Server Docker Image" executando
3. Aguardar conclusão (~5-10 minutos)
4. Verificar imagem publicada: https://github.com/edumigsoft/ems_system/pkgs/container/ems-server

### 4. Testar Pull da Imagem GHCR

**Na VPS:**
```bash
# Login no GHCR
echo "$GITHUB_TOKEN" | docker login ghcr.io -u SEU_USUARIO --password-stdin

# Pull da imagem
docker pull ghcr.io/edumigsoft/ems-server:latest

# Verificar
docker images | grep ems-server
```

**Esperado:** Imagem baixada com sucesso

### 5. Testar Deploy Produção

**Na VPS:**
```bash
cd /caminho/para/servers/ems/container

# Garantir que .env existe
cp .env.example .env
nano .env  # Ajustar credenciais

# Executar deploy
chmod +x deploy-prod.sh
./deploy-prod.sh
```

**Validação:**
1. Script solicita seleção de versão
2. Login no GHCR executado com sucesso
3. Container `ems_server_prod` iniciado
4. Logs exibidos sem erros
5. Servidor acessível na porta configurada

### 6. Testar Rollback

```bash
cd /caminho/para/servers/ems/container
chmod +x rollback.sh
./rollback.sh
```

**Validação:**
1. Script lista versões disponíveis
2. Rollback para versão anterior executado
3. Container reiniciado com versão antiga
4. Logs exibidos confirmando versão

### 7. Testar Healthcheck

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

**Esperado:** Status mostrando "(healthy)" após ~40 segundos

---

## Notas Importantes

1. **Nome da Organização/Usuário:**
   - Workflow usa `edumigsoft/ems-server`
   - Verificar se este é o nome correto da organização/usuário no GitHub
   - Ajustar se necessário no workflow e documentação

2. **Visibilidade da Imagem:**
   - Por padrão, imagens são privadas (apenas organização tem acesso)
   - Configurar visibilidade em: Package Settings → Danger Zone

3. **Rede Docker:**
   - Rede `ems_system_net` deve existir na VPS antes do deploy
   - Criar com: `docker network create ems_system_net`

4. **Banco de Dados:**
   - Container PostgreSQL deve estar rodando antes do servidor EMS
   - Validar conectividade: `docker exec ems_server_prod env | grep DB_`

5. **Segurança:**
   - Nunca commitar arquivo `.env` (já no .gitignore)
   - PAT com permissões mínimas (`read:packages`)
   - Rotacionar PAT a cada 90 dias
   - Usar HTTPS para comunicação com GHCR

---

## Ordem de Execução

### Fase 1: Infraestrutura Local (Desenvolvimento)

1. Criar diretório `scripts/`
2. Criar `scripts/build-local.sh` (build local de imagens)
3. Criar `scripts/push-to-ghcr.sh` (push manual para GHCR)
4. Criar `servers/OPERATIONS.md` ⭐ (guia completo de operações)
5. Atualizar `Dockerfile` do EMS (pacotes + cache + labels)
6. Atualizar `Dockerfile` do SMS (caminhos + pacotes + cache + labels)
7. Atualizar `.dockerignore` (remover duplicações + otimizar)
8. Atualizar `docker-compose.yml` de dev (renomear containers + labels)

### Fase 2: Workflows Manuais (CI/CD)

9. Criar diretório `.github/workflows/`
10. Criar `docker-ems-server.yml` (workflow manual para EMS)
11. Criar `docker-sms-server.yml` (workflow manual para SMS)

### Fase 3: Infraestrutura de Produção

12. Criar `docker-compose.prod.yml` para EMS
13. Criar `docker-compose.prod.yml` para SMS
14. Criar `deploy-prod.sh` para EMS
15. Criar `deploy-prod.sh` para SMS
16. Criar `rollback.sh` para EMS
17. Criar `rollback.sh` para SMS
18. Criar `DEPLOY.md` para EMS
19. Criar `DEPLOY.md` para SMS

### Fase 4: Validação

20. Testar build local (EMS e SMS)
21. Testar push manual para GHCR
22. Commit e push para branch de teste
23. Trigger workflow manual via GitHub UI
24. Validar imagens no GHCR
25. Testar deploy na VPS

**Nota:** A Fase 1 é prioritária e suficiente para desenvolvimento. Fases 2-4 podem ser implementadas gradualmente conforme necessidade.

---

## Riscos e Mitigações

**Risco:** Build falhar por pacotes faltantes
- **Mitigação:** Dockerfile atualizado inclui todos os pacotes do pubspec.yaml

**Risco:** Workflow não detectar mudanças relevantes
- **Mitigação:** Paths configurados cobrem todos os diretórios de pacotes _shared e _server

**Risco:** Autenticação GHCR falhar na VPS
- **Mitigação:** Documentação detalhada de criação de PAT e login

**Risco:** Rollback para versão inexistente
- **Mitigação:** Script de rollback lista versões disponíveis antes de executar

**Risco:** Rede Docker não existir na VPS
- **Mitigação:** Documentação inclui criação da rede como pré-requisito

---

## Arquivos de Referência

- **Dockerfile atual:** `servers/ems/container/Dockerfile`
- **docker-compose atual:** `servers/ems/container/docker-compose.yml`
- **pubspec.yaml:** `servers/ems/server_v1/pubspec.yaml` (dependências e **fonte de versionamento**)
- **Infraestrutura:** `servers/INFRASTRUCTURE.md` (documentação existente)

---

## Adequações para o Servidor SMS

### Contexto do Servidor SMS

O servidor SMS segue a mesma arquitetura do servidor EMS, mas com algumas diferenças:

- **Porta padrão:** 8080 (EMS usa 8181)
- **Caminho do servidor:** `servers/sms/server_v1` (correto, não `servers/sms_server/server_v1` como está no Dockerfile atual)
- **Dependências:** Usa `school_server` além dos pacotes core, auth e user
- **Estrutura:** Mesma base de pacotes compartilhados (_shared e _server)

**Problemas Identificados no Dockerfile Atual:**
1. Caminho incorreto: usa `servers/sms_server/server_v1` ao invés de `servers/sms/server_v1`
2. Falta pacote `school_server` (presente no pubspec.yaml mas não copiado)
3. Sem otimização de cache de dependências
4. Sem labels OCI para rastreabilidade

### Arquivos a Criar (SMS)

1. **`.github/workflows/docker-sms-server.yml`**
   - Workflow de CI/CD específico para o servidor SMS
   - Triggers: mudanças em `servers/sms/**`, pacotes relevantes, VERSION
   - Tags: `latest`, semver, branch, sha (mesmo padrão do EMS)
   - Imagem: `ghcr.io/edumigsoft/sms-server`

2. **`servers/sms/container/docker-compose.prod.yml`**
   - Configuração para produção usando imagem do GHCR
   - Pull de `ghcr.io/edumigsoft/sms-server:latest`
   - Porta: 8080 (diferente do EMS)
   - Healthcheck e labels para monitoramento

3. **`servers/sms/container/deploy-prod.sh`**
   - Script automatizado de deploy na VPS
   - Mesma estrutura do script do EMS, adaptado para SMS
   - Seleção de versão e login no GHCR

4. **`servers/sms/container/rollback.sh`**
   - Script para rollback de versões
   - Adaptado para o container `sms_server_prod`

5. **`servers/sms/container/DEPLOY.md`**
   - Documentação específica do deploy do SMS
   - Diferenças em relação ao EMS (porta, dependências)
   - Instruções de deploy conjunto (EMS + SMS)

### Arquivos a Atualizar (SMS)

6. **`servers/sms/container/Dockerfile`**
   
   **Correções Críticas:**
   - Corrigir caminho: `servers/sms/server_v1` (linhas 24, 27, 43)
   - Adicionar pacote `school_server` (após linha 17)
   
   **Otimizações:**
   - Adicionar cache de dependências (copiar pubspec.yaml antes do código)
   - Adicionar labels OCI
   
   **Mudanças Detalhadas:**
   
   ```dockerfile
   # Após linha 17 (user_server), adicionar:
   COPY packages/school/school_shared /app/packages/school/school_shared
   COPY packages/school/school_server /app/packages/school/school_server
   
   # Substituir linhas 22-32 por:
   # --- 2. OTIMIZAÇÃO: Cachear camada de dependências ---
   WORKDIR /app/servers/sms/server_v1
   
   # Copiar apenas pubspec para instalar dependências primeiro
   COPY servers/sms/server_v1/pubspec.yaml .
   
   # Remover workspace e instalar deps (essa camada será cacheada)
   RUN sed -i '/resolution: workspace/d' pubspec.yaml
   RUN dart pub get
   
   # --- 3. COPIAR CÓDIGO FONTE ---
   COPY servers/sms/server_v1 /app/servers/sms/server_v1
   
   # Após linha 35 (compilação), adicionar labels:
   # Metadados
   LABEL org.opencontainers.image.source="https://github.com/edumigsoft/ems_system"
   LABEL org.opencontainers.image.description="SMS Server - Backend Dart/Shelf"
   LABEL org.opencontainers.image.licenses="MIT"
   
   # Corrigir linha 43:
   COPY --from=build /app/servers/sms/server_v1/bin/server /app/bin/server
   ```

7. **`servers/sms/container/docker-compose.yml`**
   - Renomear container para `sms_server_dev` (distinguir de prod)
   - Adicionar labels para identificar ambiente de desenvolvimento
   - Manter porta 8080

### Workflow GitHub Actions para SMS

**Arquivo:** `.github/workflows/docker-sms-server.yml`

**Diferenças em relação ao workflow do EMS:**

- **Nome:** "Build and Publish SMS Server Docker Image"
- **Paths monitorados:**
  ```yaml
  paths:
    - 'servers/sms/server_v1/**'
    - 'servers/sms/container/**'
    - 'packages/core/**'
    - 'packages/open_api/**'
    - 'packages/auth/**'
    - 'packages/user/**'
    - 'packages/school/**'  # Adicional para SMS
    - 'VERSION'
    - '.github/workflows/docker-sms-server.yml'
  ```

- **Context e Dockerfile:**
  ```yaml
  context: .
  file: ./servers/sms/container/Dockerfile
  ```

- **Imagem:**
  ```yaml
  images: ghcr.io/edumigsoft/sms-server
  ```

- **Labels:**
  ```yaml
  org.opencontainers.image.title=SMS Server
  org.opencontainers.image.description=SMS System Server - Backend Dart/Shelf
  ```

- **Implementação de Leitura de Versão:**
  ```yaml
  - name: Read SMS version from pubspec.yaml
    id: version
    run: |
      VERSION=$(grep '^version:' servers/sms/server_v1/pubspec.yaml | sed 's/version: *//' | tr -d ' ')
      echo "version=$VERSION" >> $GITHUB_OUTPUT
      echo "major_minor=v$(echo $VERSION | cut -d. -f1,2)" >> $GITHUB_OUTPUT
      echo "SMS Version: $VERSION"
  
  # Usar nos tags:
  # - ghcr.io/edumigsoft/sms-server:${{ steps.version.outputs.version }}
  # - ghcr.io/edumigsoft/sms-server:${{ steps.version.outputs.major_minor }}
  # - ghcr.io/edumigsoft/sms-server:latest
  ```

### Docker Compose Produção (SMS)

**Arquivo:** `servers/sms/container/docker-compose.prod.yml`

**Características:**

```yaml
services:
  sms_server:
    container_name: sms_server_prod
    image: ghcr.io/edumigsoft/sms-server:latest
    ports:
      - "8080:8080"  # Porta diferente do EMS
    env_file:
      - .env
    networks:
      - ems_system_net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    labels:
      com.ems.service: "sms-server"
      com.ems.environment: "production"

networks:
  ems_system_net:
    external: true
```

### Scripts de Deploy (SMS)

**Arquivo:** `servers/sms/container/deploy-prod.sh`

**Adaptações:**
- Container name: `sms_server_prod`
- Imagem: `ghcr.io/edumigsoft/sms-server`
- Porta de verificação: 8080
- Arquivo compose: `docker-compose.prod.yml`

**Arquivo:** `servers/sms/container/rollback.sh`

**Adaptações:**
- Container name: `sms_server_prod`
- Imagem base: `ghcr.io/edumigsoft/sms-server`

### Documentação de Deploy (SMS)

**Arquivo:** `servers/sms/container/DEPLOY.md`

**Seções Específicas:**

1. **Diferenças em relação ao EMS:**
   - Porta 8080 vs 8181
   - Dependência adicional: school_server
   - Mesmo processo de autenticação GHCR

2. **Deploy Conjunto (EMS + SMS):**
   ```bash
   # Deploy de ambos os servidores
   cd /caminho/para/servers/ems/container
   ./deploy-prod.sh
   
   cd /caminho/para/servers/sms/container
   ./deploy-prod.sh
   ```

3. **Verificação de Saúde:**
   ```bash
   # Verificar ambos os servidores
   docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
   
   # Healthcheck específico
   curl http://localhost:8080/health  # SMS
   curl http://localhost:8181/health  # EMS
   ```

### Ordem de Execução (SMS)

1. Corrigir `Dockerfile` (caminhos + pacote school + cache + labels)
2. Atualizar `docker-compose.yml` (renomear container + labels)
3. Criar workflow `.github/workflows/docker-sms-server.yml`
4. Criar `docker-compose.prod.yml`
5. Criar `deploy-prod.sh` e `rollback.sh`
6. Criar `DEPLOY.md`
7. Commit e push para branch de teste
8. Validar workflow no GitHub Actions
9. Testar pull e deploy na VPS

### Verificação End-to-End (SMS)

#### 1. Validar Build Local

```bash
cd servers/sms/container
docker build -f Dockerfile -t sms-server-test:local ../../..
docker images | grep sms-server-test
```

**Esperado:** Imagem criada com sucesso (~20-50MB)

#### 2. Testar Desenvolvimento Local

```bash
cd servers/sms/container
docker-compose up --build -d
docker-compose logs -f
```

**Esperado:**
- Container `sms_server_dev` iniciado
- Logs mostrando servidor rodando na porta 8080

#### 3. Testar Workflow GitHub Actions

**Trigger de Teste:**
```bash
git checkout -b test/sms-ghcr-integration
git add .
git commit -m "ci: Add GitHub Container Registry integration for SMS server"
git push origin test/sms-ghcr-integration
```

**Validação:**
1. Verificar workflow "Build and Publish SMS Server Docker Image" executando
2. Aguardar conclusão (~5-10 minutos)
3. Verificar imagem: https://github.com/edumigsoft/ems_system/pkgs/container/sms-server

#### 4. Testar Deploy Produção

```bash
cd /caminho/para/servers/sms/container
chmod +x deploy-prod.sh
./deploy-prod.sh
```

**Validação:**
- Container `sms_server_prod` iniciado
- Servidor acessível na porta 8080
- Healthcheck mostrando "(healthy)"

#### 5. Testar Deploy Conjunto (EMS + SMS)

```bash
# Verificar ambos os servidores rodando
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Verificar conectividade
curl http://localhost:8080/health  # SMS
curl http://localhost:8181/health  # EMS
```

**Esperado:**
- Ambos os containers rodando
- Ambos os healthchecks respondendo
- Portas 8080 e 8181 acessíveis

### Notas Importantes (SMS)

1. **Porta Diferente:**
   - SMS usa porta 8080
   - EMS usa porta 8181
   - Não há conflito ao rodar ambos simultaneamente

2. **Dependências Compartilhadas:**
   - Ambos usam os mesmos pacotes core, auth, user
   - SMS adiciona school_server
   - Mudanças em pacotes compartilhados afetam ambos os workflows

3. **Rede Docker:**
   - Ambos os servidores usam a mesma rede `ems_system_net`
   - Facilita comunicação entre serviços se necessário

4. **Versionamento Independente:**
   - EMS lê versão de `servers/ems/server_v1/pubspec.yaml`
   - SMS lê versão de `servers/sms/server_v1/pubspec.yaml`
   - Cada servidor evolui no seu próprio ritmo (ex: EMS v1.3.0, SMS v1.1.5)

5. **Deploy Independente:**
   - Cada servidor pode ser deployado independentemente
   - Rollback independente para cada serviço
   - Facilita manutenção e troubleshooting

### Riscos e Mitigações (SMS)

**Risco:** Caminho incorreto no Dockerfile causar falha de build
- **Mitigação:** Correção documentada de `servers/sms_server` para `servers/sms`

**Risco:** Pacote school_server faltante causar erro de compilação
- **Mitigação:** Dockerfile atualizado inclui todos os pacotes do pubspec.yaml

**Risco:** Conflito de portas entre EMS e SMS
- **Mitigação:** Portas diferentes (8080 vs 8181) documentadas claramente

**Risco:** Workflows disparando builds desnecessários
- **Mitigação:** Paths específicos para cada servidor evitam builds cruzados

### Arquivos de Referência (SMS)

- **Dockerfile atual:** `servers/sms/container/Dockerfile`
- **docker-compose atual:** `servers/sms/container/docker-compose.yml`
- **pubspec.yaml:** `servers/sms/server_v1/pubspec.yaml` (dependências e **fonte de versionamento**)
- **Infraestrutura:** `servers/INFRASTRUCTURE.md`
