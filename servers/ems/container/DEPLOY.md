# EMS Server - Guia de Deploy em Produção

Este guia documenta o processo de deploy do servidor EMS em produção usando imagens do GitHub Container Registry (GHCR).

## Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Configuração Inicial](#configuração-inicial)
3. [Deploy](#deploy)
4. [Atualização](#atualização)
5. [Rollback](#rollback)
6. [Monitoramento](#monitoramento)
7. [Troubleshooting](#troubleshooting)

---

## Pré-requisitos

### 1. Docker Instalado na VPS

```bash
# Instalar Docker
curl -fsSL https://get.docker.com | sh

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Relogar para aplicar permissões
exit
# Logar novamente
```

### 2. GitHub Personal Access Token (PAT)

Para fazer pull de imagens privadas do GHCR:

1. Acesse: https://github.com/settings/tokens
2. Clique em "Generate new token (classic)"
3. Configure:
   - **Nome:** "VPS Production Access"
   - **Scopes:** `read:packages` (mínimo necessário)
   - **Validade:** 90 dias (rotacione regularmente)
4. Copie o token gerado (ex: `ghp_XXXXXXXXXXXXXXXXXXXX`)

**Importante:** Guarde o token em local seguro. Você não poderá vê-lo novamente.

### 3. Rede Docker

```bash
# Criar rede compartilhada (se ainda não existir)
docker network create ems_system_net
```

---

## Configuração Inicial

### 1. Copiar Arquivos de Deploy

**Opção A: Clonar repositório completo**
```bash
git clone https://github.com/edumigsoft/ems_system.git
cd ems_system/servers/ems/container
```

**Opção B: Copiar apenas arquivos necessários**
```bash
# Na sua máquina local
scp -r servers/ems/container user@vps-ip:/caminho/deploy/ems/

# Na VPS
cd /caminho/deploy/ems/container
```

### 2. Configurar Variáveis de Ambiente

```bash
# Copiar exemplo
cp .env.example .env

# Editar configurações
nano .env
```

**Variáveis obrigatórias no .env:**
```bash
# Porta do servidor
SERVER_PORT=8181

# Banco de dados PostgreSQL
DB_HOST=postgres
DB_PORT=5432
DB_NAME=ems_db
DB_USER=postgres
DB_PASSWORD=senha_segura

# JWT
JWT_SECRET=chave_secreta_segura_aqui

# Outras configurações específicas do EMS
```

### 3. Autenticação GHCR

```bash
# Exportar token
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX

# Login no GHCR
echo "$GITHUB_TOKEN" | docker login ghcr.io -u edumigsoft --password-stdin

# Opcional: Tornar token persistente
echo 'export GITHUB_TOKEN=ghp_XXX' >> ~/.bashrc
source ~/.bashrc
```

---

## Deploy

### Deploy Automatizado (Recomendado)

```bash
cd /caminho/deploy/ems/container

# Tornar script executável (primeira vez)
chmod +x deploy-prod.sh

# Executar deploy
./deploy-prod.sh
```

O script irá:
1. Solicitar seleção de versão (latest, específica ou custom)
2. Fazer login no GHCR
3. Fazer pull da imagem
4. Parar containers antigos
5. Iniciar novo container
6. Exibir logs e status

### Deploy Manual

```bash
cd /caminho/deploy/ems/container

# 1. Pull da imagem
docker pull ghcr.io/edumigsoft/ems-server:latest

# 2. Parar container antigo
docker-compose -f docker-compose.prod.yml down

# 3. Iniciar novo container
docker-compose -f docker-compose.prod.yml up -d

# 4. Verificar logs
docker-compose -f docker-compose.prod.yml logs -f
```

### Usando Versão Específica

```bash
# Editar docker-compose.prod.yml
nano docker-compose.prod.yml

# Alterar a linha da imagem:
# image: ghcr.io/edumigsoft/ems-server:1.2.0

# Deploy
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

---

## Atualização

### Atualizar para Última Versão

```bash
cd /caminho/deploy/ems/container

# Método 1: Script automatizado
./deploy-prod.sh

# Método 2: Manual
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

### Verificar Nova Versão Antes de Atualizar

```bash
# Via GitHub CLI
gh api /orgs/edumigsoft/packages/container/ems-server/versions | jq '.[0].metadata.container.tags'

# Via Web
# https://github.com/edumigsoft/ems_system/pkgs/container/ems-server
```

---

## Rollback

### Rollback Automatizado

```bash
cd /caminho/deploy/ems/container

# Tornar script executável (primeira vez)
chmod +x rollback.sh

# Executar rollback
./rollback.sh
```

### Rollback Manual

```bash
# 1. Parar container atual
docker-compose -f docker-compose.prod.yml down

# 2. Pull da versão anterior
docker pull ghcr.io/edumigsoft/ems-server:1.0.0

# 3. Editar docker-compose.prod.yml
nano docker-compose.prod.yml
# Alterar: image: ghcr.io/edumigsoft/ems-server:1.0.0

# 4. Iniciar com versão anterior
docker-compose -f docker-compose.prod.yml up -d
```

---

## Monitoramento

### Verificar Status

```bash
# Status do container
docker ps | grep ems_server_prod

# Status completo (com healthcheck)
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Status via docker-compose
docker-compose -f docker-compose.prod.yml ps
```

### Logs

```bash
# Logs em tempo real
docker-compose -f docker-compose.prod.yml logs -f

# Últimas 100 linhas
docker logs ems_server_prod --tail 100

# Logs com timestamp
docker logs ems_server_prod --timestamps
```

### Healthcheck

```bash
# Via curl
curl http://localhost:8181/health

# Via wget
wget -qO- http://localhost:8181/health

# Healthcheck interno do Docker
docker inspect ems_server_prod | jq '.[0].State.Health'
```

### Recursos

```bash
# Uso de CPU e memória em tempo real
docker stats ems_server_prod

# Informações detalhadas
docker inspect ems_server_prod
```

---

## Troubleshooting

### Container Não Inicia

**Problema:** Container para imediatamente após iniciar.

**Diagnóstico:**
```bash
# Ver logs
docker logs ems_server_prod

# Ver últimos logs
docker logs ems_server_prod --tail 50
```

**Soluções Comuns:**
1. **Erro de conexão com banco de dados:**
   ```bash
   # Verificar se PostgreSQL está rodando
   docker ps | grep postgres

   # Verificar conectividade
   docker exec ems_server_prod ping postgres

   # Verificar variáveis de ambiente
   docker exec ems_server_prod env | grep DB_
   ```

2. **Porta já em uso:**
   ```bash
   # Verificar o que está usando a porta 8181
   sudo lsof -i :8181

   # Parar serviço conflitante ou alterar porta no .env
   ```

### Healthcheck Failing

**Problema:** Status do container mostra "unhealthy".

**Diagnóstico:**
```bash
# Testar endpoint manualmente
docker exec ems_server_prod wget -O- http://localhost:8181/health

# Ver logs de healthcheck
docker inspect ems_server_prod | jq '.[0].State.Health.Log'
```

**Soluções:**
1. Servidor pode estar demorando para iniciar (aguardar `start_period` de 40s)
2. Verificar se porta 8181 está correta no .env
3. Verificar logs para erros de inicialização

### Autenticação GHCR Falha

**Problema:** `Error response from daemon: unauthorized`

**Soluções:**
```bash
# 1. Verificar se token está configurado
echo $GITHUB_TOKEN

# 2. Verificar permissões do token
# Token precisa de scope: read:packages

# 3. Fazer login novamente
echo "$GITHUB_TOKEN" | docker login ghcr.io -u edumigsoft --password-stdin

# 4. Se token expirou, gerar novo em:
# https://github.com/settings/tokens
```

### Rede Docker Não Existe

**Problema:** `network ems_system_net declared as external, but could not be found`

**Solução:**
```bash
# Criar rede
docker network create ems_system_net

# Verificar
docker network ls | grep ems_system_net
```

### Container Rodando Mas Não Responde

**Diagnóstico:**
```bash
# 1. Verificar se container está rodando
docker ps | grep ems_server_prod

# 2. Verificar logs
docker logs ems_server_prod --tail 50

# 3. Verificar se porta está exposta
docker port ems_server_prod

# 4. Testar internamente
docker exec ems_server_prod wget -qO- http://localhost:8181/health
```

**Soluções:**
1. Verificar firewall da VPS
2. Verificar se INTERFACE está configurado como 0.0.0.0 no .env
3. Verificar logs para erros de bind de porta

---

## Estrutura de Tags

O EMS Server usa as seguintes tags de versão:

- **`latest`**: Última versão estável (branch main)
- **`{version}`**: Versão específica (ex: `1.1.0`)
- **`v{major.minor}`**: Major.minor (ex: `v1.1`)
- **`sha-{commit}`**: Commit específico (rastreabilidade)

**Recomendações:**
- **Produção:** Use versões específicas (ex: `1.1.0`)
- **Testes:** Use `latest` ou `v1.1` (recebe patches automaticamente)
- **Debug:** Use `sha-{commit}` para versão exata de um commit

---

## Considerações de Segurança

1. **GITHUB_TOKEN:**
   - Nunca commite o token no repositório
   - Use permissões mínimas (`read:packages`)
   - Rotacione a cada 90 dias
   - Guarde em local seguro (ex: password manager)

2. **Arquivo .env:**
   - Nunca commite o .env no repositório
   - Use senhas fortes e únicas
   - Restrinja acesso ao arquivo na VPS:
     ```bash
     chmod 600 .env
     ```

3. **Atualizações:**
   - Monitore releases de segurança
   - Mantenha Docker atualizado
   - Faça backup antes de updates críticos

4. **Firewall:**
   - Configure firewall na VPS
   - Abra apenas portas necessárias (8181, 22)
   - Considere usar Nginx como proxy reverso

---

## Referências

- **Guia Geral de Operações:** `servers/OPERATIONS.md`
- **Infraestrutura Docker:** `servers/INFRASTRUCTURE.md`
- **GitHub Container Registry:** https://github.com/edumigsoft/ems_system/pkgs/container/ems-server
- **Issues e Suporte:** https://github.com/edumigsoft/ems_system/issues
