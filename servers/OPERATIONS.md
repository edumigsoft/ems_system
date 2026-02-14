# Guia de Operações - Servidores EMS e SMS

Este guia documenta todas as operações relacionadas ao build, publicação e deploy dos servidores EMS e SMS, seguindo a abordagem híbrida de desenvolvimento local + CI/CD manual.

## Índice

1. [Workflow Rápido (PC → GHCR → VPS)](#1-workflow-rápido-pc--ghcr--vps) ⭐ **Novo**
2. [Build Local (Desenvolvimento)](#2-build-local-desenvolvimento)
3. [Push Manual para GHCR](#3-push-manual-para-ghcr)
4. [Workflows Manuais (Releases)](#4-workflows-manuais-releases)
5. [Deploy em VPS](#5-deploy-em-vps)
6. [Rollback e Troubleshooting](#6-rollback-e-troubleshooting)
7. [FAQs](#7-faqs)

---

## 1. Workflow Rápido (PC → GHCR → VPS)

Este é o fluxo mais simples e direto para deploy: build no PC local, push para GHCR, e atualização na VPS.

### 1.1 Visão Geral

```
PC Local:                    GHCR:                    VPS:
┌─────────────────┐         ┌──────────────────┐     ┌──────────────────┐
│ Build imagem    │         │ Registry         │     │ Pull + Restart   │
│ local           │ ──────→ │ (ghcr.io)        │ ──→ │ container        │
└─────────────────┘         └──────────────────┘     └──────────────────┘
  build-local.sh              push-to-ghcr.sh           update.sh
  (~2-3 min)                  (~2-3 min)                (~1-2 min)
```

**Tempo total:** ~5-8 minutos

### 1.2 Quick Start (Opção Rápida)

#### No PC Local

```bash
# Opção 1: Scripts separados (recomendado)
./scripts/build-local.sh ems
GITHUB_TOKEN=ghp_XXX ./scripts/push-to-ghcr.sh ems

# Opção 2: Script combinado (mais conveniente)
./servers/ems/container/build-and-push.sh
```

#### Na VPS (via SSH)

```bash
ssh user@vps
cd /caminho/ems_system/servers/ems/container
./update.sh  # Script simplificado (sempre usa latest)
```

### 1.3 Quando Usar Este Workflow

✅ **Use quando:**
- Você quer deploy rápido de mudanças para teste/produção
- Você não precisa escolher versão específica (sempre usa `latest`)
- Você quer simplicidade e velocidade

❌ **Não use quando:**
- Você precisa escolher versão específica → Use `deploy-prod.sh` na VPS
- Você quer build reproduzível oficial → Use workflows GitHub Actions (seção 4)

### 1.4 Scripts Disponíveis

| Local | Script | Descrição |
|-------|--------|-----------|
| **PC Local** | `scripts/build-local.sh ems` | Build da imagem Docker |
| **PC Local** | `scripts/push-to-ghcr.sh ems` | Push para GHCR |
| **PC Local** | `servers/ems/container/build-and-push.sh` | Build + Push combinados |
| **VPS** | `servers/ems/container/update.sh` | **Atualização rápida** (usa `latest`) |
| **VPS** | `servers/ems/container/deploy-prod.sh` | Deploy completo (escolhe versão) |
| **VPS** | `servers/ems/container/rollback.sh` | Rollback para versão anterior |

### 1.5 Documentação Rápida

Para um guia passo a passo completo, consulte:
- **Quick Start:** `servers/ems/container/QUICKSTART.md` (guia rápido de referência)
- **Este documento:** Detalhes completos de todas as operações

---

## 2. Build Local (Desenvolvimento)

### 2.1 Quando Usar

Use build local durante o desenvolvimento para:
- ✅ Testar mudanças rapidamente
- ✅ Validar Dockerfile sem custos
- ✅ Rodar com docker-compose localmente
- ✅ Debug de problemas de build

**Custo:** $0 (executado localmente)

### 2.2 Como Fazer Build Local

```bash
# Build do servidor EMS
./scripts/build-local.sh ems

# Build do servidor SMS
./scripts/build-local.sh sms
```

O script automaticamente:
- Lê a versão do `pubspec.yaml` do servidor
- Executa o build do Docker
- Cria tags: `{server}-server:{version}` e `{server}-server:latest`
- Exibe instruções de próximos passos

### 2.3 Testando com Docker Compose

**EMS:**
```bash
cd servers/ems/container
docker-compose up -d
docker-compose logs -f
```

**SMS:**
```bash
cd servers/sms/container
docker-compose up -d
docker-compose logs -f
```

**Verificação:**
```bash
# Healthcheck EMS
curl http://localhost:8181/health

# Healthcheck SMS
curl http://localhost:8080/health
```

### 2.4 Quando Fazer Push para GHCR

Após build local, faça push manual para GHCR quando:
- ✅ Você quer compartilhar a imagem com a equipe
- ✅ Você quer testar deploy na VPS sem usar workflow
- ✅ Você fez mudanças pequenas que não justificam um workflow completo

Para releases oficiais, prefira usar workflows manuais (seção 3).

---

## 3. Push Manual para GHCR

### 3.1 Pré-requisitos

**Criar Personal Access Token (PAT):**
1. Acesse: https://github.com/settings/tokens
2. Clique em "Generate new token (classic)"
3. Scopes necessários: `write:packages`, `read:packages`
4. Validade recomendada: 90 dias
5. Copie o token gerado (ex: `ghp_XXXXXXXXXXXXXXXXXXXX`)

**Configurar Token:**
```bash
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX

# Opcional: Tornar persistente
echo 'export GITHUB_TOKEN=ghp_XXX' >> ~/.bashrc
source ~/.bashrc
```

### 3.2 Push Manual

```bash
# Push do servidor EMS
GITHUB_TOKEN=ghp_XXX ./scripts/push-to-ghcr.sh ems

# Push do servidor SMS
GITHUB_TOKEN=ghp_XXX ./scripts/push-to-ghcr.sh sms
```

O script automaticamente:
- Valida o token GitHub
- Verifica se a imagem local existe
- Faz login no GHCR
- Cria tags: `{version}`, `v{major.minor}`, `latest`
- Faz push de todas as tags
- Exibe link para verificar no GHCR

### 3.3 Verificar Imagens Publicadas

**Via Web:**
- EMS: https://github.com/edumigsoft/ems_system/pkgs/container/ems-server
- SMS: https://github.com/edumigsoft/ems_system/pkgs/container/sms-server

**Via CLI:**
```bash
# Listar tags disponíveis (requer gh CLI)
gh api /orgs/edumigsoft/packages/container/ems-server/versions
gh api /orgs/edumigsoft/packages/container/sms-server/versions
```

---

## 4. Workflows Manuais (Releases)

### 4.1 Quando Usar Workflows

Use workflows GitHub Actions para:
- ✅ Releases oficiais (v1.2.0, v1.3.0, etc.)
- ✅ Builds limpos e reproduzíveis
- ✅ Rastreabilidade completa (commit SHA, labels OCI)
- ✅ Garantia de qualidade (ambiente isolado)

**Custo:** ~$0.03-0.05 por build (ou $0 se repositório público)

### 4.2 Trigger via GitHub UI

1. Acesse: https://github.com/edumigsoft/ems_system/actions
2. Selecione o workflow desejado:
   - "Build and Publish EMS Server Docker Image"
   - "Build and Publish SMS Server Docker Image"
3. Clique em "Run workflow"
4. Selecione a branch (ex: `main` para releases, `develop` para testes)
5. Clique em "Run workflow" novamente
6. Aguarde conclusão (~5-10 minutos)
7. Verifique a imagem publicada no GHCR

### 4.3 Trigger via GitHub CLI

```bash
# Trigger workflow do EMS (branch main)
gh workflow run docker-ems-server.yml --ref main

# Trigger workflow do SMS (branch develop)
gh workflow run docker-sms-server.yml --ref develop

# Verificar status
gh run list --workflow=docker-ems-server.yml
gh run list --workflow=docker-sms-server.yml

# Ver logs de uma execução específica
gh run view <RUN_ID> --log
```

### 4.4 Versionamento

**Como Funciona:**
- Cada servidor lê a versão do próprio `pubspec.yaml`
- **EMS:** `servers/ems/server_v1/pubspec.yaml`
- **SMS:** `servers/sms/server_v1/pubspec.yaml`
- Versionamento independente (EMS v1.3.0, SMS v1.1.5)

**Tags Geradas:**
- `latest` → Última versão estável (branch main)
- `{version}` → Versão específica (ex: `1.1.0`)
- `v{major.minor}` → Major.minor (ex: `v1.1`)
- `sha-{commit}` → Commit específico (rastreabilidade)

**Incrementar Versão:**
1. Edite `servers/{ems|sms}/server_v1/pubspec.yaml`
2. Atualize o campo `version: X.Y.Z`
3. Commit: `git commit -m "chore: bump {ems|sms} version to X.Y.Z"`
4. Trigger workflow manual

### 4.5 Push Manual vs Workflow

| Critério | Push Manual | Workflow Manual |
|----------|-------------|-----------------|
| **Velocidade** | Rápido (2-5 min) | Médio (5-10 min) |
| **Custo** | $0 | ~$0.03-0.05 |
| **Rastreabilidade** | Básica | Completa (labels OCI) |
| **Reproduzibilidade** | Depende do ambiente local | Garantida (GitHub Actions) |
| **Quando usar** | Desenvolvimento, testes rápidos | Releases oficiais, produção |

---

## 5. Deploy em VPS

### 5.1 Configuração Inicial na VPS

**Instalar Docker:**
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

**Criar Rede Docker:**
```bash
docker network create ems_system_net
```

**Configurar Autenticação GHCR:**
```bash
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX
echo "$GITHUB_TOKEN" | docker login ghcr.io -u edumigsoft --password-stdin
```

**Clonar Repositório (ou copiar arquivos necessários):**
```bash
# Opção 1: Clonar repo completo
git clone https://github.com/edumigsoft/ems_system.git
cd ems_system

# Opção 2: Copiar apenas arquivos de deploy
scp -r servers/ems/container user@vps:/caminho/deploy/ems
scp -r servers/sms/container user@vps:/caminho/deploy/sms
```

### 5.2 Configurar Variáveis de Ambiente

**EMS:**
```bash
cd servers/ems/container
cp .env.example .env
nano .env  # Configurar credenciais
```

**SMS:**
```bash
cd servers/sms/container
cp .env.example .env
nano .env  # Configurar credenciais
```

### 5.3 Deploy com Scripts Automatizados

**EMS:**
```bash
cd servers/ems/container
chmod +x deploy-prod.sh
./deploy-prod.sh
```

**SMS:**
```bash
cd servers/sms/container
chmod +x deploy-prod.sh
./deploy-prod.sh
```

**O que o script faz:**
1. Solicita seleção de versão (latest, específica, ou custom)
2. Faz login no GHCR
3. Faz pull da imagem
4. Para containers antigos
5. Inicia novo container
6. Exibe logs e status

### 5.4 Deploy Manual (sem script)

**EMS:**
```bash
cd servers/ems/container

# Pull da imagem
docker pull ghcr.io/edumigsoft/ems-server:latest

# Deploy
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d

# Verificar
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs -f
```

**SMS:**
```bash
cd servers/sms/container

# Pull da imagem
docker pull ghcr.io/edumigsoft/sms-server:latest

# Deploy
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d

# Verificar
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs -f
```

### 5.5 Verificação de Saúde

```bash
# Verificar status dos containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Healthcheck via curl
curl http://localhost:8181/health  # EMS
curl http://localhost:8080/health  # SMS

# Logs em tempo real
docker logs -f ems_server_prod
docker logs -f sms_server_prod
```

---

## 6. Rollback e Troubleshooting

### 6.1 Rollback com Script

**EMS:**
```bash
cd servers/ems/container
chmod +x rollback.sh
./rollback.sh
```

**SMS:**
```bash
cd servers/sms/container
chmod +x rollback.sh
./rollback.sh
```

**O que o script faz:**
1. Lista versões disponíveis no GHCR
2. Solicita seleção da versão para rollback
3. Faz pull da imagem
4. Para container atual
5. Inicia container com versão anterior
6. Exibe logs

### 6.2 Rollback Manual

```bash
# EMS - Rollback para versão específica
cd servers/ems/container
docker-compose -f docker-compose.prod.yml down
docker pull ghcr.io/edumigsoft/ems-server:1.0.0
# Editar docker-compose.prod.yml para usar tag 1.0.0
docker-compose -f docker-compose.prod.yml up -d

# SMS - Rollback para versão específica
cd servers/sms/container
docker-compose -f docker-compose.prod.yml down
docker pull ghcr.io/edumigsoft/sms-server:1.0.0
# Editar docker-compose.prod.yml para usar tag 1.0.0
docker-compose -f docker-compose.prod.yml up -d
```

### 6.3 Problemas Comuns

#### Problema: Autenticação GHCR falha

**Sintomas:**
```
Error response from daemon: unauthorized: authentication required
```

**Solução:**
```bash
# Verificar se token está configurado
echo $GITHUB_TOKEN

# Fazer login novamente
echo "$GITHUB_TOKEN" | docker login ghcr.io -u edumigsoft --password-stdin

# Verificar permissões do token
# Token precisa de scopes: read:packages, write:packages
```

#### Problema: Container não inicia

**Sintomas:**
```
Container exits with code 1
```

**Solução:**
```bash
# Verificar logs
docker logs ems_server_prod
docker logs sms_server_prod

# Verificar variáveis de ambiente
docker exec ems_server_prod env | grep DB_

# Verificar conectividade com PostgreSQL
docker exec ems_server_prod ping postgres

# Verificar se rede existe
docker network ls | grep ems_system_net
```

#### Problema: Healthcheck failing

**Sintomas:**
```
Status: unhealthy
```

**Solução:**
```bash
# Testar endpoint manualmente
docker exec ems_server_prod wget -O- http://localhost:8181/health

# Verificar se porta está exposta
docker port ems_server_prod

# Verificar logs de erro
docker logs ems_server_prod --tail 100
```

#### Problema: Build local falha

**Sintomas:**
```
ERROR: failed to solve: process "/bin/sh -c dart pub get" did not complete successfully
```

**Solução:**
```bash
# Verificar se todos os pacotes estão no Dockerfile
# Comparar dependencies do pubspec.yaml com COPY no Dockerfile

# Limpar cache do Docker
docker builder prune -a

# Rebuild sem cache
docker build --no-cache -f servers/ems/container/Dockerfile -t ems-server:test .
```

#### Problema: Workflow GitHub Actions falha

**Sintomas:**
```
Error: buildx failed with: ERROR: failed to solve...
```

**Solução:**
1. Verificar logs completos no GitHub Actions
2. Verificar se paths do workflow estão corretos
3. Verificar se Dockerfile está correto
4. Testar build localmente primeiro
5. Verificar permissões do repositório

---

## 7. FAQs

### 7.1 Qual a diferença entre build local e workflow?

- **Build local:** Rápido, gratuito, para desenvolvimento e testes. Executado na sua máquina.
- **Workflow:** Build limpo e reproduzível, para releases oficiais. Executado no GitHub Actions.

### 7.2 Quando usar `latest` vs versão específica?

- **`latest`:** Desenvolvimento, testes, ambientes não-críticos. Sempre aponta para a versão mais recente.
- **Versão específica (ex: `1.2.0`):** Produção, ambientes críticos. Garante versão exata.
- **`v{major.minor}` (ex: `v1.2`):** Facilita upgrades de patch (1.2.0 → 1.2.1) sem mudar tag.

### 7.3 Como atualizar apenas um servidor (EMS ou SMS)?

Cada servidor é independente:
```bash
# Atualizar apenas EMS
cd servers/ems/container
./deploy-prod.sh  # Selecione nova versão

# SMS continua rodando versão antiga
```

### 7.4 Como rodar EMS e SMS simultaneamente?

Ambos podem rodar juntos pois usam portas diferentes:
- **EMS:** Porta 8181
- **SMS:** Porta 8080
- **Rede:** Ambos usam `ems_system_net`

```bash
# Iniciar ambos
cd servers/ems/container && docker-compose -f docker-compose.prod.yml up -d
cd servers/sms/container && docker-compose -f docker-compose.prod.yml up -d

# Verificar
curl http://localhost:8181/health  # EMS
curl http://localhost:8080/health  # SMS
```

### 7.5 Como rotacionar o GITHUB_TOKEN?

1. Criar novo token: https://github.com/settings/tokens
2. Atualizar variável de ambiente:
   ```bash
   export GITHUB_TOKEN=ghp_NOVO_TOKEN
   echo 'export GITHUB_TOKEN=ghp_NOVO_TOKEN' >> ~/.bashrc
   ```
3. Fazer novo login:
   ```bash
   echo "$GITHUB_TOKEN" | docker login ghcr.io -u edumigsoft --password-stdin
   ```
4. Revogar token antigo no GitHub

### 7.6 Como ver histórico de versões disponíveis?

```bash
# Via GitHub CLI
gh api /orgs/edumigsoft/packages/container/ems-server/versions | jq '.[].metadata.container.tags'
gh api /orgs/edumigsoft/packages/container/sms-server/versions | jq '.[].metadata.container.tags'

# Via Web
# https://github.com/edumigsoft/ems_system/pkgs/container/ems-server
# https://github.com/edumigsoft/ems_system/pkgs/container/sms-server
```

### 7.7 O que fazer se o banco de dados PostgreSQL não está rodando?

```bash
# Verificar se container existe
docker ps -a | grep postgres

# Iniciar PostgreSQL
cd servers/containers/postgres
docker-compose up -d

# Verificar logs
docker-compose logs -f

# Verificar conectividade
docker exec postgres_db psql -U postgres -c "SELECT version();"
```

### 7.8 Como limpar imagens antigas do Docker?

```bash
# Listar imagens
docker images | grep -E "ems-server|sms-server"

# Remover imagens não usadas
docker image prune -a --filter "label=org.opencontainers.image.source=https://github.com/edumigsoft/ems_system"

# Remover versões específicas
docker rmi ghcr.io/edumigsoft/ems-server:1.0.0
docker rmi ghcr.io/edumigsoft/sms-server:1.0.0
```

### 7.9 Como monitorar recursos dos containers?

```bash
# Uso de recursos em tempo real
docker stats ems_server_prod sms_server_prod

# Informações detalhadas
docker inspect ems_server_prod
docker inspect sms_server_prod
```

### 7.10 Como fazer backup antes de deploy?

```bash
# Backup do banco de dados
cd servers/containers/postgres
docker-compose exec postgres pg_dump -U postgres -d ems_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup de imagem atual (snapshot)
docker commit ems_server_prod ems-server:backup-$(date +%Y%m%d)
docker commit sms_server_prod sms-server:backup-$(date +%Y%m%d)
```

---

## Boas Práticas

1. **Sempre teste localmente antes de fazer push para GHCR**
2. **Use workflows para releases oficiais em produção**
3. **Mantenha o GITHUB_TOKEN seguro e rotacione regularmente**
4. **Faça backup do banco de dados antes de deploys importantes**
5. **Use versões específicas em produção, não `latest`**
6. **Monitore logs após deploy para detectar problemas**
7. **Documente mudanças no CHANGELOG.md**
8. **Incremente a versão no pubspec.yaml antes de releases**

---

## Referências

- **Infraestrutura Docker:** `servers/INFRASTRUCTURE.md`
- **Plano de Integração GHCR:** `cached-singing-harbor.md`
- **Deploy EMS:** `servers/ems/container/DEPLOY.md`
- **Deploy SMS:** `servers/sms/container/DEPLOY.md`
