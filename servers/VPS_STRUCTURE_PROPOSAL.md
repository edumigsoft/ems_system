# Proposta: Nova Estrutura de Pastas na VPS

> **Status:** Proposta — aguardando implementação
> **Criado em:** 2026-02-21
> **Contexto:** Refatoração da estrutura de diretórios na VPS para separar configuração (versionada) de dados persistentes (não versionados).

---

## Problema com a Estrutura Atual

A estrutura implícita atual tem os seguintes problemas:

| Problema | Impacto |
|---|---|
| `../../../uploads` como path relativo | Frágil, quebra se o repo for movido |
| `letsencrypt/` dentro de `servers/infra/` | Dados persistentes misturados com config versionada |
| `logs/` dentro de `servers/ems/container/` | Logs misturados com config versionada |
| Repo inteiro clonado na VPS | Flutter apps, packages Dart, docs — nada disso é necessário |
| Path base indefinido (`/caminho/ems_system/`) | Não documentado onde fica na VPS |

---

## Estrutura Proposta na VPS

```
/opt/ems_system/
│
├── servers/                              # git clone (ou sparse-checkout)
│   │                                     # apenas o diretório servers/ é necessário na VPS
│   ├── infra/
│   │   └── docker-compose.yml           # Traefik + Portainer
│   ├── containers/
│   │   └── postgres/
│   │       ├── docker-compose.yml
│   │       └── .env                     # chmod 600 — NÃO versionado
│   ├── ems/
│   │   └── container/
│   │       ├── docker-compose.prod.yml
│   │       └── .env                     # chmod 600 — NÃO versionado
│   ├── sms/
│   │   └── container/
│   │       ├── docker-compose.prod.yml
│   │       └── .env                     # chmod 600 — NÃO versionado
│   ├── update.sh
│   └── rollback.sh
│
├── data/                                 # NÃO versionado — estado persistente
│   ├── letsencrypt/                     # certificados TLS (era servers/infra/letsencrypt/)
│   ├── uploads/                         # arquivos enviados pelas aplicações
│   │   ├── ems/                         # uploads do EMS
│   │   └── sms/                         # uploads do SMS
│   └── portainer/                       # (opcional) dados do Portainer em bind mount
│
└── logs/                                 # NÃO versionado — logs das aplicações
    ├── ems/
    └── sms/
```

> **Nota sobre PostgreSQL e Portainer:** Ambos usam **named Docker volumes**
> (`postgres_ems_system_data` e `portainer_data`), gerenciados pelo Docker.
> Esses volumes **não precisam ser migrados** — ficam em `/var/lib/docker/volumes/`
> e continuam funcionando independente de onde o repo está clonado.

---

## Variáveis de Ambiente — Após a Migração

### `servers/ems/container/.env` (produção)

```env
SERVER_PORT=8181

DB_HOST=postgres_ems_system
DB_PORT=5432
DB_NAME=ems_production
DB_USER=ems_user
DB_PASS=senha_forte_ems

ENVIRONMENT=production

# Paths absolutos — sem mais ../../../
UPLOADS_HOST_PATH=/opt/ems_system/data/uploads/ems
UPLOADS_CONTAINER_PATH=/app/uploads
LOGS_HOST_PATH=/opt/ems_system/logs/ems
LOGS_CONTAINER_PATH=/app/logs

MAX_FILE_SIZE=50MB
ALLOWED_MIME_TYPES=application/pdf,image/jpeg,image/png
STORAGE_TYPE=local
```

### `servers/sms/container/.env` (produção)

```env
SERVER_PORT=8080

DB_HOST=postgres_ems_system
DB_PORT=5432
DB_NAME=sms_production
DB_USER=sms_user
DB_PASS=senha_forte_sms

ENVIRONMENT=production

# Paths absolutos — sem mais ../../../
UPLOADS_HOST_PATH=/opt/ems_system/data/uploads/sms
UPLOADS_CONTAINER_PATH=/app/uploads
LOGS_HOST_PATH=/opt/ems_system/logs/sms
LOGS_CONTAINER_PATH=/app/logs

MAX_FILE_SIZE=50MB
ALLOWED_MIME_TYPES=application/pdf,image/jpeg,image/png
STORAGE_TYPE=local
```

---

## Mudança no `servers/infra/docker-compose.yml`

O volume do Traefik precisa mudar de relativo para absoluto:

```yaml
# ANTES
volumes:
  - ./letsencrypt:/letsencrypt

# DEPOIS
volumes:
  - /opt/ems_system/data/letsencrypt:/letsencrypt
```

---

## Plano de Migração na VPS

> **Tempo estimado:** 10–15 minutos de downtime
> **Risco:** Baixo — PostgreSQL e Portainer usam named volumes (sem movimento de dados)

### Passo 0 — Backup preventivo

