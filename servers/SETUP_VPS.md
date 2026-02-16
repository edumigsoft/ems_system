# Setup de GITHUB_TOKEN na VPS

## Configuração Centralizada (Recomendado)

Para compartilhar o GITHUB_TOKEN entre múltiplos projetos:

### 1. Criar estrutura de secrets

```bash
# Na VPS
sudo mkdir -p /root/apps/.secrets
sudo chmod 700 /root/apps/.secrets
```

### 2. Criar arquivo de credenciais

```bash
sudo nano /root/apps/.secrets/github
```

Conteúdo:
```bash
# GitHub Container Registry Token
# Permissões: read:packages
export GITHUB_TOKEN=ghp_seu_token_aqui
```

### 3. Proteger o arquivo

```bash
sudo chmod 600 /root/apps/.secrets/github
sudo chown root:root /root/apps/.secrets/github
```

### 4. Validar

```bash
# Testar carregamento
source /root/apps/.secrets/github
echo "Token configurado: ${GITHUB_TOKEN:0:10}..."

# Testar login Docker
echo $GITHUB_TOKEN | docker login ghcr.io -u edumigsoft --password-stdin
```

## Uso Automático

O script `update.sh` carrega automaticamente de `/root/apps/.secrets/github` se existir.

## Alternativas

### Opção 1: Variável de ambiente por projeto
```bash
cd /path/servers/ems/container
echo 'GITHUB_TOKEN=ghp_seu_token_aqui' >> .env
chmod 600 .env
```

### Opção 2: Exportar na sessão
```bash
export GITHUB_TOKEN=ghp_seu_token_aqui
```

## Segurança

✅ **Fazer:**
- Usar permissões 600 (somente root pode ler)
- Criar token com escopo mínimo (`read:packages`)
- Usar tokens com expiração
- Rotacionar periodicamente

❌ **Evitar:**
- Nunca commitar no git
- Nunca usar permissões 644 ou 777
- Nunca compartilhar entre usuários sem necessidade

## Gerando Token no GitHub

1. Acesse: https://github.com/settings/tokens
2. Clique em "Generate new token" → "Generate new token (classic)"
3. Configure:
   - **Note**: "VPS Docker Pull - EMS/SMS"
   - **Expiration**: 90 days (ou conforme política)
   - **Scopes**: marque apenas `read:packages`
4. Clique em "Generate token"
5. **Importante**: Copie o token imediatamente (não será exibido novamente)
6. Salve em gerenciador de senhas (1Password, Bitwarden, etc)

## Estrutura Recomendada na VPS

```
/root/apps/
└── .secrets/                       # Credenciais compartilhadas
    ├── github                      # GITHUB_TOKEN (chmod 600)
    └── README.md                   # Documentação de uso

/caminho/ems_system/
└── servers/
    ├── update.sh                   # Carrega automaticamente de /root/apps/.secrets/github
    ├── ems/container/
    │   ├── docker-compose.prod.yml
    │   └── .env                    # Config específica do EMS
    └── sms/container/
        ├── docker-compose.prod.yml
        └── .env                    # Config específica do SMS
```

## Verificação

### Testar na VPS

```bash
# 1. Setup inicial
ssh user@vps
sudo mkdir -p /root/apps/.secrets
sudo nano /root/apps/.secrets/github  # Adicionar token
sudo chmod 600 /root/apps/.secrets/github

# 2. Testar update.sh
cd /path/servers
./update.sh ems  # Deve carregar token automaticamente

# 3. Verificar logs
# Deve mostrar: "Carregando GITHUB_TOKEN de /root/apps/.secrets/github"
# Não deve pedir token interativamente
```

### Validar segurança

```bash
# Na VPS
ls -la /root/apps/.secrets/github
# Esperado: -rw------- 1 root root ... /root/apps/.secrets/github

# Verificar conteúdo sem expor token
cat /root/apps/.secrets/github | grep "export GITHUB_TOKEN" | sed 's/=.*/=***/'
# Esperado: export GITHUB_TOKEN=***
```

## Troubleshooting

### Problema: "Permission denied"
```bash
# Solução: Ajustar permissões
sudo chmod 600 /root/apps/.secrets/github
sudo chown root:root /root/apps/.secrets/github
```

### Problema: "Login failed"
```bash
# Verificar se token está correto
source /root/apps/.secrets/github
echo $GITHUB_TOKEN | wc -c  # Deve ter ~41 caracteres

# Testar login manual
echo $GITHUB_TOKEN | docker login ghcr.io -u edumigsoft --password-stdin

# Se falhar, gerar novo token em: https://github.com/settings/tokens
```

### Problema: Script não carrega token
```bash
# Verificar se arquivo existe
ls -la /root/apps/.secrets/github

# Verificar conteúdo
cat /root/apps/.secrets/github

# Deve conter:
# export GITHUB_TOKEN=ghp_...
```

## Rotação de Token

Quando o token expirar ou precisar ser rotacionado:

```bash
# 1. Gerar novo token no GitHub (veja seção acima)

# 2. Atualizar na VPS
sudo nano /root/apps/.secrets/github
# Substituir valor do GITHUB_TOKEN

# 3. Testar
source /root/apps/.secrets/github
echo $GITHUB_TOKEN | docker login ghcr.io -u edumigsoft --password-stdin

# 4. (Opcional) Revogar token antigo em: https://github.com/settings/tokens
```

## Notas Importantes

1. **Escopo do Token**: O token em `/root/apps/.secrets/github` serve todos os projetos na VPS
2. **Permissões Mínimas**: Token deve ter apenas `read:packages` (não precisa write)
3. **Expiração**: Configurar expiração de 90 dias e rotacionar regularmente
4. **Backup**: Documentar o token em gerenciador de senhas (1Password, Bitwarden, etc)
5. **Revogação**: Se comprometido, revogar imediatamente em https://github.com/settings/tokens
