# Arquitetura de Infraestrutura (Docker, Local e VPS)

Centraliza as definições de infraestrutura do EMS System para desenvolvimento local e produção (VPS).

---

## 1. 💻 Ambiente de Desenvolvimento Local

O ambiente local espelha a produção com a mesma stack (Traefik + Docker + PostgreSQL), diferindo apenas nos domínios `.local` e TLS via `mkcert`.

### Estrutura local relevante

```
~/Projects/Working/ems_system/              ← raiz do repositório
│
├── .dev-data/                              ← volumes locais (.gitignore'd)
│   ├── uploads/
│   │   ├── ems/
│   │   └── sms/
│   └── logs/
│       ├── ems/
│       └── sms/
│
└── servers/
    ├── dev.sh                              ← build local da imagem
    ├── publish.sh                          ← publica imagem no GHCR
    ├── update.sh                           ← deploy na VPS (pull + restart)
    ├── rollback.sh                         ← rollback de versão na VPS
    │
    ├── infra/
    │   ├── docker-compose.dev.yml          ← Traefik dev (mkcert, sem ACME)
    │   ├── docker-compose.prod.yml         ← Traefik prod (Let's Encrypt ACME)
    │   └── certs/
    │       ├── tls.yml                     ← configuração TLS para mkcert
    │       ├── local.pem                   ← cert local (.gitignore'd)
    │       └── local-key.pem              ← chave local (.gitignore'd)
    │
    ├── containers/
    │   └── postgres/
    │       ├── docker-compose.prod.yml     ← PostgreSQL (dev e prod usam o mesmo)
    │       ├── .env_example               ← template de credenciais
    │       └── .env                       ← credenciais (.gitignore'd)
    │
    ├── ems/
    │   ├── server_v1/                     ← código-fonte do servidor EMS
    │   └── container/
    │       ├── Dockerfile
    │       ├── docker-compose.dev.yml      ← EMS dev → api.ems.local
    │       ├── docker-compose.prod.yml     ← EMS prod → api.ems.edumigsoft.com.br
    │       ├── .env_example               ← template (anotações dev/VPS)
    │       └── .env                       ← valores locais (.gitignore'd)
    │
    └── sms/
        ├── server_v1/                     ← código-fonte do servidor SMS
        └── container/
            ├── Dockerfile
            ├── docker-compose.dev.yml      ← SMS dev → api.sms.local
            ├── docker-compose.prod.yml     ← SMS prod → api.sms.edumigsoft.com.br
            ├── .env_example               ← template (anotações dev/VPS)
            └── .env                       ← valores locais (.gitignore'd)
```

---

## 2. ☁️ Produção (VPS) — Estrutura de Diretórios

A VPS utiliza **caminhos absolutos** para isolar dados persistentes do repositório,
evitando fragilidades com movimentação de arquivos ou re-clones.

### Estrutura definitiva em `/root/`

```
/root/
│
├── infra/                                  ← infraestrutura compartilhada (todos os sistemas)
│   └── letsencrypt/                       ← certificados ACME Let's Encrypt (persistente)
│
├── ems_system/                            ← EMS System
│   ├── .secrets/
│   │   └── github                        ← GHCR token (chmod 600) — ver Seção 4
│   │
│   ├── data/                             ← volumes persistentes (fora do repo)
│   │   ├── uploads/
│   │   │   ├── ems/
│   │   │   └── sms/
│   │   ├── logs/
│   │   │   ├── ems/
│   │   │   └── sms/
│   │   └── backups/                      ← dumps pg_dump (cron)
│   │
│   └── repo/                             ← repositório git clonado
│       └── servers/                      ← única pasta usada na VPS
│           ├── update.sh                 ← deploy: pull imagem + restart
│           ├── rollback.sh               ← rollback de versão
│           │
│           ├── infra/
│           │   └── docker-compose.prod.yml  ← Traefik (ACME → /root/infra/letsencrypt)
│           │
│           ├── containers/
│           │   └── postgres/
│           │       ├── docker-compose.prod.yml
│           │       ├── .env_example
│           │       └── .env              ← criar manualmente na VPS
│           │
│           ├── ems/container/
│           │   ├── docker-compose.prod.yml
│           │   ├── .env_example
│           │   └── .env                  ← criar manualmente na VPS
│           │
│           └── sms/container/
│               ├── docker-compose.prod.yml
│               ├── .env_example
│               └── .env                  ← criar manualmente na VPS
│
└── ppr_system/                           ← outros sistemas futuros (mesmo padrão)
    ├── .secrets/github
    ├── data/...
    └── repo/...
```

### Equivalência local ↔ VPS

