# Plano: Integração do Servidor EMS com GitHub Container Registry (GHCR)

## Context

O servidor EMS atualmente usa build local de imagens Docker (`ems_server_image:v1`), o que não é ideal para deploy em VPS de produção. A integração com GitHub Container Registry (GHCR) permitirá:

1. **Build Automatizado**: CI/CD via GitHub Actions para build e publicação automática de imagens
2. **Versionamento Consistente**: Tags semânticas (latest, 1.1.0, v1.1) sincronizadas com o arquivo VERSION
3. **Deploy Simplificado**: Pull direto de imagens pré-compiladas na VPS sem necessidade de build local
4. **Rollback Facilitado**: Capacidade de voltar para versões anteriores rapidamente
5. **Rastreabilidade**: Todas as imagens vinculadas a commits específicos via SHA

**Situação Atual:**
- Dockerfile multi-stage otimizado (dart:stable → scratch)
- Faltam pacotes `tag` e `notebook` no Dockerfile (presentes no pubspec.yaml mas não copiados)
- docker-compose.yml usa build local
- Sem workflows GitHub Actions configurados

**Objetivo:**
Configurar infraestrutura completa de CI/CD para publicar imagens Docker do servidor EMS no GitHub Packages (ghcr.io), mantendo compatibilidade com desenvolvimento local.

---

## Arquivos Críticos

### Arquivos a Criar

1. **`.github/workflows/docker-ems-server.yml`**
   - Workflow de CI/CD para build e publicação automática no GHCR
   - Triggers: push em main/develop, releases, workflow_dispatch
   - Tags: latest, semver (1.1.0), major.minor (v1.1), branch, sha

2. **`servers/ems/container/docker-compose.prod.yml`**
   - Configuração para produção usando imagem do GHCR
   - Pull de `ghcr.io/edumigsoft/ems-server:latest`
   - Healthcheck e labels para monitoramento

3. **`servers/ems/container/deploy-prod.sh`**
   - Script automatizado de deploy na VPS
   - Seleção de versão (latest ou específica)
   - Login no GHCR com PAT
   - Pull, down, up e verificação

4. **`servers/ems/container/rollback.sh`**
   - Script para rollback para versões anteriores
   - Lista de versões disponíveis
   - Pull e restart automático

5. **`servers/ems/container/DEPLOY.md`**
   - Documentação completa de autenticação GHCR
   - Instruções de deploy e rollback
   - Troubleshooting comum
   - Estrutura de tags

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

### Etapa 1: Criar Workflow GitHub Actions

**Arquivo:** `.github/workflows/docker-ems-server.yml`

**Características:**
- Build apenas quando houver mudanças relevantes:
  - Código do servidor EMS (`servers/ems/server_v1/**`)
  - Dockerfile/compose (`servers/ems/container/**`)
  - Pacotes `_shared` e `_server` usados pelo EMS
  - Arquivo VERSION
  - Próprio workflow

- Versionamento:
  - Lê versão do arquivo `/VERSION`
  - Gera tags: `latest`, `1.1.0`, `v1.1`, `develop`, `sha-abc1234`

- Otimizações:
  - Cache de camadas Docker via GitHub Actions cache
  - Build para plataforma `linux/amd64`

- Metadados:
  - Labels OCI para rastreabilidade

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

**Tags Geradas:**
- `latest` → Última versão estável (branch main)
- `1.1.0` → Versão específica do arquivo VERSION
- `v1.1` → Major.minor (facilita upgrades de patch)
- `develop` → Branch de desenvolvimento
- `sha-abc1234` → Commit específico (rastreabilidade)

**Workflow de Release:**
1. Mudanças pushadas para `develop` → Imagem `develop` publicada
2. Merge para `main` → Imagens `latest`, `1.1.0`, `v1.1` publicadas
3. GitHub Release criado → Todas as tags + tag do release

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

1. Criar diretório `.github/workflows/`
2. Criar workflow `docker-ems-server.yml`
3. Atualizar `Dockerfile` (pacotes + cache + labels)
4. Atualizar `.dockerignore` (remover duplicações + otimizar)
5. Criar `docker-compose.prod.yml`
6. Atualizar `docker-compose.yml` (renomear container + labels)
7. Criar `deploy-prod.sh` e `rollback.sh`
8. Criar `DEPLOY.md`
9. Commit e push para branch de teste
10. Validar workflow no GitHub Actions
11. Testar pull e deploy na VPS

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
- **pubspec.yaml:** `servers/ems/server_v1/pubspec.yaml` (dependências de referência)
- **VERSION:** `/VERSION` (fonte de versionamento)
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

4. **Versionamento Sincronizado:**
   - Ambos leem a mesma versão do arquivo `/VERSION`
   - Releases sincronizados para manter compatibilidade

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
- **pubspec.yaml:** `servers/sms/server_v1/pubspec.yaml`
- **VERSION:** `/VERSION` (compartilhado com EMS)
- **Infraestrutura:** `servers/INFRASTRUCTURE.md`
