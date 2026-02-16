# Scripts de Build e Deploy

## Comandos Rápidos

### 🔧 Desenvolvimento Local
```bash
./dev.sh ems          # Build dev + test
./dev.sh sms          # Build SMS dev + test
./dev.sh ems -f       # Build com logs em tempo real
```

### 📦 Publicar para Produção
```bash
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX
./publish.sh ems      # Build production + push GHCR
./publish.sh sms 1.2.0  # Versão específica
```

### 🚀 Deploy em VPS (via SSH)
```bash
cd servers
./update.sh ems              # Pull :latest (padrão)
./update.sh ems 1.1.3        # Pull versão específica
./update.sh ems v1.1         # Pull série 1.1.x
```

### ⏮️ Rollback (Emergência)
```bash
cd servers
./rollback.sh ems            # Solicita versão interativamente
./rollback.sh ems 1.1.2      # Rollback para versão específica
```

## Estrutura

**PC Local (Build):**
- `dev.sh` - Desenvolvimento local (build dev + test + health check)
- `publish.sh` - Publicação GHCR (build production + push)

**VPS (Deploy - SEM BUILD):**
- `update.sh` - Pull imagem do GHCR + restart (centralizado para EMS e SMS)
- `rollback.sh` - Rollback em VPS (centralizado para EMS e SMS)

**Importante:** Build **sempre** acontece no PC. VPS apenas faz pull da imagem pronta do GHCR.

## Estratégias de Versionamento

| Ambiente | Tag Recomendada | Motivo | Comando |
|----------|----------------|--------|---------|
| **Produção Estável** | `:1.1.3` (fixa) | Imutável, reproduzível | `./update.sh ems 1.1.3` |
| **Staging/QA** | `:v1.1` (série) | Recebe patches automaticamente | `./update.sh ems v1.1` |
| **Desenvolvimento VPS** | `:latest` | Sempre testa a mais nova | `./update.sh ems` |

## Fluxo de Trabalho

```
┌─────────────────────────────────────────────────────────────┐
│                    PC LOCAL (Desenvolvimento)               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Desenvolvimento e Testes                                │
│     ./dev.sh ems                                            │
│     → Build com ENVIRONMENT=development                     │
│     → Health check automático                               │
│     → Logs em tempo real (opcional -f)                      │
│                                                             │
│  2. Validação OK → Publicar                                 │
│     export GITHUB_TOKEN=ghp_XXX                             │
│     ./publish.sh ems                                        │
│     → Build com ENVIRONMENT=production                      │
│     → Push para GHCR (3 tags: version, major.minor, latest) │
│     → Confirmação antes do push                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          ↓
                    GITHUB PACKAGES
                    (Container Registry)
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                    VPS (Produção)                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  3. Deploy (Pull da imagem pronta)                          │
│     ssh user@vps                                            │
│     cd /path/servers                                        │
│     ./update.sh ems                    # :latest (padrão)   │
│     ./update.sh ems 1.1.3              # versão específica  │
│     ./update.sh ems v1.1               # série 1.1.x        │
│     → Pull imagem do GHCR (SEM BUILD)                       │
│     → Restart container                                     │
│     → Health check automático                               │
│                                                             │
│  4. Rollback (se necessário)                                │
│     ./rollback.sh ems 1.1.2                                 │
│     → Volta para versão anterior                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Detalhes dos Scripts

### `dev.sh <ems|sms> [--follow-logs|-f]`

**Propósito:** Desenvolvimento local com testes automatizados

**O que faz:**
1. ✅ Para container anterior
2. ✅ Build com `ENVIRONMENT=development`
3. ✅ Sobe container via docker-compose
4. ✅ Aguarda 5s e faz health check automático
5. ✅ Valida versão e environment
6. ✅ Exibe logs recentes (últimas 30 linhas)
7. ✅ Opcional: seguir logs em tempo real (-f)

**Exemplo:**
```bash
./dev.sh ems          # Build + test EMS
./dev.sh sms -f       # Build + test SMS com logs
```

**Health check testado automaticamente:**
- `https://ems.local/api/v1/health`
- `http://localhost:8181/api/v1/health`

---

### `publish.sh <ems|sms> [version]`

**Propósito:** Build production e publicação no GHCR

**O que faz:**
1. ✅ Lê versão do `pubspec.yaml` (ou usa argumento)
2. ✅ Solicita confirmação do usuário
3. ✅ Build com `ENVIRONMENT=production`
4. ✅ Login no GHCR (via `GITHUB_TOKEN`)
5. ✅ Cria 3 tags:
   - `ghcr.io/edumigsoft/ems-server:1.1.3` (versão completa)
   - `ghcr.io/edumigsoft/ems-server:v1.1` (major.minor)
   - `ghcr.io/edumigsoft/ems-server:latest`
6. ✅ Push das 3 tags para GHCR
7. ✅ Exibe instruções de deploy para VPS

**Pré-requisitos:**
```bash
# Criar token em: https://github.com/settings/tokens
# Permissões: read:packages, write:packages
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX
```

**Exemplo:**
```bash
./publish.sh ems           # Usa versão do pubspec.yaml
./publish.sh sms 1.2.0-beta  # Versão específica
```

---

### `update.sh <ems|sms> [version]`

**Propósito:** Deploy em VPS (pull + restart, **SEM BUILD**)

