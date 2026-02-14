# Quick Start - Deploy EMS Server

Guia rápido para o fluxo: **PC Local → GHCR → VPS**

---

## 📋 Pré-requisitos

### No PC Local
- Docker instalado
- Git configurado
- GitHub Personal Access Token (PAT) com permissões `read:packages` e `write:packages`
  - Criar em: https://github.com/settings/tokens

### Na VPS
- Docker instalado
- Acesso SSH configurado
- GitHub Token configurado (mesmo do PC local)

---

## 🚀 Workflow Rápido

### Opção 1: Scripts Separados (Recomendado)

#### No PC Local

```bash
# 1. Build da imagem local
./scripts/build-local.sh ems

# 2. Push para GHCR
GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX ./scripts/push-to-ghcr.sh ems
```

#### Na VPS (via SSH)

```bash
# Conectar na VPS
ssh user@vps

# Ir para o diretório do container
cd /caminho/ems_system/servers/ems/container

# Atualizar servidor (pull + restart)
./update.sh
```

---

### Opção 2: Script Combinado (PC Local)

```bash
# Build + Push em um único comando
./servers/ems/container/build-and-push.sh
```

Depois conecte na VPS e execute `./update.sh`

---

## ⚙️ Configuração Inicial

### PC Local (Primeira Vez)

```bash
# Clonar repositório
git clone https://github.com/edumigsoft/ems_system.git
cd ems_system

# Configurar token permanentemente (opcional)
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX
echo 'export GITHUB_TOKEN=ghp_XXX' >> ~/.bashrc
source ~/.bashrc

# Dar permissões de execução aos scripts
chmod +x scripts/build-local.sh
chmod +x scripts/push-to-ghcr.sh
chmod +x servers/ems/container/build-and-push.sh
```

### VPS (Primeira Vez)

```bash
# Instalar Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Fazer logout e login novamente

# Criar rede Docker
docker network create ems_system_net

# Clonar repositório
git clone https://github.com/edumigsoft/ems_system.git
cd ems_system/servers/ems/container

# Configurar variáveis de ambiente
cp .env.example .env
nano .env  # Editar credenciais do banco de dados

# Configurar token GHCR permanentemente (opcional)
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX
echo 'export GITHUB_TOKEN=ghp_XXX' >> ~/.bashrc
source ~/.bashrc

# Dar permissões de execução aos scripts
chmod +x update.sh
chmod +x deploy-prod.sh
chmod +x rollback.sh

# Login no GHCR (será solicitado automaticamente pelo update.sh se não configurado)
echo "$GITHUB_TOKEN" | docker login ghcr.io -u edumigsoft --password-stdin
```

---

## 🔄 Deploy/Update (Após Configuração Inicial)

### Sempre que houver uma nova versão:

**PC Local:**
```bash
cd /caminho/ems_system
./scripts/build-local.sh ems
GITHUB_TOKEN=ghp_XXX ./scripts/push-to-ghcr.sh ems
```

**VPS:**
```bash
ssh user@vps
cd /caminho/ems_system/servers/ems/container
./update.sh
```

---

## ✅ Verificação

```bash
# Status dos containers
docker ps

# Healthcheck
curl http://localhost:8181/health

# Logs em tempo real
docker-compose -f docker-compose.prod.yml logs -f

# Parar logs (Ctrl+C)
```

---

## 🔧 Scripts Disponíveis

### PC Local

| Script | Descrição |
|--------|-----------|
| `scripts/build-local.sh ems` | Build da imagem Docker local |
| `scripts/push-to-ghcr.sh ems` | Push manual para GHCR |
| `servers/ems/container/build-and-push.sh` | Build + Push combinados |

### VPS

| Script | Descrição |
|--------|-----------|
| `update.sh` | **Atualização rápida** (sempre usa `latest`) |
| `deploy-prod.sh` | Deploy completo (permite escolher versão específica) |
| `rollback.sh` | Rollback para versão anterior |

---

## 📝 Notas Importantes

1. **Script `update.sh` vs `deploy-prod.sh`:**
   - `update.sh`: Rápido, direto, sempre usa tag `latest`
   - `deploy-prod.sh`: Completo, interativo, permite escolher versão específica

2. **Tags de Imagem:**
   - `latest`: Última versão estável
   - `1.1.0`: Versão específica
   - `v1.1`: Major.minor (facilita upgrades de patch)

3. **Segurança do Token:**
   - Nunca commite o token no Git
   - Rotacione o token regularmente (recomendado a cada 90 dias)
   - Use variável de ambiente ou arquivo `.env` local

4. **Backup antes de deploy:**
   ```bash
   # Backup do banco de dados (recomendado)
   cd servers/containers/postgres
   docker-compose exec postgres pg_dump -U postgres -d ems_db > backup_$(date +%Y%m%d).sql
   ```

---

## 🆘 Troubleshooting

### Erro de Autenticação GHCR

```bash
# Verificar token
echo $GITHUB_TOKEN

# Login manual
echo "$GITHUB_TOKEN" | docker login ghcr.io -u edumigsoft --password-stdin
```

### Container não inicia

```bash
# Ver logs
docker logs ems_server_prod

# Verificar variáveis de ambiente
docker exec ems_server_prod env | grep DB_

# Verificar rede
docker network ls | grep ems_system_net
```

### Healthcheck failing

```bash
# Testar endpoint
curl http://localhost:8181/health

# Verificar porta
docker port ems_server_prod
```

---

## 📚 Documentação Completa

Para informações detalhadas, consulte:

- **Operações Completas:** `servers/OPERATIONS.md`
- **Deploy Detalhado:** `servers/ems/container/DEPLOY.md`
- **Infraestrutura:** `servers/INFRASTRUCTURE.md`

---

## 🎯 Resumo do Fluxo

```
PC Local:                    VPS:
┌─────────────────┐         ┌──────────────────┐
│ 1. build-local  │         │ 3. update.sh     │
│    ↓            │         │    ↓             │
│ 2. push-to-ghcr │ ──────→ │ 4. Verificar     │
└─────────────────┘         └──────────────────┘
```

**Tempo estimado:** 5-10 minutos (build + deploy)
