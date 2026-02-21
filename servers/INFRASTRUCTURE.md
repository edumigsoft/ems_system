# Infraestrutura Docker — EMS System

Documentação completa da infraestrutura Docker de produção do EMS System na VPS.

## Visão Geral

```
                         Internet
                             │
                   ┌─────────▼──────────┐
                   │   Traefik (443/80)  │  ← SSL automático (Let's Encrypt)
                   │  traefik.edumigsoft │  ← Dashboard protegido por senha
                   └──────┬──────┬───────┘
                          │      │
              ┌───────────▼──┐ ┌─▼──────────────┐
              │  EMS Server  │ │   SMS Server    │
              │ ems_server   │ │  sms_server     │
              │    _prod     │ │     _prod       │
              │ api.ems.*    │ │  api.sms.*      │
              └──────┬───────┘ └────────┬────────┘
                     │                  │
                     └──────┬───────────┘
                            │
               ┌────────────▼────────────┐
               │  PostgreSQL 17 Alpine   │
               │  postgres_ems_system    │
               │  (traefik.enable=false) │
               └─────────────────────────┘

         Todos os serviços na rede: ems_system_net (Docker bridge)
```

## Serviços e Responsabilidades

| Serviço | Container | Domínio | Descrição |
|---------|-----------|---------|-----------|
| Traefik | `traefik` | `traefik.edumigsoft.com.br` | Proxy reverso + TLS + dashboard |
| Portainer | `portainer` | `portainer.edumigsoft.com.br` | Gestão visual dos containers |
| EMS Server | `ems_server_prod` | `api.ems.edumigsoft.com.br` | API backend EMS |
| SMS Server | `sms_server_prod` | `api.sms.edumigsoft.com.br` | API backend SMS |
| PostgreSQL | `postgres_ems_system` | — (interno) | Banco de dados compartilhado |

## Rede Docker

Todos os serviços compartilham a rede `ems_system_net`:

```bash
# Criar a rede (somente uma vez na VPS)
docker network create ems_system_net
```

A rede deve ser criada **antes** de subir qualquer serviço. É marcada como `external: true` em todos os `docker-compose` para garantir que seja compartilhada.

## Traefik — Proxy Reverso

Localização: `servers/infra/docker-compose.yml`

### Configuração

- **Entrypoints**: `web` (80) e `websecure` (443)
- **Redirecionamento**: HTTP → HTTPS automático
- **TLS**: Let's Encrypt via HTTP challenge
- **Cert Resolver**: `ems_system_resolver`
- **Email ACME**: `admin@edumigsoft.com.br`
- **Dashboard**: Protegido por Basic Auth

### Labels dos serviços

Para um serviço ser roteado pelo Traefik, deve declarar:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.<nome>.rule=Host(`dominio.com`)"
  - "traefik.http.routers.<nome>.entrypoints=websecure"
  - "traefik.http.routers.<nome>.tls.certresolver=ems_system_resolver"
  - "traefik.http.services.<nome>.loadbalancer.server.port=${SERVER_PORT}"
```

Para **excluir** um serviço do Traefik (ex: banco de dados):

```yaml
labels:
  traefik.enable: "false"
```

### Subir Traefik + Portainer

```bash
cd servers/infra
docker compose up -d
```

## PostgreSQL — Banco de Dados Compartilhado

Localização: `servers/containers/postgres/`

- PostgreSQL 17 Alpine, uma instância, múltiplas databases
- **Porta `5432` vinculada apenas a `127.0.0.1`** — sem exposição pública
- Label `traefik.enable: "false"` — nunca roteado pelo proxy
- Consulte `servers/containers/postgres/README.md` para setup completo

## EMS Server — Produção

Localização: `servers/ems/container/docker-compose.prod.yml`

- **Serviço**: `ems_server_prod`
- **Imagem**: `ghcr.io/edumigsoft/ems-server:${IMAGE_TAG:-latest}`
- **Domínio**: `api.ems.edumigsoft.com.br`
- **Porta**: definida via `SERVER_PORT` no `.env` (Traefik lê internamente)
- **Volumes**:
  - `UPLOADS_HOST_PATH` → `UPLOADS_CONTAINER_PATH` (padrão: `../../../uploads:/app/uploads`)
  - `LOGS_HOST_PATH` → `LOGS_CONTAINER_PATH` (padrão: `./logs:/app/logs`)

## SMS Server — Produção

Localização: `servers/sms/container/docker-compose.prod.yml`

- **Serviço**: `sms_server_prod`
- **Imagem**: `ghcr.io/edumigsoft/sms-server:${IMAGE_TAG:-latest}`
- **Domínio**: `api.sms.edumigsoft.com.br`
- **Porta**: definida via `SERVER_PORT` no `.env`
- **Volumes**: mesma estrutura do EMS Server

## Variáveis de Ambiente — Produção

### EMS (`servers/ems/container/.env`)

```env
SERVER_PORT=8080

