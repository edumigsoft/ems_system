# Proposta: Ambiente de Desenvolvimento Local com Paridade de Produção

> **Status:** Proposta — aguardando implementação
> **Criado em:** 2026-02-21
> **Contexto:** Configurar desenvolvimento local usando a mesma stack de produção (Traefik + Docker + PostgreSQL), trocando apenas os domínios e o provedor TLS.

---

## Objetivo

Fazer o ambiente local espelhar a produção o máximo possível:

- Mesmo roteamento via Traefik
- Mesmos domínios (`.local` ao invés de `.edumigsoft.com.br`)
- HTTPS funcionando localmente (não só na VPS)
- Mesmo PostgreSQL, mesma rede Docker
- Imagens Docker construídas localmente (ao invés de puxadas do GHCR)

> **Observação:** O `dev.sh` já assume essa intenção — linha 124 tenta `https://ems.local/api/v1/health` antes de cair para `http://localhost:PORT`. A infraestrutura Traefik local é o elo faltante.

---

## Comparação: Produção × Desenvolvimento

| Componente | Produção | Desenvolvimento |
|---|---|---|
| Traefik TLS | Let's Encrypt (ACME automático) | `mkcert` (CA local) |
| EMS API | `api.ems.edumigsoft.com.br` | `api.ems.local` |
| SMS API | `api.sms.edumigsoft.com.br` | `api.sms.local` |
| Traefik Dashboard | `traefik.edumigsoft.com.br` | `traefik.local` |
| Portainer | `portainer.edumigsoft.com.br` | `portainer.local` |
| PostgreSQL (host interno) | `postgres_ems_system` | `postgres_ems_system` ← **igual** |
| Rede Docker | `ems_system_net` | `ems_system_net` ← **igual** |
| Imagens dos servidores | Pull de `ghcr.io` | Build local via `Dockerfile` |
| Auth dashboard Traefik | Basic Auth (htpasswd) | Pode remover (opcional) |
| Porta HTTP/HTTPS | 80 / 443 | 80 / 443 ← **igual** |
| Uploads (host path) | `/opt/ems_system/data/uploads/ems` | `servers/.dev-data/uploads/ems` |
| Logs (host path) | `/opt/ems_system/logs/ems` | `servers/.dev-data/logs/ems` |

---

## Estrutura de Pastas Local (Dev)

```
servers/
│
├── infra/
│   ├── docker-compose.yml          # prod (existente)
│   └── docker-compose.dev.yml      # DEV — NOVO (Traefik local + Portainer)
│       └── certs/                  # mkcert certificates (gitignored)
│           ├── local.pem
│           ├── local-key.pem
│           └── tls.yml             # file provider para Traefik
│
├── containers/
│   └── postgres/
│       ├── docker-compose.yml      # reutilizado igual em dev e prod
│       └── .env                    # credenciais locais (gitignored)
│
├── ems/
│   └── container/
│       ├── docker-compose.prod.yml # prod (existente, sem alteração)
│       ├── docker-compose.dev.yml  # AJUSTAR — adicionar labels Traefik + volumes
│       └── .env                    # config dev local (gitignored)
│
├── sms/
│   └── container/
│       ├── docker-compose.prod.yml # prod (existente, sem alteração)
│       ├── docker-compose.dev.yml  # AJUSTAR — adicionar labels Traefik + volumes
│       └── .env                    # config dev local (gitignored)
│
└── .dev-data/                      # NOVO — gitignored, dados persistentes de dev
    ├── uploads/
    │   ├── ems/
    │   └── sms/
    └── logs/
        ├── ems/
        └── sms/
```

---

## Parte 1 — DNS Local (`.local` domains)

### Opção A: `/etc/hosts` (simples, manual)

```
# Adicionar em /etc/hosts
127.0.0.1  api.ems.local
127.0.0.1  api.sms.local
127.0.0.1  traefik.local
127.0.0.1  portainer.local
```

**Prós:** zero dependências, funciona em qualquer OS.
**Contras:** precisa adicionar entrada manual para cada novo domínio.

### Opção B: `dnsmasq` (elegante, wildcard)

```bash
# Instalar (Ubuntu/Debian)
sudo apt install dnsmasq

# Configurar wildcard *.local → 127.0.0.1
echo "address=/.local/127.0.0.1" | sudo tee /etc/dnsmasq.d/local-dev.conf
sudo systemctl restart dnsmasq
```

**Prós:** qualquer subdomínio `.local` resolve automaticamente — sem editar `/etc/hosts` para novos serviços.
**Contras:** configuração inicial mais complexa; pode conflitar com mDNS.

> **Recomendação:** Opção A para começar (simples). Migrar para dnsmasq se o número de domínios crescer.

---

## Parte 2 — TLS Local (HTTPS com `mkcert`)

O `dev.sh` já usa `curl -k` (ignora erros de cert) e tenta HTTPS primeiro. Para ter HTTPS com certs confiáveis no browser:

