# Arquitetura de Infraestrutura (Docker, Local e VPS)

Este documento centraliza as definições de infraestrutura do sistema EMS/SMS, abordando desde o ambiente de desenvolvimento local até o deploy em produção (VPS).

> **Status:** 🟢 **A maior parte da infraestrutura descrita já está implementada e ativa no código.**
> A exceção é a **Estrutura de Pastas na VPS (Seção 2)**, que possui um plano de migração listado como pendente para as instâncias de produção.

---

## 1. 💻 [ATIVO] Ambiente de Desenvolvimento Local com Paridade de Produção

O ambiente local é um espelho fiel da produção (utilizando a mesma stack Traefik + Docker + PostgreSQL), alterando apenas os domínios para `.local` e o certificado TLS via `mkcert`.
A infraestrutura base do Traefik localmente já se encontra em `servers/infra/docker-compose.dev.yml`. 

### Como a Infra Local Funciona no Código

**Arquivos de Setup:**
- `servers/infra/docker-compose.dev.yml` configura o Traefik de Dev (sem ACME Let's Encrypt, com File Provider do `mkcert`) lendo de `servers/infra/certs/tls.yml`.
- `servers/ems/container/docker-compose.dev.yml` e a variante do `sms` expõem os labels corretos do Traefik para roteamento em `api.ems.local` e gerenciam os volumes `UPLOADS_HOST_PATH` referenciando aos mock locations de desenvolvimento `../../.dev-data/...`.

---

## 2. ☁️ [PENDENTE] Nova Estrutura de Pastas na VPS (Traefik com Let's Encrypt)

Na VPS de produção, o proxy Traefik utiliza exclusivamente o **Let's Encrypt (ACME)** para gerenciar e rotacionar os certificados HTTPS automaticamente. O `mkcert` é usado apenas para o ambiente de desenvolvimento local (`.local`).

Em setups anteriores, a VPS clonou e armazenou o repositório por inteiro, e isso acaba misturando configurações versionadas com dados estáticos persistentes (Uploads, TLS, Logs).

### O Entendimento de Caminhos Relativos Atuais
Atualmente o arquivo `servers/ems/container/docker-compose.prod.yml` referencia arquivos utilizando caminhos relativos na criação de volumes docker. Por exemplo:
- `../../../uploads` (Ele volta 3 pastas a partir de `servers/ems/container` para chegar na raiz onde supostamente a pasta `uploads` ficaria ao lado de `apps` e `servers`).
- No Traefik, os certificados TLS são injetados do `./letsencrypt` (A mesma pasta do arquivo `docker-compose.yml` da infraestrutura). 

Isso é frágil caso o repositório seja transferido, escalado ou ocorra qualquer erro de movimentação. O objetivo futuro é segmentar a VPS estabelecendo um isolamento estrito por caminho absoluto (`/opt/ems_system/...`):

### 🚨 Como Implementar o Plano de Migração na VPS

Esta migração causará um breve período de inatividade no serviço (aprox. 10-15 min) e exigirá validação assíncrona:

**Passo 1:** **Criar Nova Hierarquia Definitiva (Apenas na VPS)**
- [ ] Estabelecer a base rigorosa em `/opt/ems_system/` com diretórios de vida longa apartados: `/data` (Uploads, Certificados do Traefik Let's Encrypt), `/logs` e a nova pasta base exclusiva para containers (`/servers`).

**Passo 2:** **Migração via Terminal (Downtime)**
- [ ] Realizar backup crítico pré-migração da pasta `letsencrypt` conectada ao Traefik de Produção e da pasta raiz local de `uploads` na VPS.
- [ ] Excluir preventivamente as stacks antigas do Traefik, EMS e SMS na VPS (`docker compose down`). O PostgreSQL em volume *Named* pode continuar intacto. 
- [ ] Mover em definitivo o estado e os relatórios originais para a nova área segura (`/opt/ems_system/data/...`).

**Passo 3:** **Alterações de Arquivos no Código Fonte Local**
- [ ] Editar `servers/infra/docker-compose.yml` (repositório) para modificar o volume associado ao container traefik acme (`./letsencrypt`) para um path incondicional: (`/opt/ems_system/data/letsencrypt`).
- [ ] Retificar o `UPLOADS_HOST_PATH` e `LOGS_HOST_PATH` em `servers/ems/container/.env_example` e variantes `.env` de runtime na VPS.

**Passo 4:** **Validação e Limpeza Final**
- [ ] Transferir apenas os dockers restritivos da VPS utilizando SSH/Rsync (isento de Dart) e re-acordá-los (`update.sh`). Validar emissão do ACME Traefik. Por fim, limpe a estrutura originária se sucesso certificado.

---

## 3. 🔐 [ATIVO] Setup de GITHUB_TOKEN na VPS

Para baixar as imagens do contêiner armazenadas no GitHub Container Registry (GHCR), os utilitários de servidor validam automaticamente o acesso de pull. Isso já é funcional e mantido nativamente via `update.sh`.

Em vez de replicar o secret global `GITHUB_TOKEN` comumente no `docker-compose.yml`, sua armazenagem opera no padrão protegido da chave global exclusiva do ambiente host Linux VPS:

```bash
/root/apps/.secrets/github
```
Esse formato, com configuração local restritiva (`chmod 600`), garante que a integridade se mantenha exclusivamente nos parâmetros do container registry (`read:packages`).

### Substituição e Rotação

A VPS não pedirá credencial desde que o token mantido em `.secrets` não atinja seu prazo de validade (*Expiration*).

Se o token expirar ou necessitar de rotação rotineira de segurança:
1. Revogue e reemita um novo com limite respectivo (no GitHub, vá em Settings > Developer Settings > Classic Tokens).
2. Acesse a VPS como usuário root (ou super-admin ssh) e utilize qualquer editor de terminal para sobscrever exatamente apenas este valor, regravando como:
   `export GITHUB_TOKEN=ghp_ABC123...`
3. Execute o script nativo `# source /root/apps/.secrets/github && echo $GITHUB_TOKEN | docker login ghcr.io -u edumigsoft --password-stdin` para reassegurar.