**Sintaxe:**
```bash
./update.sh <ems|sms> [version]
```

**Argumentos:**
- `<ems|sms>`: Servidor a atualizar (obrigatório)
- `[version]`: Tag da imagem (opcional, default: `latest`)
  - `latest` - Sempre a mais nova (padrão)
  - `v1.1` - Última versão da série 1.1.x
  - `1.1.3` - Versão específica

**O que faz:**
1. ✅ Solicita `GITHUB_TOKEN` se não configurado
2. ✅ Login no GHCR
3. ✅ Pull da tag especificada do GHCR
4. ✅ Confirmação para versões específicas (não latest)
5. ✅ Restart container com `IMAGE_TAG` dinâmico
6. ✅ Health check automático
7. ✅ Exibe status e logs

**Exemplos:**
```bash
ssh user@vps
cd /path/servers

# Deploy latest (padrão)
./update.sh ems

# Deploy versão específica (produção)
./update.sh ems 1.1.3

# Deploy série (staging/QA)
./update.sh ems v1.1
```

**Nota:** Este script **não faz build**. A imagem já vem pronta do GHCR com `ENVIRONMENT=production` hardcoded.

---

### `rollback.sh <ems|sms> [version]`

**Propósito:** Reverter para versão anterior em emergências

**Sintaxe:**
```bash
./rollback.sh <ems|sms> [version]
```

**Argumentos:**
- `<ems|sms>`: Servidor a fazer rollback (obrigatório)
- `[version]`: Versão anterior (opcional, será solicitada interativamente)

**O que faz:**
1. ✅ Solicita versão se não especificada
2. ✅ Exibe versão atual (se possível)
3. ✅ Confirmação OBRIGATÓRIA
4. ✅ Executa `update.sh` internamente com versão anterior
5. ✅ Validação pós-rollback via health check

**Exemplos:**
```bash
cd servers

# Rollback interativo
./rollback.sh ems

# Rollback direto
./rollback.sh ems 1.1.2
```

## Variáveis de Ambiente

### ENVIRONMENT

**Desenvolvimento (`dev.sh`):**
- Build: `docker-compose build --build-arg ENVIRONMENT=development`
- Runtime: `ENV=development` (via docker-compose.yml)
- Health: `"env": "development"`

**Produção (`publish.sh` + VPS):**
- Build: `docker build --build-arg ENVIRONMENT=production`
- Runtime: `ENV=production` (hardcoded no Dockerfile)
- Health: `"env": "production"`

### GITHUB_TOKEN

Necessário para:
- ✅ `publish.sh` - Push para GHCR
- ✅ `update.sh` (VPS) - Pull do GHCR

**Configurar:**
```bash
# Temporário (sessão atual)
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX

# Permanente (adicionar ao ~/.bashrc ou ~/.zshrc)
echo 'export GITHUB_TOKEN=ghp_XXX' >> ~/.bashrc
```

**Criar token:**
1. Acesse: https://github.com/settings/tokens
2. Clique em "Generate new token (classic)"
3. Selecione permissões: `read:packages`, `write:packages`
4. Copie o token (começa com `ghp_`)

## Verificação de Saúde (Health Check)

Todos os scripts fazem health check automático:

```bash
# Local (desenvolvimento)
curl -k https://ems.local/api/v1/health
curl http://localhost:8181/api/v1/health

# VPS (produção)
curl https://ems.production.com/api/v1/health
```

**Resposta esperada:**
```json
{
  "status": "OK",
  "timestamp": "2026-02-16T16:10:07.401998",
  "uptime": "since startup",
  "env": "development",  // ou "production" na VPS
  "version": "1.1.3"
}
```

## Solução de Problemas

### Health check falha no dev.sh

**Problema:** `Servidor não respondeu em nenhuma URL`

**Soluções:**
1. Verificar logs: `cd servers/{ems,sms}/container && docker compose logs`
2. Verificar porta no `.env`: `SERVER_PORT=8181`
3. Verificar rede Docker: `docker network ls`
4. Verificar certificado self-signed (usar curl -k)

### Login GHCR falha

**Problema:** `Falha no login GHCR`

**Soluções:**
1. Verificar token: `echo $GITHUB_TOKEN`
2. Verificar permissões do token: `read:packages`, `write:packages`
3. Criar novo token: https://github.com/settings/tokens
4. Testar login manual:
   ```bash
   echo $GITHUB_TOKEN | docker login ghcr.io -u edumigsoft --password-stdin
   ```

### Build falha no publish.sh

**Problema:** Erro durante build production

**Soluções:**
1. Verificar espaço em disco: `df -h`
2. Limpar builds antigos: `docker system prune -a`
3. Verificar Dockerfile: `servers/{ems,sms}/container/Dockerfile`
4. Testar build manual:
   ```bash
   docker build -f servers/ems/container/Dockerfile \
     --build-arg VERSION=1.1.3 \
     --build-arg ENVIRONMENT=production \
     -t test .
   ```

## Documentação Completa

- [ENVIRONMENT_STRATEGY.md](ENVIRONMENT_STRATEGY.md) - Estratégia de ambientes
- [INFRASTRUCTURE.md](INFRASTRUCTURE.md) - Infraestrutura Docker completa
- [../ARCHITECTURE.md](../ARCHITECTURE.md) - Arquitetura do sistema