### Instalar e configurar `mkcert`

```bash
# Ubuntu/Debian
sudo apt install libnss3-tools
curl -L https://github.com/FiloSottile/mkcert/releases/latest/download/mkcert-v*-linux-amd64 -o /usr/local/bin/mkcert
chmod +x /usr/local/bin/mkcert

# macOS
brew install mkcert

# Instalar CA local (uma vez por máquina)
mkcert -install
```

### Gerar certificados para os domínios locais

```bash
# Na raiz do projeto (ou em servers/infra/certs/)
mkdir -p servers/infra/certs

mkcert \
  -cert-file servers/infra/certs/local.pem \
  -key-file  servers/infra/certs/local-key.pem \
  api.ems.local \
  api.sms.local \
  traefik.local \
  portainer.local \
  localhost
```

### Arquivo de configuração do file provider do Traefik (`tls.yml`)

```yaml
# servers/infra/certs/tls.yml  — montado no container Traefik
tls:
  certificates:
    - certFile: /certs/local.pem
      keyFile: /certs/local-key.pem
```

> **Nota:** Os arquivos em `servers/infra/certs/` devem ser adicionados ao `.gitignore`.
> O `.env_example` ou README do `infra/` deve documentar o passo de geração.

---

## Parte 3 — `servers/infra/docker-compose.dev.yml` (NOVO)

Diferenças em relação ao `docker-compose.yml` (prod):

| Aspecto | Prod | Dev |
|---|---|---|
| Cert resolver | ACME (`ems_system_resolver`) | Removido |
| Volume letsencrypt | `./letsencrypt:/letsencrypt` | `./certs:/certs` |
| Redirecionamento HTTP→HTTPS | Sim | Sim (manter paridade) |
| File provider | Não | Sim (`/certs/tls.yml`) |
| Basic Auth dashboard | Sim (htpasswd) | Opcional (pode remover) |
| Regras de domínio | `*.edumigsoft.com.br` | `*.local` |

**Configurações Traefik dev a adicionar/remover:**

```yaml
# Adicionar (file provider para mkcert):
- "--providers.file.filename=/certs/tls.yml"

# Remover (ACME não existe localmente):
- "--certificatesresolvers.ems_system_resolver.acme.*"

# Manter igual:
- "--providers.docker=true"
- "--providers.docker.exposedbydefault=false"
- "--entrypoints.web.address=:80"
- "--entrypoints.websecure.address=:443"
- "--entrypoints.web.http.redirections.entryPoint.to=websecure"
```

---

## Parte 4 — `docker-compose.dev.yml` dos servidores (AJUSTES)

### Problemas atuais nos compose dev existentes

1. **EMS e SMS:** sem labels Traefik → não são roteados, só acessíveis via `localhost:PORT`
2. **SMS:** sem volumes de uploads/logs (ausentes no `docker-compose.dev.yml` atual)
3. **Paths de uploads/logs:** ainda usam `../../../uploads` (mesmo problema da VPS)

### Labels Traefik a adicionar em ambos os `docker-compose.dev.yml`

**Para EMS:**
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.ems-api-dev.rule=Host(`api.ems.local`)"
  - "traefik.http.routers.ems-api-dev.entrypoints=websecure"
  - "traefik.http.routers.ems-api-dev.tls=true"
  - "traefik.http.services.ems-api-dev.loadbalancer.server.port=${SERVER_PORT}"
```

**Para SMS:**
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.sms-api-dev.rule=Host(`api.sms.local`)"
  - "traefik.http.routers.sms-api-dev.entrypoints=websecure"
  - "traefik.http.routers.sms-api-dev.tls=true"
  - "traefik.http.services.sms-api-dev.loadbalancer.server.port=${SERVER_PORT}"
```

> **Observação:** Os nomes de router (`ems-api-dev`, `sms-api-dev`) devem ser diferentes dos de prod para não conflitar caso alguém rode prod e dev simultaneamente.

### Volumes a corrigir em ambos

```yaml
volumes:
  - ${UPLOADS_HOST_PATH:-../../.dev-data/uploads/ems}:${UPLOADS_CONTAINER_PATH:-/app/uploads}
  - ${LOGS_HOST_PATH:-../../.dev-data/logs/ems}:${LOGS_CONTAINER_PATH:-/app/logs}
```

---

## Parte 5 — `.env` de desenvolvimento

### `servers/ems/container/.env` (dev local)

```env
SERVER_PORT=8181

DB_HOST=postgres_ems_system
DB_PORT=5432
DB_NAME=ems_development
DB_USER=ems_user
DB_PASS=dev_password_ems

ENVIRONMENT=development

# Paths relativos à localização do docker-compose.dev.yml
# (servers/ems/container/docker-compose.dev.yml)
UPLOADS_HOST_PATH=../../.dev-data/uploads/ems
UPLOADS_CONTAINER_PATH=/app/uploads
LOGS_HOST_PATH=../../.dev-data/logs/ems
LOGS_CONTAINER_PATH=/app/logs

MAX_FILE_SIZE=50MB
ALLOWED_MIME_TYPES=application/pdf,image/jpeg,image/png
STORAGE_TYPE=local
```