DB_HOST=postgres_ems_system
DB_PORT=5432
DB_NAME=ems_production
DB_USER=ems_user
DB_PASS=senha_forte_ems

ENVIRONMENT=production

UPLOADS_HOST_PATH=../../../uploads
UPLOADS_CONTAINER_PATH=/app/uploads
LOGS_HOST_PATH=./logs
LOGS_CONTAINER_PATH=/app/logs
```

### SMS (`servers/sms/container/.env`)

Baseado em `servers/sms/container/.env_example`:

```env
SERVER_PORT=8080

DB_HOST=postgres_ems_system
DB_PORT=5432
DB_NAME=sms_production
DB_USER=sms_user
DB_PASS=senha_forte_sms

ENVIRONMENT=production

UPLOADS_HOST_PATH=../../../uploads
UPLOADS_CONTAINER_PATH=/app/uploads
LOGS_HOST_PATH=./logs
LOGS_CONTAINER_PATH=/app/logs
MAX_FILE_SIZE=50MB
ALLOWED_MIME_TYPES=application/pdf,image/jpeg,image/png
STORAGE_TYPE=local
```

## Ordem de Inicialização na VPS

```bash
# 1. Criar rede compartilhada (somente na primeira vez)
docker network create ems_system_net

# 2. Subir PostgreSQL
cd servers/containers/postgres
docker compose up -d

# 3. Subir Traefik + Portainer
cd servers/infra
docker compose up -d

# 4. Deploy EMS e SMS (via scripts)
cd servers
./update.sh ems
./update.sh sms
```

## Estrutura de Arquivos na VPS

```
/caminho/ems_system/
└── servers/
    ├── infra/
    │   ├── docker-compose.yml      # Traefik + Portainer
    │   └── letsencrypt/            # Certificados SSL (gerado automaticamente)
    ├── containers/
    │   └── postgres/
    │       ├── docker-compose.yml
    │       └── .env                # Credenciais PostgreSQL (chmod 600)
    ├── ems/container/
    │   ├── docker-compose.prod.yml
    │   └── .env                    # Config EMS produção (chmod 600)
    ├── sms/container/
    │   ├── docker-compose.prod.yml
    │   └── .env                    # Config SMS produção (chmod 600)
    ├── update.sh
    └── rollback.sh
```

## Checklist de Produção

- [ ] Rede `ems_system_net` criada: `docker network create ems_system_net`
- [ ] `.env` do PostgreSQL configurado com senhas fortes
- [ ] `.env` do EMS configurado com credenciais de produção
- [ ] `.env` do SMS configurado com credenciais de produção
- [ ] Arquivos `.env` com permissão `600`: `chmod 600 .env`
- [ ] DNS apontando para IP da VPS:
  - `api.ems.edumigsoft.com.br` → IP da VPS
  - `api.sms.edumigsoft.com.br` → IP da VPS
  - `traefik.edumigsoft.com.br` → IP da VPS
  - `portainer.edumigsoft.com.br` → IP da VPS
- [ ] Portas 80 e 443 abertas no firewall da VPS
- [ ] `GITHUB_TOKEN` configurado (ver `SETUP_VPS.md`)
- [ ] Backup automático do PostgreSQL configurado (ver `containers/postgres/README.md`)

## Troubleshooting

### Verificar status de todos os serviços

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Verificar logs do Traefik (roteamento e TLS)

```bash
docker logs traefik -f
```

### Certificado SSL não emitido

```bash
# Verificar logs do Traefik para erros ACME
docker logs traefik 2>&1 | grep -i acme

# Verificar se DNS está propagado
nslookup api.ems.edumigsoft.com.br

# Verificar se porta 80 está acessível (necessária para HTTP challenge)
curl http://api.ems.edumigsoft.com.br/.well-known/acme-challenge/test
```

### Serviço não acessível pelo domínio

```bash
# Verificar se container está na rede correta
docker inspect ems_server_prod | grep -A 10 Networks

# Verificar labels Traefik no container
docker inspect ems_server_prod | grep -A 5 Labels

# Verificar rotas no dashboard do Traefik
# Acesse: https://traefik.edumigsoft.com.br
```

### Resetar certificados SSL (emergência)

```bash
cd servers/infra
docker compose down
rm -f letsencrypt/ems_system.json
docker compose up -d
```

## Referências

- [Traefik Docs](https://doc.traefik.io/traefik/)
- [Let's Encrypt](https://letsencrypt.org/)
- [PostgreSQL README](containers/postgres/README.md)
- [Scripts de Deploy](README.md)
- [Setup GITHUB_TOKEN](SETUP_VPS.md)
