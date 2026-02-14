# SMS Server - Guia de Deploy em Produção

Este guia documenta o processo de deploy do servidor SMS em produção usando imagens do GitHub Container Registry (GHCR).

## Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Configuração Inicial](#configuração-inicial)
3. [Deploy](#deploy)
4. [Atualização](#atualização)
5. [Rollback](#rollback)
6. [Monitoramento](#monitoramento)
7. [Deploy Conjunto EMS + SMS](#deploy-conjunto-ems--sms)
8. [Troubleshooting](#troubleshooting)

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
cd ems_system/servers/sms/container
```

**Opção B: Copiar apenas arquivos necessários**
```bash
# Na sua máquina local
scp -r servers/sms/container user@vps-ip:/caminho/deploy/sms/

# Na VPS
cd /caminho/deploy/sms/container
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
# Porta do servidor (DIFERENTE do EMS)
SERVER_PORT=8080

# Banco de dados PostgreSQL
DB_HOST=postgres
DB_PORT=5432
DB_NAME=sms_db
DB_USER=postgres
DB_PASSWORD=senha_segura

# JWT
JWT_SECRET=chave_secreta_segura_aqui

# Outras configurações específicas do SMS
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
cd /caminho/deploy/sms/container

# Tornar script executável (primeira vez)
chmod +x deploy-prod.sh

# Executar deploy
./deploy-prod.sh
```

### Deploy Manual

```bash
cd /caminho/deploy/sms/container

# 1. Pull da imagem
docker pull ghcr.io/edumigsoft/sms-server:latest

# 2. Parar container antigo
docker-compose -f docker-compose.prod.yml down

# 3. Iniciar novo container
docker-compose -f docker-compose.prod.yml up -d

# 4. Verificar logs
docker-compose -f docker-compose.prod.yml logs -f
```

---

## Atualização

### Atualizar para Última Versão

```bash
cd /caminho/deploy/sms/container

# Método 1: Script automatizado
./deploy-prod.sh

# Método 2: Manual
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

---

## Rollback

### Rollback Automatizado

```bash
cd /caminho/deploy/sms/container

# Tornar script executável (primeira vez)
chmod +x rollback.sh

# Executar rollback
./rollback.sh
```

---

## Monitoramento

### Verificar Status

```bash
# Status do container
docker ps | grep sms_server_prod

# Status via docker-compose
docker-compose -f docker-compose.prod.yml ps
```

### Logs

```bash
# Logs em tempo real
docker-compose -f docker-compose.prod.yml logs -f

# Últimas 100 linhas
docker logs sms_server_prod --tail 100
```

### Healthcheck

```bash
# Via curl (PORTA 8080 para SMS)
curl http://localhost:8080/health

# Healthcheck interno do Docker
docker inspect sms_server_prod | jq '.[0].State.Health'
```

---

## Deploy Conjunto EMS + SMS

### Iniciar Ambos os Servidores

Como EMS e SMS usam portas diferentes (8181 e 8080), podem rodar simultaneamente:

```bash
# 1. Deploy EMS
cd /caminho/deploy/ems/container
./deploy-prod.sh

# 2. Deploy SMS
cd /caminho/deploy/sms/container
./deploy-prod.sh
```

### Verificar Ambos os Servidores

```bash
# Status de todos os containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Healthcheck de ambos
curl http://localhost:8181/health  # EMS
curl http://localhost:8080/health  # SMS

# Logs combinados
docker logs ems_server_prod --tail 20
docker logs sms_server_prod --tail 20
```

### Atualizar Apenas Um Servidor

Cada servidor é independente:

```bash
# Atualizar apenas SMS (EMS continua rodando)
cd /caminho/deploy/sms/container
./deploy-prod.sh

# Atualizar apenas EMS (SMS continua rodando)
cd /caminho/deploy/ems/container
./deploy-prod.sh
```

---

## Troubleshooting

### Conflito de Porta

**Problema:** Porta 8080 já está em uso.

**Diagnóstico:**
```bash
sudo lsof -i :8080
```

**Solução:**
1. Parar serviço conflitante, OU
2. Alterar porta no .env do SMS para outra (ex: 8082)

### SMS Não Conecta ao Banco

**Problema:** Container para com erro de conexão ao banco.

**Verificações:**
```bash
# 1. Verificar se PostgreSQL está rodando
docker ps | grep postgres

# 2. Verificar se database SMS existe
docker exec postgres_db psql -U postgres -l | grep sms_db

# 3. Criar database se não existir
docker exec postgres_db psql -U postgres -c "CREATE DATABASE sms_db;"

# 4. Verificar variáveis de ambiente
docker exec sms_server_prod env | grep DB_
```

### Diferenças EMS vs SMS

| Aspecto | EMS | SMS |
|---------|-----|-----|
| **Porta** | 8181 | 8080 |
| **Container** | ems_server_prod | sms_server_prod |
| **Imagem** | ghcr.io/edumigsoft/ems-server | ghcr.io/edumigsoft/sms-server |
| **Database** | ems_db | sms_db |
| **Pacotes Extras** | tag, notebook | school |

---

## Estrutura de Tags

O SMS Server usa as mesmas tags do EMS:

- **`latest`**: Última versão estável (branch main)
- **`{version}`**: Versão específica (ex: `1.1.0`)
- **`v{major.minor}`**: Major.minor (ex: `v1.1`)
- **`sha-{commit}`**: Commit específico

**Versionamento Independente:**
- EMS e SMS têm versões independentes
- EMS pode estar na v1.3.0 enquanto SMS está na v1.1.5
- Cada servidor lê versão do próprio `pubspec.yaml`

---

## Considerações de Segurança

**Mesmas recomendações do EMS Server:**

1. **GITHUB_TOKEN:** Permissões mínimas, rotacionar regularmente
2. **Arquivo .env:** Nunca commitar, usar senhas fortes
3. **Atualizações:** Monitorar releases de segurança
4. **Firewall:** Configurar portas 8080 (SMS) e 8181 (EMS)

---

## Referências

- **Guia Geral de Operações:** `servers/OPERATIONS.md`
- **Deploy EMS:** `servers/ems/container/DEPLOY.md`
- **Infraestrutura Docker:** `servers/INFRASTRUCTURE.md`
- **GitHub Container Registry:** https://github.com/edumigsoft/ems_system/pkgs/container/sms-server
