# PostgreSQL Container - EMS System

Container PostgreSQL 17 Alpine compartilhado para EMS e SMS, configurado para rodar em VPS com rede Docker compartilhada (nginx proxy reverso).

## Arquitetura

- **Container**: Uma instância PostgreSQL compartilhada
- **Rede**: `ems_system_net` (externa, compartilhada com nginx e outros serviços)
- **Acesso**: Apenas via rede interna Docker (sem exposição de portas públicas)
- **Persistência**: Um volume Docker único (`postgres_ems_system_data`)
- **Databases**: Múltiplas databases isoladas (EMS, SMS, etc.) no mesmo PostgreSQL
- **Healthcheck**: Verificação automática de saúde do container

### Por que um container ao invés de múltiplos?

✅ **Eficiência de recursos**: ~40-80MB RAM por container economizado
✅ **Gerenciamento simples**: Um único ponto de administração
✅ **Backup/Restore flexível**: `pg_dump`/`pg_restore` por database individual
✅ **Isolamento lógico**: Databases separadas com usuários e permissões distintas

## Deployment no VPS

### 1. Criar rede Docker (se ainda não existir)

```bash
docker network create ems_system_net
```

### 2. Copiar arquivos para o VPS

```bash
# No VPS
mkdir -p /opt/ems_system/postgres
cd /opt/ems_system/postgres

# Copiar apenas:
# - docker-compose.yml
# - .env (criar com credenciais de produção)
```

### 3. Configurar variáveis de ambiente

```bash
nano .env
```

Exemplo de `.env` para produção:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=SuaSenhaSuperForte123!@#
POSTGRES_DB=postgres
```

⚠️ **Importante**: Use senha forte e única em produção!

### 4. Subir o container

```bash
docker-compose up -d
```

### 5. Verificar status

```bash
docker-compose ps
docker-compose logs -f
docker exec postgres_ems_system pg_isready -U postgres
```

## Configuração inicial de Databases

Após subir o container, crie as databases e usuários:

```bash
# Acessar o PostgreSQL
docker exec -it postgres_ems_system psql -U postgres
```

```sql
-- Database e usuário EMS
CREATE DATABASE ems_production;
CREATE USER ems_user WITH PASSWORD 'senha_forte_ems_unica';
GRANT ALL PRIVILEGES ON DATABASE ems_production TO ems_user;

-- Conectar e configurar permissões
\c ems_production
GRANT ALL ON SCHEMA public TO ems_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ems_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ems_user;

-- Database e usuário SMS
\c postgres
CREATE DATABASE sms_production;
CREATE USER sms_user WITH PASSWORD 'senha_forte_sms_unica';
GRANT ALL PRIVILEGES ON DATABASE sms_production TO sms_user;

\c sms_production
GRANT ALL ON SCHEMA public TO sms_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO sms_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO sms_user;

-- Verificar databases criadas
\l

-- Sair
\q
```

## Acesso pelos servidores EMS/SMS

Configuração de conexão para servidores Dart/Shelf:

```dart
// Servidor EMS
final connection = PostgreSQLConnection(
  'postgres_ems_system',  // Nome do container na rede Docker
  5432,                   // Porta interna
  'ems_production',       // Database
  username: 'ems_user',
  password: env['EMS_DB_PASSWORD'],
);

// Servidor SMS
final connection = PostgreSQLConnection(
  'postgres_ems_system',  // Mesmo container
  5432,
  'sms_production',       // Database diferente
  username: 'sms_user',
  password: env['SMS_DB_PASSWORD'],
);
```

## Backup e Restore (por database)

### Backup individual de database

```bash
# Backup EMS
docker exec postgres_ems_system pg_dump -U postgres -d ems_production \
  > backup_ems_$(date +%Y%m%d_%H%M%S).sql

# Backup SMS
docker exec postgres_ems_system pg_dump -U postgres -d sms_production \
  > backup_sms_$(date +%Y%m%d_%H%M%S).sql

# Backup compactado (economiza espaço)
docker exec postgres_ems_system pg_dump -U postgres -d ems_production \
  | gzip > backup_ems_$(date +%Y%m%d_%H%M%S).sql.gz
```

### Restore individual de database

```bash
# Restore EMS
cat backup_ems.sql | docker exec -i postgres_ems_system \
  psql -U postgres -d ems_production

# Restore compactado
gunzip -c backup_ems.sql.gz | docker exec -i postgres_ems_system \
  psql -U postgres -d ems_production

# Restore com recriação da database
docker exec -i postgres_ems_system psql -U postgres <<EOF
DROP DATABASE IF EXISTS ems_production;
CREATE DATABASE ems_production;
GRANT ALL PRIVILEGES ON DATABASE ems_production TO ems_user;
EOF

