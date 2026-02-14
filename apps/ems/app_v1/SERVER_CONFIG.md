# Configuração de Servidor - EMS App v1

Este documento explica como configurar e alternar entre servidores local e remoto no aplicativo EMS.

## 📋 Visão Geral

O aplicativo permite alternar facilmente entre:
- **Servidor Local**: Para desenvolvimento (localhost)
- **Servidor Remoto**: Para acesso via rede/internet

As URLs são configuradas no arquivo `.env`, tornando simples alterar os endereços sem precisar recompilar o app.

## ⚙️ Configuração Inicial

### 1. Editar o arquivo `.env`

Abra o arquivo `.env` na raiz do app (`apps/ems/app_v1/.env`) e configure as URLs:

```bash
# Servidor Local (desenvolvimento)
BACKEND_BASE_URL=http://localhost:8181

# Servidor Remoto (rede/internet)
BACKEND_REMOTE_URL=http://192.168.0.100:8181

# Caminho da API (comum para ambos)
BACKEND_PATH_API=/api/v1
```

### 2. Exemplos de URLs

**Servidor Local:**
```bash
BACKEND_BASE_URL=http://localhost:8181
```

**Servidor Remoto (IP da rede local):**
```bash
BACKEND_REMOTE_URL=http://192.168.0.100:8181
```

**Servidor Remoto (domínio):**
```bash
BACKEND_REMOTE_URL=https://api.exemplo.com
```

**Servidor Remoto (ngrok/túnel):**
```bash
BACKEND_REMOTE_URL=https://abc123.ngrok.io
```

### 3. Gerar arquivos de configuração

Após editar o `.env`, execute:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Isso irá gerar o arquivo `lib/config/env/env.g.dart` com as novas configurações.

## 🎯 Como Usar no App

### Alternar entre Servidores

1. **Abra o aplicativo**
2. **Navegue até Configurações** (⚙️)
3. **Encontre a seção "Conexão"**
4. **Toque em "Servidor"**
5. **Selecione:**
   - **Servidor Local**: Usa `BACKEND_BASE_URL` do `.env`
   - **Servidor Remoto**: Usa `BACKEND_REMOTE_URL` do `.env`
6. **Reinicie o app** para aplicar as alterações

### Fluxo Visual

```
Configurações
  └─ Conexão
       └─ Servidor: [Servidor Local ▼]
            ├─ ○ Servidor Local (localhost)
            └─ ○ Servidor Remoto (Internet/Rede)
```

## 🔄 Mudando URLs

### Para alterar a URL do servidor remoto:

1. **Edite o arquivo `.env`:**
   ```bash
   BACKEND_REMOTE_URL=http://SEU_NOVO_IP:8181
   ```

2. **Regenere as configurações:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Reinicie o app**

✅ **Não precisa digitar nada no app!** Tudo é configurado pelo `.env`.

## 💾 Persistência

- A escolha do servidor (Local/Remoto) é **salva automaticamente**
- Usa **FlutterSecureStorage** (armazenamento criptografado)
- Funciona em **todos os ambientes**:
  - ✅ Android
  - ✅ iOS
  - ✅ Windows
  - ✅ Linux
  - ✅ macOS
  - ✅ Web

## 🔍 Logs

Ao iniciar o app, você verá nos logs qual servidor está sendo usado:

```
[INFO] Using local server: http://localhost:8181/api/v1
```

ou

```
[INFO] Using remote server: http://192.168.0.100:8181/api/v1
```

## 📝 Exemplo Completo

### Cenário: Desenvolvimento local, depois deploy

**1. Durante desenvolvimento (.env):**
```bash
BACKEND_BASE_URL=http://localhost:8181
BACKEND_REMOTE_URL=http://192.168.0.100:8181
BACKEND_PATH_API=/api/v1
```

**2. No app:**
- Use "Servidor Local" durante desenvolvimento
- Troque para "Servidor Remoto" quando quiser testar em outro dispositivo na rede

**3. Para produção (.env):**
```bash
BACKEND_BASE_URL=http://localhost:8181
BACKEND_REMOTE_URL=https://api.producao.com
BACKEND_PATH_API=/api/v1
```

**4. Regenere e redistribua:**
```bash
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release
```

## 🛠️ Troubleshooting

### O app não conecta ao servidor remoto

1. **Verifique se o `.env` está correto**
2. **Regenere com build_runner**
3. **Reinicie o app completamente**
4. **Verifique os logs** para ver qual URL está sendo usada

### Erro "Failed to load server settings"

- O app usará o servidor local por padrão
- Verifique se a permissão de storage está habilitada

### Preciso digitar a URL manualmente?

❌ **Não!** Todas as URLs são configuradas no `.env`. Isso facilita:
- Mudanças rápidas sem recompilar
- Controle de versão
- Diferentes configurações por ambiente

## 📦 Arquivos Relacionados

- **Configuração**: `apps/ems/app_v1/.env`
- **Entidade**: `packages/user/user_shared/lib/src/domain/entities/user_settings.dart`
- **ViewModel**: `packages/user/user_ui/lib/view_models/settings_view_model.dart`
- **UI**: `packages/user/user_ui/lib/pages/settings_page.dart`
- **Injeção**: `apps/ems/app_v1/lib/config/di/injector.dart`
- **Dio Factory**: `apps/ems/app_v1/lib/config/network/dio_factory.dart`

## 🎓 Boas Práticas

1. ✅ **Sempre comite o `.env_example`** com URLs de exemplo
2. ✅ **Nunca comite o `.env`** com URLs reais de produção
3. ✅ **Use URLs HTTPS** em produção
4. ✅ **Teste a conexão** após mudar de servidor
5. ✅ **Mantenha logs habilitados** durante desenvolvimento

---

**Versão**: 1.1.0
**Última atualização**: 2026-02-14