| Elemento | Local | VPS |
|---|---|---|
| Repositório | `~/Projects/Working/ems_system/` | `/root/ems_system/repo/` |
| Traefik config | `servers/infra/docker-compose.dev.yml` | `servers/infra/docker-compose.prod.yml` |
| TLS | `servers/infra/certs/` (mkcert) | `/root/infra/letsencrypt/` (Let's Encrypt ACME) |
| PostgreSQL | `servers/containers/postgres/docker-compose.prod.yml` | idem |
| EMS compose | `servers/ems/container/docker-compose.dev.yml` | `servers/ems/container/docker-compose.prod.yml` |
| SMS compose | `servers/sms/container/docker-compose.dev.yml` | `servers/sms/container/docker-compose.prod.yml` |
| Uploads EMS | `.dev-data/uploads/ems/` | `/root/ems_system/data/uploads/ems/` |
| Uploads SMS | `.dev-data/uploads/sms/` | `/root/ems_system/data/uploads/sms/` |
| Logs EMS | `.dev-data/logs/ems/` | `/root/ems_system/data/logs/ems/` |
| Logs SMS | `.dev-data/logs/sms/` | `/root/ems_system/data/logs/sms/` |
| GHCR token | `$GITHUB_TOKEN` local | `/root/ems_system/.secrets/github` |

### Mapeamento de volumes nos composes de produção

| Serviço | Volume Host (default no compose) | Override via `.env` |
|---|---|---|
| Traefik ACME | `/root/infra/letsencrypt` | — (hardcoded) |
| EMS uploads | `/root/ems_system/data/uploads/ems` | `UPLOADS_HOST_PATH` |
| EMS logs | `/root/ems_system/data/logs/ems` | `LOGS_HOST_PATH` |
| SMS uploads | `/root/ems_system/data/uploads/sms` | `UPLOADS_HOST_PATH` |
| SMS logs | `/root/ems_system/data/logs/sms` | `LOGS_HOST_PATH` |

---

## 3. 🚨 Plano de Migração na VPS (execução manual)

> Causa ~10-15 min de downtime. Executar fora do horário de pico.
> PostgreSQL em **named volume** permanece intacto durante toda a migração.

### Passo 1 — Criar hierarquia definitiva

```bash
mkdir -p /root/infra/letsencrypt
mkdir -p /root/ems_system/.secrets
mkdir -p /root/ems_system/data/uploads/{ems,sms}
mkdir -p /root/ems_system/data/logs/{ems,sms}
mkdir -p /root/ems_system/data/backups
chmod 700 /root/ems_system/.secrets

# Mover o repositório para a nova localização
mv /caminho/antigo/ems_system /root/ems_system/repo
```

### Passo 2 — Backup e derrubada das stacks antigas

```bash
# Backup crítico antes de qualquer operação
cp -r <caminho_antigo>/letsencrypt /root/infra/letsencrypt
cp -r <caminho_antigo>/uploads/ems  /root/ems_system/data/uploads/ems
cp -r <caminho_antigo>/uploads/sms  /root/ems_system/data/uploads/sms

# Derrubar stacks antigas
cd /root/ems_system/repo/servers
docker compose -f infra/docker-compose.prod.yml down
docker compose -f ems/container/docker-compose.prod.yml down
docker compose -f sms/container/docker-compose.prod.yml down
```

### Passo 3 — Alterações de código ✅ (já implementado)

- `servers/infra/docker-compose.prod.yml` → volume letsencrypt usa `/root/infra/letsencrypt`
- `servers/ems/container/docker-compose.prod.yml` → defaults absolutos para uploads/logs
- `servers/sms/container/docker-compose.prod.yml` → volumes adicionados com defaults absolutos
- `servers/update.sh` → secrets path atualizado para `/root/ems_system/.secrets/github`
- `.env_example` de cada container → anotações `# Dev: ... | VPS: ...` para cada path
- Todos os `docker-compose.yml` renomeados para `docker-compose.prod.yml`

### Passo 4 — Criar `.env` de produção e subir stacks

```bash
cd /root/ems_system/repo/servers

# Criar .env de produção (baseado nos _example)
cp containers/postgres/.env_example containers/postgres/.env
cp ems/container/.env_example ems/container/.env
cp sms/container/.env_example sms/container/.env

# Editar cada .env:
#   - ENVIRONMENT=production
#   - DB_* com credenciais reais
#   - JWT_KEY, API_KEY com valores seguros
#   - UPLOADS_HOST_PATH e LOGS_HOST_PATH já têm defaults absolutos corretos
nano containers/postgres/.env
nano ems/container/.env
nano sms/container/.env

# Subir infraestrutura
docker compose -f infra/docker-compose.prod.yml up -d
docker compose -f containers/postgres/docker-compose.prod.yml up -d
docker compose -f ems/container/docker-compose.prod.yml up -d
docker compose -f sms/container/docker-compose.prod.yml up -d

# Validar emissão do certificado ACME (~2 min)
docker logs traefik --tail 50 | grep -i acme
```

---

## 4. 🔐 GITHUB_TOKEN na VPS (GHCR Pull)

Cada sistema mantém sua própria credencial de leitura do GitHub Container Registry.

**Localização:** `/root/ems_system/.secrets/github`
**Permissão:** `chmod 600`
**Formato:**
```bash
export GITHUB_TOKEN=ghp_ABC123...
```

O `update.sh` carrega automaticamente esse arquivo via `source` antes de `docker login`.

### Rotação do token

1. Revogue e reemita em **GitHub → Settings → Developer Settings → Classic Tokens** (escopo: `read:packages`)
2. Na VPS, sobrescreva o arquivo: `/root/ems_system/.secrets/github`
3. Valide:
```bash
source /root/ems_system/.secrets/github && echo $GITHUB_TOKEN | docker login ghcr.io -u edumigsoft --password-stdin
```
