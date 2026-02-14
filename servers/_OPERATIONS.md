# Guia de Operações: Servidores EMS e SMS
## Build, Deploy e Gerenciamento de Imagens Docker

Este guia descreve **em ordem de execução** como trabalhar com os servidores EMS e SMS, desde o desenvolvimento local até o deploy em produção.

---

## 📋 Índice

1. [Build Local (Desenvolvimento)](#1-build-local-desenvolvimento)
2. [Push Manual para GHCR](#2-push-manual-para-ghcr)
3. [Workflows Manuais (Releases Oficiais)](#3-workflows-manuais-releases-oficiais)
4. [Deploy em VPS](#4-deploy-em-vps)
5. [Rollback](#5-rollback)
6. [Troubleshooting](#6-troubleshooting)
7. [FAQs](#7-faqs)

---

## 1. Build Local (Desenvolvimento)

### 🎯 Quando Usar
- ✅ Durante desenvolvimento ativo
- ✅ Para testar mudanças rapidamente
- ✅ Antes de fazer commit
- ✅ **90% do tempo** - Custo: **$0**

### 📝 Passo a Passo

#### Opção A: Build com Script (Recomendado)

```bash
# Build do servidor EMS
./scripts/build-local.sh ems

# Build do servidor SMS
./scripts/build-local.sh sms
```

O script automaticamente:
- Lê a versão do `pubspec.yaml`
- Faz build da imagem
- Cria tags apropriadas

#### Opção B: Build Manual

```bash
# EMS
cd servers/ems/container
docker build -f Dockerfile -t ems-server:local ../../..

# SMS
cd servers/sms/container
docker build -f Dockerfile -t sms-server:local ../../..
```

### 🧪 Testar Localmente

```bash
# EMS
cd servers/ems/container
docker-compose up -d
docker-compose logs -f

# SMS
cd servers/sms/container
docker-compose up -d
docker-compose logs -f

# Verificar saúde
curl http://localhost:8181/health  # EMS
curl http://localhost:8080/health  # SMS
```

### 🔄 Quando Fazer Push para GHCR?

**Faça push manual quando:**
- ✅ Versão estável para testar em staging
- ✅ Compartilhar com equipe
- ✅ Preparar para deploy em VPS

**NÃO faça push para:**
- ❌ Builds experimentais
- ❌ Testes locais
- ❌ WIP (Work in Progress)

---

## 2. Push Manual para GHCR

### 🎯 Quando Usar
- ✅ Versão estável pronta para staging/produção
- ✅ Compartilhar imagem com equipe
- ✅ Deploy em VPS sem usar GitHub Actions
- ⚠️ **Ocasional** - Custo: **$0**

### 🔐 Configuração Inicial (Uma Vez)

#### Criar Personal Access Token (PAT)

1. Acesse: https://github.com/settings/tokens
2. Clique em "Generate new token" → "Generate new token (classic)"
3. Configure:
   - **Note**: "GHCR Push Access"
   - **Expiration**: 90 dias
   - **Scopes**: 
     - ✅ `write:packages`
     - ✅ `read:packages`
     - ✅ `delete:packages` (opcional)
4. Copie o token (começa com `ghp_`)

#### Configurar Token Localmente

```bash
# Exportar token (temporário - sessão atual)
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX

# OU persistir no .bashrc/.zshrc (permanente)
echo 'export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX' >> ~/.bashrc
source ~/.bashrc
```

### 📝 Passo a Passo

#### Opção A: Push com Script (Recomendado)

```bash
# Garantir que token está configurado
echo $GITHUB_TOKEN  # Deve mostrar seu token

# Push do servidor EMS
./scripts/push-to-ghcr.sh ems

# Push do servidor SMS
./scripts/push-to-ghcr.sh sms
```

O script automaticamente:
- Faz login no GHCR
- Lê versão do `pubspec.yaml`
- Faz build da imagem
- Cria tags (versão + latest)
- Faz push para GHCR

#### Opção B: Push Manual

```bash
# 1. Login no GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u SEU_USUARIO_GITHUB --password-stdin

# 2. Build e tag (EMS exemplo)
cd servers/ems/container
VERSION=$(grep '^version:' ../server_v1/pubspec.yaml | sed 's/version: *//' | tr -d ' ')
docker build -f Dockerfile -t ghcr.io/edumigsoft/ems-server:$VERSION ../../..
docker tag ghcr.io/edumigsoft/ems-server:$VERSION ghcr.io/edumigsoft/ems-server:latest

# 3. Push
docker push ghcr.io/edumigsoft/ems-server:$VERSION
docker push ghcr.io/edumigsoft/ems-server:latest
```

### ✅ Verificar Imagens Publicadas

```bash
# Via Docker CLI
docker pull ghcr.io/edumigsoft/ems-server:latest
docker images | grep ems-server

# Via GitHub Web
# Acesse: https://github.com/edumigsoft/ems_system/pkgs/container/ems-server
```

---

## 3. Workflows Manuais (Releases Oficiais)

### 🎯 Quando Usar
- ✅ Releases oficiais (v1.2.0, v1.3.0, etc.)
- ✅ Garantir build limpo e reproduzível
- ✅ Quando não tem ambiente de build local disponível
- ⚠️ **Raro (10% do tempo)** - Custo: **~$0.03-0.05 por build** (ou $0 se repo público)

### 📝 Passo a Passo

#### Opção A: Via GitHub Web UI

1. Acesse: https://github.com/edumigsoft/ems_system/actions
2. Selecione o workflow:
   - "Build and Publish EMS Server Docker Image" (para EMS)
   - "Build and Publish SMS Server Docker Image" (para SMS)
3. Clique em "Run workflow"
4. Selecione branch (geralmente `main`)
5. Clique em "Run workflow" (confirmar)
6. Aguarde conclusão (~5-8 minutos)

#### Opção B: Via GitHub CLI

```bash
# Instalar GitHub CLI (se necessário)
# https://cli.github.com/

# Autenticar
gh auth login

# Trigger workflow EMS
gh workflow run docker-ems-server.yml

# Trigger workflow SMS
gh workflow run docker-sms-server.yml

# Monitorar progresso
gh run list --workflow=docker-ems-server.yml
gh run watch
```

### ✅ Verificar Build

```bash
# Verificar status
gh run list --workflow=docker-ems-server.yml --limit 1

# Ver logs
gh run view --log

# Verificar imagem publicada
docker pull ghcr.io/edumigsoft/ems-server:latest
```

---

## 4. Deploy em VPS

### 🎯 Pré-requisitos

- ✅ VPS com Docker instalado
- ✅ Rede `ems_system_net` criada
- ✅ Arquivo `.env` configurado
- ✅ Token GHCR configurado (para pull de imagens privadas)

### 📝 Configuração Inicial (Uma Vez)

```bash
# Na VPS

# 1. Criar rede Docker
docker network create ems_system_net

# 2. Configurar token GHCR
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX
echo 'export GITHUB_TOKEN=ghp_XXX' >> ~/.bashrc

# 3. Clonar repositório (ou copiar arquivos necessários)
git clone https://github.com/edumigsoft/ems_system.git
cd ems_system

# 4. Configurar .env
cd servers/ems/container
cp .env.example .env
nano .env  # Ajustar credenciais
```

### 📝 Deploy

#### Opção A: Script Automatizado (Recomendado)

```bash
# Deploy EMS
cd servers/ems/container
chmod +x deploy-prod.sh
./deploy-prod.sh

# Deploy SMS
cd servers/sms/container
chmod +x deploy-prod.sh
./deploy-prod.sh
```

O script irá:
1. Solicitar versão (latest ou específica)
2. Fazer login no GHCR
3. Pull da imagem
4. Parar container antigo
5. Iniciar novo container
6. Exibir logs e status

#### Opção B: Manual

```bash
# EMS
cd servers/ems/container

# Login GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u SEU_USUARIO --password-stdin

# Pull imagem
docker pull ghcr.io/edumigsoft/ems-server:latest

# Deploy
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d

# Verificar
docker-compose -f docker-compose.prod.yml logs -f
```

### ✅ Verificar Deploy

```bash
# Status dos containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Healthcheck
curl http://localhost:8181/health  # EMS
curl http://localhost:8080/health  # SMS

# Logs
docker logs ems_server_prod -f
docker logs sms_server_prod -f
```

---

## 5. Rollback

### 🎯 Quando Usar
- ⚠️ Bug crítico em produção
- ⚠️ Nova versão instável
- ⚠️ Necessidade de voltar para versão anterior

### 📝 Passo a Passo

#### Opção A: Script Automatizado

```bash
# Rollback EMS
cd servers/ems/container
chmod +x rollback.sh
./rollback.sh

# Rollback SMS
cd servers/sms/container
chmod +x rollback.sh
./rollback.sh
```

O script irá:
1. Listar versões disponíveis no GHCR
2. Solicitar versão para rollback
3. Pull da versão antiga
4. Restart do container

#### Opção B: Manual

```bash
# 1. Listar versões disponíveis
# Acesse: https://github.com/edumigsoft/ems_system/pkgs/container/ems-server

# 2. Pull versão antiga
docker pull ghcr.io/edumigsoft/ems-server:1.1.0

# 3. Atualizar docker-compose.prod.yml
nano docker-compose.prod.yml
# Mudar: image: ghcr.io/edumigsoft/ems-server:latest
# Para:  image: ghcr.io/edumigsoft/ems-server:1.1.0

# 4. Restart
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

---

## 6. Troubleshooting

### ❌ Problema: "Error response from daemon: pull access denied"

**Causa:** Token GHCR não configurado ou expirado

**Solução:**
```bash
# Verificar token
echo $GITHUB_TOKEN

# Reconfigurar
export GITHUB_TOKEN=ghp_NOVO_TOKEN
echo $GITHUB_TOKEN | docker login ghcr.io -u SEU_USUARIO --password-stdin
```

### ❌ Problema: "network ems_system_net not found"

**Causa:** Rede Docker não criada

**Solução:**
```bash
docker network create ems_system_net
```

### ❌ Problema: Build local falha com "packages not found"

**Causa:** Dockerfile desatualizado ou pacotes faltando

**Solução:**
```bash
# Verificar se todos os pacotes estão no Dockerfile
# Comparar com pubspec.yaml do servidor
```

### ❌ Problema: Container não inicia (exit code 1)

**Causa:** Variáveis de ambiente faltando ou incorretas

**Solução:**
```bash
# Verificar .env
cat .env

# Ver logs do container
docker logs ems_server_prod

# Validar variáveis
docker exec ems_server_prod env | grep DB_
```

---

## 7. FAQs

### ❓ Quando devo usar build local vs workflow manual?

**Build Local:**
- Durante desenvolvimento
- Testes rápidos
- Iteração frequente
- **Custo: $0**

**Workflow Manual:**
- Releases oficiais
- Build limpo garantido
- Sem ambiente local disponível
- **Custo: ~$0.03-0.05 (ou $0 se repo público)**

### ❓ Preciso fazer push para GHCR toda vez que faço build local?

**Não!** Apenas faça push quando:
- Versão estável para staging/produção
- Compartilhar com equipe
- Preparar para deploy

### ❓ Como sei qual versão está rodando em produção?

```bash
# Ver tag da imagem
docker inspect ems_server_prod | grep Image

# Ver logs de inicialização (geralmente mostra versão)
docker logs ems_server_prod | head -20
```

### ❓ Posso rodar EMS e SMS simultaneamente?

**Sim!** Eles usam portas diferentes:
- EMS: 8181
- SMS: 8080

### ❓ Como atualizar apenas um servidor (EMS ou SMS)?

Cada servidor é independente:
```bash
# Atualizar apenas EMS
cd servers/ems/container
./deploy-prod.sh

# SMS continua na versão antiga
```

### ❓ O que fazer se o workflow manual falhar?

1. Ver logs do workflow no GitHub Actions
2. Verificar se Dockerfile está correto
3. Verificar se todos os pacotes existem
4. Tentar build local para debug
5. Se necessário, fazer push manual

---

## 📊 Resumo de Custos

| Operação | Frequência | Custo |
|----------|-----------|-------|
| Build Local | Diária | $0 |
| Push Manual | Semanal | $0 |
| Workflow Manual | Mensal (releases) | $0 (público) ou ~$0.03-0.05 (privado) |
| Deploy VPS | Conforme necessário | $0 (apenas custo da VPS) |

**Custo Total Estimado:** **$0 - $2/mês** (se repo privado com ~40 releases/mês)

---

## 🔗 Links Úteis

- **GitHub Packages (EMS)**: https://github.com/edumigsoft/ems_system/pkgs/container/ems-server
- **GitHub Packages (SMS)**: https://github.com/edumigsoft/ems_system/pkgs/container/sms-server
- **GitHub Actions**: https://github.com/edumigsoft/ems_system/actions
- **Criar PAT**: https://github.com/settings/tokens
- **GitHub CLI**: https://cli.github.com/

---

## 📝 Ordem de Execução Típica

### Desenvolvimento
```
1. Fazer mudanças no código
2. Build local (./scripts/build-local.sh ems)
3. Testar localmente (docker-compose up)
4. Commit e push para Git
5. (Opcional) Push manual para GHCR se versão estável
```

### Release Oficial
```
1. Incrementar versão no pubspec.yaml
2. Commit e push
3. Trigger workflow manual (GitHub UI ou CLI)
4. Aguardar build (~5-8 min)
5. Verificar imagem no GHCR
6. Deploy em VPS
```

### Deploy em Produção
```
1. SSH na VPS
2. cd servers/ems/container (ou sms)
3. ./deploy-prod.sh
4. Selecionar versão
5. Aguardar deploy
6. Verificar healthcheck
```
