# Documentação de Infraestrutura Docker (EMS System)

Este documento detalha a arquitetura de contêineres para o ecossistema `ems_system`. O sistema utiliza uma arquitetura de **Serviços Compartilhados** (Shared Services), onde uma única instância de banco de dados atende a múltiplos servidores Dart (EMS, SMS, etc.) através de uma rede Docker interna.

## 1. Visão Geral da Arquitetura

* **Database:** PostgreSQL 15 (Alpine) rodando isolado.
* **Backends:** Servidores Dart/Shelf rodando em imagens *scratch* (compilação AOT).
* **Rede:** Uma `docker network` externa conecta todos os serviços.
* **Segurança:** Cada aplicação possui seu próprio usuário e banco de dados com credenciais distintas.

---

## 2. Pré-requisito Obrigatório (Rede)

Antes de subir qualquer contêiner, é **obrigatório** criar a rede compartilhada. Sem isso, os serviços não conseguirão se comunicar.

Execute no terminal:

```bash
docker network create ems_system_net

```

---

## 3. Estrutura de Diretórios

```text
ems_system/
├── servers/
│   ├── containers/             # Infraestrutura Global
│   │   ├── postgres/           # Banco de Dados
│   │   │   ├── docker-compose.yml
│   │   │   ├── .env
│   │   │   └── init_users.sh
│   │   │
│   │   └── proxy/              # Nginx Proxy Manager (Novo)
│   │       └── docker-compose.yml
│   │
│   ├── ems/
│   │   ├── server_v1/          # Código Fonte Dart
│   │   └── container/          # Docker do EMS
│   │       ├── Dockerfile
│   │       ├── docker-compose.yml
│   │       └── .env
│   │
│   └── sms_server/
│       ├── server_v1/          # Código Fonte Dart
│       └── container/          # Docker do SMS
│           ├── Dockerfile
│           ├── docker-compose.yml
│           └── .env            # Credenciais APENAS do SMS

```

---

## 4. Configuração do Banco de Dados (Postgres)

O banco de dados é o "coração" da infraestrutura e deve ser iniciado primeiro.

**Local:** `servers/containers/postgres/`

### Funcionalidades

*   Utiliza um script `.sh` (`init_users.sh`) mapeado para `/docker-entrypoint-initdb.d/`.
*   Este script roda apenas na **primeira execução** (quando o volume está vazio).
*   Lê as variáveis do `.env` para criar os bancos `db_ems`, `db_sms` e seus respectivos usuários automaticamente.

### Comandos de Operação

**Iniciar:**

```bash
cd servers/containers/postgres/
docker compose up -d

```

**Resetar (Apagar tudo e recriar):**
*Atenção: Isso apaga todos os dados! Necessário se você alterou senhas ou usuários no script de inicialização.*

```bash
docker compose down
docker volume rm postgres_postgres_data  # Verifique o nome correto com 'docker volume ls'
docker compose up -d

```

---

## 5. Configuração dos Servidores (EMS / SMS)

Os servidores são compilados em Dart e rodam em contêineres mínimos.

**Local:** `servers/ems/container/` ou `servers/sms_server/container/`

### O Dockerfile (Destaques)

*   **Build Context:** O `docker-compose.yml` define o contexto na raiz (`../../..`).
*   **Cópia de Pacotes:** Copia a pasta `packages/` para garantir que dependências locais (shared) estejam disponíveis.
*   **Isolamento:** Executa um comando `sed` para remover `resolution: workspace` do `pubspec.yaml`, permitindo compilação isolada sem o Flutter.
*   **Conexão DB:** Utiliza `Platform.environment` no Dart para ler as variáveis injetadas.

### Configuração de Rede (`docker-compose.yml`)

Todos os serviços de aplicação devem declarar a rede externa no final do arquivo:

```yaml
networks:
  ems_system_net:
    external: true

```

### Variáveis de Ambiente (`.env`)

No servidor, `DB_HOST` deve apontar para o **nome do serviço** do banco definido na rede:

```ini
DB_HOST=postgres_shared_db
DB_PORT=5432

```

### Comandos de Operação

**Iniciar (com Build):**

```bash
cd servers/ems/container/
docker compose up -d --build

```

**Verificar Logs:**

```bash
docker logs -f ems_server_app

```

---

## 6. Acesso Externo (DBeaver / PgAdmin)

O banco de dados expõe a porta `5432` para o host.

*   **Host:** `localhost` (ou IP da VPS)
*   **Porta:** `5432`
*   **Database:** `postgres_admin`, `db_ems` ou `db_sms`
*   **Username/Password:** Conforme definido no arquivo `.env` da pasta `postgres`.

---

---

## 6. Ambiente Local com HTTPS (Nginx Proxy Manager)

Para simular o ambiente de produção (VPS) e ter SSL localmente:

1.  **Iniciar o Proxy:**

    ```bash
    cd servers/containers/proxy/
    docker compose up -d
    ```

2.  **Configurar:**
    *   Acesse `http://localhost:81`
    *   Login padrão: `admin@example.com` / `changeme`
    *   Altere as credenciais conforme solicitado.

3.  **Criar Proxy Host:**
    *   Navegue para **Hosts** > **Proxy Hosts** > **Add Proxy Host**.
    *   **Details:**
        *   Domain Names: `localhost` (ou `ems.local` se configurado no `/etc/hosts`)
        *   Scheme: `http`
        *   Forward Hostname / IP: `ems_server_dev` (nome do container na rede interna)
        *   Forward Port: `8181`
        *   Cache Assets: Enable (opcional)
        *   Block Common Exploits: Enable (opcional)
    *   **SSL:**
        *   SSL Certificate: *Request a new SSL Certificate*
        *   Force SSL: Enable
        *   HTTP/2 Support: Enable
        *   *Nota:* Para `localhost`, o Let's Encrypt pode falhar. Use "Self Signed" se disponível ou apenas HTTP na porta 80 para testes simples, mas para simular SSL real, recomenda-se configurar um domínio local no `/etc/hosts` e gerar um certificado self-signed dentro do container ou importá-lo.
    *   Save.

4.  **Acessar:**
    *   Acesse `https://localhost` (ou o domínio configurado).
    *   A API estará disponível com terminação SSL gerenciada pelo Nginx.

---

## 7. Solução de Problemas Comuns

| Erro | Causa Provável | Solução |
| --- | --- | --- |
| `Network ems_system_net not found` | A rede não foi criada manualmente. | Rode `docker network create ems_system_net`. |
| `Connection Refused (localhost)` | A app está tentando conectar no próprio container. | Verifique se o código Dart usa `Platform.environment['DB_HOST']` e se o `.env` aponta para `postgres_ems_system`. |
| `database files are incompatible` | Tentativa de rodar Postgres 15 em volume criado por versão 17. | Apague o volume do Docker (`docker volume rm`) e inicie novamente. |
| `Fatal: password authentication failed` | O volume antigo persistiu senhas antigas. | Apague o volume do Docker e inicie novamente para rodar o script de usuários com as novas senhas. |