### `servers/sms/container/.env` (dev local)

```env
SERVER_PORT=8080

DB_HOST=postgres_ems_system
DB_PORT=5432
DB_NAME=sms_development
DB_USER=sms_user
DB_PASS=dev_password_sms

ENVIRONMENT=development

UPLOADS_HOST_PATH=../../.dev-data/uploads/sms
UPLOADS_CONTAINER_PATH=/app/uploads
LOGS_HOST_PATH=../../.dev-data/logs/sms
LOGS_CONTAINER_PATH=/app/logs

MAX_FILE_SIZE=50MB
ALLOWED_MIME_TYPES=application/pdf,image/jpeg,image/png
STORAGE_TYPE=local
```

---

## Ordem de Inicialização Dev

```bash
# 1. Criar rede (uma vez)
docker network create ems_system_net

# 2. Criar diretórios de dados dev
mkdir -p servers/.dev-data/uploads/ems
mkdir -p servers/.dev-data/uploads/sms
mkdir -p servers/.dev-data/logs/ems
mkdir -p servers/.dev-data/logs/sms

# 3. Gerar certificados TLS (uma vez por máquina)
mkcert -install
mkcert -cert-file servers/infra/certs/local.pem \
       -key-file  servers/infra/certs/local-key.pem \
       api.ems.local api.sms.local traefik.local portainer.local localhost

# 4. Subir PostgreSQL (reutiliza o mesmo compose de prod)
cd servers/containers/postgres
docker compose up -d

# 5. Subir Traefik + Portainer dev
cd servers/infra
docker compose -f docker-compose.dev.yml up -d

# 6. Build e subir servidores (via dev.sh existente)
cd servers
./dev.sh ems
./dev.sh sms
```

---

## Diagrama de Funcionamento (Dev)

```
                     localhost (dev machine)
                              │
              ┌───────────────▼───────────────┐
              │  Traefik dev (80/443)          │
              │  TLS via mkcert (local CA)     │
              └──────┬──────────────┬──────────┘
                     │              │
         ┌───────────▼──┐  ┌────────▼──────────┐
         │  EMS Server  │  │   SMS Server      │
         │  (dev build) │  │   (dev build)     │
         │ api.ems.local│  │  api.sms.local    │
         └──────┬───────┘  └────────┬──────────┘
                │                   │
                └──────────┬────────┘
                           │
              ┌────────────▼────────────┐
              │  PostgreSQL 17 Alpine  │
              │  postgres_ems_system   │
              │  (mesmo container de   │
              │   sempre, reutilizado) │
              └─────────────────────────┘

       Rede Docker: ems_system_net (igual à produção)
```

---

## Arquivos a Criar/Modificar

### Novos arquivos

- [ ] `servers/infra/docker-compose.dev.yml` — Traefik dev (sem ACME, com file provider mkcert)
- [ ] `servers/infra/certs/tls.yml` — configuração TLS para file provider
- [ ] `servers/infra/certs/.gitignore` — ignorar `*.pem` e `*-key.pem`

### Arquivos a ajustar

- [ ] `servers/ems/container/docker-compose.dev.yml` — adicionar labels Traefik, corrigir volumes
- [ ] `servers/sms/container/docker-compose.dev.yml` — adicionar labels Traefik, **adicionar volumes** (atualmente ausentes!)
- [ ] `servers/ems/container/.env_example` — valores dev nos defaults (paths relativos)
- [ ] `servers/sms/container/.env_example` — idem
- [ ] `servers/.gitignore` — adicionar `.dev-data/` e `infra/certs/*.pem`

### Documentação

- [ ] Atualizar `servers/README.md` — incluir seção sobre setup de dev local
- [ ] `servers/infra/` — adicionar `README.md` com passo de geração do mkcert

---

## Considerações Finais

### O que é idêntico entre dev e prod
- Rede Docker (`ems_system_net`)
- Nome do container PostgreSQL (`postgres_ems_system`)
- Stack Traefik como proxy reverso
- Estrutura de roteamento (mesmo padrão de labels)
- Variáveis de ambiente (mesmos nomes, valores diferentes)

### O que difere intencionalmente
- Domínios (`.local` vs `.edumigsoft.com.br`)
- TLS provider (mkcert vs Let's Encrypt)
- Origem das imagens (build local vs pull GHCR)
- Banco de dados separado (`ems_development` vs `ems_production`)
- Paths de dados (`.dev-data/` vs `/opt/ems_system/data/`)

### Banco de dados dev vs prod
Recomendado usar databases separadas (`ems_development`, `sms_development`) dentro da mesma instância PostgreSQL local. Isso evita misturar dados de teste com dados reais e facilita recriar o banco de dev sem risco.