```bash
# Backup do banco de dados (EXECUTE ANTES DE QUALQUER COISA)
docker exec postgres_ems_system pg_dumpall -U postgres > /tmp/backup_pre_migration_$(date +%Y%m%d_%H%M).sql

# Backup dos certificados TLS
cp -r /caminho_atual/servers/infra/letsencrypt /tmp/letsencrypt_backup_$(date +%Y%m%d)

# Backup dos uploads (se existirem)
cp -r /caminho_atual/uploads /tmp/uploads_backup_$(date +%Y%m%d) 2>/dev/null || echo "Sem uploads para fazer backup"

echo "Backups concluídos em /tmp/"
```

### Passo 1 — Criar estrutura nova

```bash
mkdir -p /opt/ems_system/data/letsencrypt
mkdir -p /opt/ems_system/data/uploads/ems
mkdir -p /opt/ems_system/data/uploads/sms
mkdir -p /opt/ems_system/data/portainer
mkdir -p /opt/ems_system/logs/ems
mkdir -p /opt/ems_system/logs/sms

# Permissões adequadas
chmod 750 /opt/ems_system/data
chmod 750 /opt/ems_system/logs
```

### Passo 2 — Derrubar os serviços (downtime começa aqui)

```bash
# Parar em ordem reversa à inicialização
cd /caminho_atual/servers/ems/container
docker compose -f docker-compose.prod.yml down

cd /caminho_atual/servers/sms/container
docker compose -f docker-compose.prod.yml down

cd /caminho_atual/servers/infra
docker compose down

# PostgreSQL pode continuar rodando (named volume, sem impacto)
# Mas se preferir parar tudo:
# cd /caminho_atual/servers/containers/postgres
# docker compose down
```

### Passo 3 — Mover dados persistentes

```bash
# Mover certificados TLS (crítico — se perder, Traefik reemite, mas gera downtime de DNS)
cp -r /caminho_atual/servers/infra/letsencrypt/. /opt/ems_system/data/letsencrypt/

# Mover uploads do EMS (se existirem)
UPLOADS_ATUAL="/caminho_atual/uploads"
if [ -d "$UPLOADS_ATUAL" ]; then
    cp -r "$UPLOADS_ATUAL/." /opt/ems_system/data/uploads/ems/
    echo "Uploads EMS migrados"
else
    echo "Nenhum upload encontrado em $UPLOADS_ATUAL"
fi

# Mover logs (opcional — pode deixar começar do zero)
cp -r /caminho_atual/servers/ems/container/logs/. /opt/ems_system/logs/ems/ 2>/dev/null || echo "Sem logs EMS para mover"
cp -r /caminho_atual/servers/sms/container/logs/. /opt/ems_system/logs/sms/ 2>/dev/null || echo "Sem logs SMS para mover"
```

### Passo 4 — Enviar arquivos de configuração para a VPS

Não é necessário git na VPS. Apenas os arquivos de configuração Docker precisam estar lá.
As imagens dos servidores são puxadas do GHCR via `update.sh`.

```bash
# A partir da máquina local (projeto raiz), sincronizar apenas o que a VPS precisa:
rsync -avz --delete \
  --exclude='.env' \
  --exclude='server_v1/' \
  --exclude='.dart_tool/' \
  --exclude='*.dart' \
  --exclude='*.reflectable.dart' \
  --exclude='*.http' \
  --exclude='*.yaml' \
  --include='*/' \
  servers/infra/          user@vps:/opt/ems_system/servers/infra/
  servers/containers/     user@vps:/opt/ems_system/servers/containers/
  servers/ems/container/  user@vps:/opt/ems_system/servers/ems/container/
  servers/sms/container/  user@vps:/opt/ems_system/servers/sms/container/

# Scripts de deploy
rsync -avz servers/update.sh servers/rollback.sh user@vps:/opt/ems_system/servers/
ssh user@vps "chmod +x /opt/ems_system/servers/update.sh /opt/ems_system/servers/rollback.sh"
```

> **O que vai para a VPS:** apenas `docker-compose.prod.yml`, scripts e estrutura de diretórios.
> **O que NÃO vai:** código-fonte Dart, Dockerfiles (imagens já estão no GHCR), arquivos `.env` (ficam só na VPS).

> **Dica:** Adicionar uma entrada em `~/.ssh/config` com alias `vps` facilita os comandos `rsync`/`ssh`.

### Passo 5 — Configurar arquivos `.env` na nova localização

```bash
# Copiar .env existentes para nova localização (editá-los logo após)
cp /caminho_atual/servers/containers/postgres/.env /opt/ems_system/servers/containers/postgres/.env
cp /caminho_atual/servers/ems/container/.env       /opt/ems_system/servers/ems/container/.env
cp /caminho_atual/servers/sms/container/.env       /opt/ems_system/servers/sms/container/.env

# Proteger
chmod 600 /opt/ems_system/servers/containers/postgres/.env
chmod 600 /opt/ems_system/servers/ems/container/.env
chmod 600 /opt/ems_system/servers/sms/container/.env

# Editar .env do EMS — atualizar paths de uploads e logs
nano /opt/ems_system/servers/ems/container/.env
# Alterar:
#   UPLOADS_HOST_PATH=/opt/ems_system/data/uploads/ems
#   LOGS_HOST_PATH=/opt/ems_system/logs/ems

# Editar .env do SMS — atualizar paths de uploads e logs
nano /opt/ems_system/servers/sms/container/.env
# Alterar:
#   UPLOADS_HOST_PATH=/opt/ems_system/data/uploads/sms
#   LOGS_HOST_PATH=/opt/ems_system/logs/sms
```