cat backup_ems.sql | docker exec -i postgres_ems_system \
  psql -U postgres -d ems_production
```

### Backup do volume completo (todas as databases)

```bash
# Parar o container
docker-compose stop

# Backup do volume
docker run --rm \
  -v postgres_ems_system_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/postgres_full_backup_$(date +%Y%m%d).tar.gz /data

# Reiniciar
docker-compose up -d
```

### Script de backup automático (cron)

Crie `/opt/ems_system/postgres/backup.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/opt/ems_system/backups"
RETENTION_DAYS=7

mkdir -p $BACKUP_DIR

# Backup EMS
docker exec postgres_ems_system pg_dump -U postgres -d ems_production \
  | gzip > $BACKUP_DIR/ems_$(date +%Y%m%d_%H%M%S).sql.gz

# Backup SMS
docker exec postgres_ems_system pg_dump -U postgres -d sms_production \
  | gzip > $BACKUP_DIR/sms_$(date +%Y%m%d_%H%M%S).sql.gz

# Limpar backups antigos
find $BACKUP_DIR -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
```

Adicione ao cron:

```bash
chmod +x /opt/ems_system/postgres/backup.sh

# Backup diário às 2h da manhã
crontab -e
0 2 * * * /opt/ems_system/postgres/backup.sh
```

## Manutenção

```bash
# Ver logs
docker-compose logs -f

# Restart
docker-compose restart

# Stop/Start
docker-compose stop
docker-compose up -d

# Verificar saúde
docker inspect postgres_ems_system | grep -A 10 Health

# Conectar ao PostgreSQL
docker exec -it postgres_ems_system psql -U postgres

# Ver tamanho das databases
docker exec postgres_ems_system psql -U postgres -c "\l+"

# Ver conexões ativas
docker exec postgres_ems_system psql -U postgres -c "SELECT * FROM pg_stat_activity;"
```

## Monitoramento de recursos

```bash
# Uso de memória e CPU
docker stats postgres_ems_system

# Tamanho do volume
docker system df -v | grep postgres_ems_system_data

# Logs de acesso
docker exec postgres_ems_system tail -f /var/lib/postgresql/data/log/postgresql-*.log
```

## Segurança

✅ **Isolamento de databases**: Cada serviço (EMS/SMS) tem sua própria database e usuário
✅ **Sem exposição pública**: Acesso apenas via rede Docker interna
✅ **Firewall VPS**: Proteção adicional no host
✅ **Nginx proxy**: Apps acessam via proxy reverso
✅ **Healthcheck**: Detecta problemas automaticamente

⚠️ **Checklist de produção:**
- [ ] Senha forte para usuário `postgres`
- [ ] Senhas únicas para `ems_user` e `sms_user`
- [ ] Arquivo `.env` não commitado no git
- [ ] Backup automático configurado (cron)
- [ ] Monitoramento de disco (volume pode encher)
- [ ] Logs rotacionados

## Troubleshooting

### Database com problemas (corrupção, inconsistência)

```bash
# 1. Criar backup de segurança
docker exec postgres_ems_system pg_dump -U postgres -d ems_production \
  > backup_antes_restore.sql

# 2. Restaurar de backup conhecido
cat backup_ems_limpo.sql | docker exec -i postgres_ems_system \
  psql -U postgres -d ems_production

# 3. Verificar integridade
docker exec postgres_ems_system psql -U postgres -d ems_production \
  -c "SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'public';"
```

### Container não inicia

```bash
# Ver logs de erro
docker-compose logs

# Verificar volume
docker volume inspect postgres_ems_system_data

# Último recurso: recriar volume (PERDE DADOS!)
docker-compose down
docker volume rm postgres_ems_system_data
docker-compose up -d
```

## Resposta: Volumes separados são viáveis?

**Curto**: Não é prático nem recomendado.

**Explicação**:
- PostgreSQL armazena TODAS as databases em `/var/lib/postgresql/data`
- Volumes separados só funcionam com **tablespaces** (adiciona complexidade)
- A solução atual (1 volume, múltiplas databases) é:
  ✅ **Eficiente**: Economiza recursos vs múltiplos containers
  ✅ **Flexível**: `pg_dump`/`pg_restore` por database individual
  ✅ **Confiável**: Fácil restaurar database com problema sem afetar outras
  ✅ **Simples**: Menos complexidade operacional

**Para restaurar database com problema:**
Simplesmente faça `pg_dump` da database problemática, recrie-a e restaure do backup. As outras databases não são afetadas.
