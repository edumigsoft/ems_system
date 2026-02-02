# Notebook Server Migrations

Este diretório contém migrations SQL para o banco de dados PostgreSQL do notebook server.

## Como Executar Migrations

### Opção 1: Via psql (Linha de Comando)

```bash
# Conectar ao banco de dados
psql -U seu_usuario -d ems_database

# Executar a migration
\i /caminho/completo/para/002_add_tags_column_and_index.sql
```

### Opção 2: Via DBeaver / pgAdmin

1. Abra o cliente PostgreSQL (DBeaver, pgAdmin, etc.)
2. Conecte ao banco de dados `ems_database`
3. Abra o arquivo SQL da migration
4. Execute o script

### Opção 3: Via Docker Exec (se usando container)

```bash
# Copiar migration para o container
docker cp 002_add_tags_column_and_index.sql postgres_container:/tmp/

# Executar dentro do container
docker exec -i postgres_container psql -U postgres -d ems_database < /tmp/002_add_tags_column_and_index.sql
```

## Migrations Disponíveis

### 002_add_tags_column_and_index.sql
**Data:** 2026-02-01
**Descrição:** Adiciona coluna `tags` (TEXT com JSON array) e índice GIN para buscas eficientes

**O que faz:**
- Adiciona coluna `tags` se não existir
- Cria índice GIN para operador `@>` (containment)
- Limpa dados existentes (converte strings vazias para NULL)

## Verificando se a Migration Foi Aplicada

```sql
-- Verificar se a coluna existe
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'notebooks' AND column_name = 'tags';

-- Verificar se o índice foi criado
SELECT indexname
FROM pg_indexes
WHERE tablename = 'notebooks' AND indexname = 'idx_notebooks_tags_gin';
```

## Rollback (Reverter)

Se precisar reverter a migration 002:

```sql
-- Remover índice
DROP INDEX IF EXISTS idx_notebooks_tags_gin;

-- Remover coluna (cuidado: perde dados!)
ALTER TABLE notebooks DROP COLUMN IF EXISTS tags;
```

## Notas Importantes

1. **Backup:** Sempre faça backup antes de executar migrations em produção
2. **Ordem:** Execute as migrations na ordem numérica (001, 002, 003...)
3. **Idempotência:** Todas as migrations usam `IF NOT EXISTS` para serem seguras de executar múltiplas vezes
4. **Performance:** O índice GIN melhora buscas em 10-100x dependendo do volume de dados