### Passo 6 — Subir os serviços na nova localização

```bash
# Rede Docker (se não existir)
docker network create ems_system_net 2>/dev/null || echo "Rede já existe"

# PostgreSQL (se foi derrubado no Passo 2)
cd /opt/ems_system/servers/containers/postgres
docker compose up -d
docker compose ps   # verificar se está healthy

# Traefik + Portainer (com novo path absoluto no docker-compose.yml)
cd /opt/ems_system/servers/infra
docker compose up -d

# EMS
cd /opt/ems_system/servers/ems/container
docker compose -f docker-compose.prod.yml up -d

# SMS
cd /opt/ems_system/servers/sms/container
docker compose -f docker-compose.prod.yml up -d
```

### Passo 7 — Validação

```bash
# Status de todos os containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Health checks das APIs
curl -s https://api.ems.edumigsoft.com.br/api/v1/health | python3 -m json.tool
curl -s https://api.sms.edumigsoft.com.br/api/v1/health | python3 -m json.tool

# Verificar se certificados TLS foram carregados (não reemitidos)
docker logs traefik 2>&1 | grep -i "acme\|certificate\|letsencrypt" | tail -20

# Verificar volumes dos containers
docker inspect ems_server_prod | python3 -c "import sys,json; [print(m['Source'], '->', m['Destination']) for m in json.load(sys.stdin)[0]['Mounts']]"
docker inspect sms_server_prod | python3 -c "import sys,json; [print(m['Source'], '->', m['Destination']) for m in json.load(sys.stdin)[0]['Mounts']]"
```

### Passo 8 — Limpeza (somente após validação completa)

```bash
# Remover estrutura antiga (aguardar pelo menos 24h após validação)
# rm -rf /caminho_atual/servers/infra/letsencrypt
# rm -rf /caminho_atual/servers/ems/container/logs
# rm -rf /caminho_atual/servers/sms/container/logs
# rm -rf /caminho_atual/uploads

echo "Remova a estrutura antiga somente após confirmar que tudo está funcionando"
```

---

## O que NÃO precisa ser migrado

| Dado | Motivo |
|---|---|
| PostgreSQL (`postgres_ems_system_data`) | Named Docker volume — gerenciado pelo Docker em `/var/lib/docker/volumes/`. Não se move com o repo. |
| Portainer (`portainer_data`) | Idem — named volume. |
| Imagens Docker | Ficam no daemon Docker da máquina. |

---

## Rollback (se algo der errado)

```bash
# 1. Derrubar serviços novos
cd /opt/ems_system/servers/ems/container && docker compose -f docker-compose.prod.yml down
cd /opt/ems_system/servers/sms/container && docker compose -f docker-compose.prod.yml down
cd /opt/ems_system/servers/infra && docker compose down

# 2. Restaurar certificados TLS (se necessário)
cp -r /tmp/letsencrypt_backup_*/ /caminho_atual/servers/infra/letsencrypt/

# 3. Subir estrutura antiga
cd /caminho_atual/servers/infra && docker compose up -d
cd /caminho_atual/servers/ems/container && docker compose -f docker-compose.prod.yml up -d
cd /caminho_atual/servers/sms/container && docker compose -f docker-compose.prod.yml up -d

# 4. Restaurar banco (somente se necessário — named volume não foi tocado)
# docker exec -i postgres_ems_system psql -U postgres < /tmp/backup_pre_migration_*.sql
```

---

## Alterações de Código Necessárias

Após definir `/opt/ems_system/` como path base na VPS, os seguintes arquivos precisarão ser atualizados no repo:

- [ ] `servers/infra/docker-compose.yml` — volume do Traefik: `./letsencrypt` → `/opt/ems_system/data/letsencrypt`
- [ ] `servers/ems/container/.env_example` — atualizar defaults de `UPLOADS_HOST_PATH` e `LOGS_HOST_PATH`
- [ ] `servers/sms/container/.env_example` — idem
- [ ] `servers/INFRASTRUCTURE.md` — atualizar "Estrutura de Arquivos na VPS" e "Ordem de Inicialização"
- [ ] `servers/SETUP_VPS.md` — atualizar paths de referência e remover referências a git
- [ ] `servers/update.sh` — linha 68: `CONTAINER_DIR` derivado de `$SCRIPT_DIR` (ok para rsync, mas confirmar path absoluto na VPS)

## Sincronização de Configuração (sem git)

O fluxo de atualização de configuração na VPS sem git:

```
Desenvolvedor  →  rsync  →  VPS (/opt/ems_system/servers/)
                               ↓
                           update.sh ems/sms
                               ↓
                         docker pull GHCR
                               ↓
                         docker compose up -d
```

Apenas os `docker-compose.prod.yml` precisam ser re-sincronizados quando houver mudança na configuração dos containers. Na maioria dos deploys (nova versão de código), apenas `./update.sh ems latest` já basta.
