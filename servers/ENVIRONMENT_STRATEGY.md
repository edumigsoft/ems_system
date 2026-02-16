# Estratégia de Ambientes (Development → Production)

Este documento descreve como o sistema gerencia diferentes ambientes (development, staging, production) de forma automática.

## 🎯 Objetivo

Eliminar alterações manuais de código ao mudar entre ambientes. O valor de `env` no endpoint `/health` é determinado automaticamente por variáveis de ambiente.

## 🏗️ Arquitetura

### 1. Código (`HealthRoutes`)
```dart
// Lê automaticamente de variáveis de ambiente
_environment = environment ??
    Platform.environment['ENV'] ??
    Platform.environment['ENVIRONMENT'] ??
    'development'; // fallback seguro
```

**Prioridade de leitura:**
1. Parâmetro explícito no construtor
2. Variável `ENV`
3. Variável `ENVIRONMENT`
4. Fallback: `'development'`

### 2. Dockerfile

```dockerfile
# Build ARGs permitem passar valores durante o build
ARG VERSION=unknown
ARG ENVIRONMENT=production  # Default para produção

# ENVs ficam disponíveis no runtime
ENV APP_VERSION=$VERSION
ENV ENV=$ENVIRONMENT
```

### 3. Docker Compose (Desenvolvimento)

```yaml
build:
  args:
    VERSION: ${VERSION:-dev}
    ENVIRONMENT: ${ENVIRONMENT:-development}  # Override para dev
environment:
  - ENV=${ENVIRONMENT:-development}
```

### 4. Arquivo `.env` (Local)

```bash
# Ambiente da aplicação
ENVIRONMENT=development  # ou staging, production
```

## 📋 Uso por Cenário

### **Desenvolvimento Local**

```bash
cd servers
./dev.sh ems          # Build + test + health check (development)
./dev.sh ems -f       # Com logs em tempo real
```

**O que acontece:**
- Build com `ENVIRONMENT=development`
- Health check automático
- Validação de versão e environment

**Resultado:** `"env": "development"`

---

### **Build e Publicação para GitHub Packages**

```bash
cd servers
export GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXX
./publish.sh ems      # Build production + push GHCR
./publish.sh ems 1.2.0  # Versão específica
```

**O que acontece:**
1. Build com `ENVIRONMENT=production`
2. Login no GHCR
3. Criação de 3 tags:
   - `ghcr.io/edumigsoft/ems-server:1.1.3` (versão completa)
   - `ghcr.io/edumigsoft/ems-server:v1.1` (major.minor)
   - `ghcr.io/edumigsoft/ems-server:latest`
4. Push automático para GHCR

**Resultado:** Imagem no GHCR com `"env": "production"` hardcoded

---

### **Deploy em Produção (VPS)**

```bash
# SSH na VPS
ssh user@vps
cd /path/servers

# Deploy versão específica (RECOMENDADO para produção)
./update.sh ems 1.1.3         # Pull :1.1.3 (imutável)

# Deploy série (staging/QA)
./update.sh ems v1.1          # Pull :v1.1 (recebe patches)

# Deploy latest (dev/test)
./update.sh ems               # Pull :latest (pode mudar)
```

**Importante:** VPS **não faz build**. A imagem já vem pronta do GHCR com `ENVIRONMENT=production` hardcoded.

**Recomendação:** Use versão **específica** (`:1.1.3`) em produção para garantir reprodutibilidade.

**Resultado:** Container rodando com `"env": "production"`

### **Estratégias de Versionamento por Ambiente**

| Ambiente | Tag Recomendada | Motivo | Comando |
|----------|----------------|--------|---------|
| **Produção Estável** | `:1.1.3` (fixa) | Imutável, reproduzível | `./update.sh ems 1.1.3` |
| **Staging/QA** | `:v1.1` (série) | Recebe patches automaticamente | `./update.sh ems v1.1` |
| **Desenvolvimento VPS** | `:latest` | Sempre testa a mais nova | `./update.sh ems` |

### **Rollback em Emergências**

```bash
cd /path/servers

# Rollback para versão anterior
./rollback.sh ems 1.1.2       # Volta para 1.1.2
```

**O que acontece:**
1. Confirmação obrigatória
2. Pull da versão anterior do GHCR
3. Restart do container
4. Health check pós-rollback

---

### **Build para Staging/QA (Manual)**

Se necessário build manual para staging:

```bash
cd /path/to/project_root

docker build \
  --build-arg VERSION="1.1.0-staging" \
  --build-arg ENVIRONMENT="staging" \
  -t ems-server:1.1.0-staging \
  -f servers/ems/container/Dockerfile \
  .
```

**Resultado:** `"env": "staging"`

---

## 🔍 Verificação

Teste o endpoint de health:

```bash
curl http://localhost:8080/api/v1/health
```

**Resposta esperada:**
```json
{
  "status": "OK",
  "timestamp": "2024-02-16T10:30:00.000Z",
  "uptime": "since startup",
  "env": "production",  // ← Automático baseado na ENV
  "version": "1.1.0"
}
```

---

## 📊 Comparação de Estratégias

| Estratégia | Vantagens | Desvantagens |
|-----------|-----------|--------------|
| **Variáveis de Ambiente** ✅ (escolhida) | • Sem alteração de código<br>• Suporte Docker nativo<br>• Segue 12-factor app<br>• Fácil de testar | • Requer configuração correta<br>• Pode falhar se não definida (mitigado por fallback) |
| Arquivos de config | • Centralizado<br>• Versionável | • Código precisa ler arquivo<br>• Pode ser commitado por engano |
| Hardcoded | • Simples | • ❌ Requer mudar código<br>• ❌ Propício a erros |
| Build-time flag | • Compilado na imagem | • ❌ Requer rebuild para trocar ambiente |

---

## 🛠️ Solução de Problemas

### Problema: Endpoint retorna `"env": "development"` em produção

**Causa:** Variável `ENV` ou `ENVIRONMENT` não foi definida no build.

**Solução:**
```bash
# Rebuild com build arg correto
docker build --build-arg ENVIRONMENT=production ...
```

### Problema: Variável não está sendo lida

**Debug:**
```bash
# Inspecionar variáveis de ambiente dentro do container
docker run --rm ems-server:latest sh -c 'env | grep ENV'

# Resultado esperado:
# ENV=production
# APP_VERSION=1.1.0
```

---

## 📚 Referências

- [12-Factor App - Config](https://12factor.net/config)
- [Dockerfile ARG vs ENV](https://docs.docker.com/engine/reference/builder/#arg)
- [Docker Build Args](https://docs.docker.com/engine/reference/commandline/build/#build-arg)

---

## ✅ Checklist de Deployment

- [ ] Código lê `Platform.environment['ENV']`
- [ ] Dockerfile define `ARG ENVIRONMENT=production`
- [ ] Build usa `--build-arg ENVIRONMENT=production`
- [ ] Imagem testada localmente com `docker run`
- [ ] Endpoint `/health` retorna `"env": "production"`
- [ ] Imagem taggeada para registry
- [ ] Push para GitHub Packages concluído
- [ ] Deploy em servidor de produção testado
