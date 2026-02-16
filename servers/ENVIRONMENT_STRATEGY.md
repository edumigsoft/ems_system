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
cd servers/ems/container

# Opção 1: Usar valor do .env (ENVIRONMENT=development)
docker-compose up --build

# Opção 2: Override via linha de comando
ENVIRONMENT=development docker-compose up --build
```

**Resultado:** `"env": "development"`

---

### **Build para Staging/QA**

```bash
cd servers

# Build com ambiente staging
./build_production.sh ems 1.1.0-staging

# Ou manualmente:
docker build \
  --build-arg VERSION="1.1.0-staging" \
  --build-arg ENVIRONMENT="staging" \
  -t ems-server:1.1.0-staging \
  -f ems/container/Dockerfile \
  .
```

**Resultado:** `"env": "staging"`

---

### **Build para Produção**

```bash
cd servers

# Build com versão da pasta VERSION
./build_production.sh ems

# Ou especificar versão manualmente:
./build_production.sh ems 1.1.0

# Ou build manual:
docker build \
  --build-arg VERSION="1.1.0" \
  --build-arg ENVIRONMENT="production" \
  -t ems-server:1.1.0 \
  -f ems/container/Dockerfile \
  .
```

**Resultado:** `"env": "production"`

---

### **Push para GitHub Packages**

```bash
# 1. Tag a imagem para o registry
docker tag ems-server:1.1.0 ghcr.io/SEU_ORG/ems-server:1.1.0
docker tag ems-server:1.1.0 ghcr.io/SEU_ORG/ems-server:latest

# 2. Login no GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u SEU_USERNAME --password-stdin

# 3. Push
docker push ghcr.io/SEU_ORG/ems-server:1.1.0
docker push ghcr.io/SEU_ORG/ems-server:latest
```

**⚠️ Importante:** A imagem já contém `ENVIRONMENT=production` (definido no build). Não é necessário passar variável de ambiente no `docker run`.

---

### **Deploy em Produção**

```bash
# A imagem já vem com ENVIRONMENT=production
docker run -p 8080:8080 ghcr.io/SEU_ORG/ems-server:1.1.0

# Ou via docker-compose em produção:
services:
  ems_server:
    image: ghcr.io/SEU_ORG/ems-server:1.1.0
    # Não precisa definir ENVIRONMENT - já está no build
    environment:
      - DB_HOST=postgres
      - DB_PORT=5432
```

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
