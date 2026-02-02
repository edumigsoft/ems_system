#!/bin/bash
set -e

# O comando psql abaixo usa as variáveis de ambiente ($EMS_DB_USER, etc)
# que foram passadas pelo docker-compose.

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    
    -- Configuração do EMS
    CREATE USER $EMS_DB_USER WITH PASSWORD '$EMS_DB_PASS';
    CREATE DATABASE $EMS_DB_NAME;
    GRANT ALL PRIVILEGES ON DATABASE $EMS_DB_NAME TO $EMS_DB_USER;
    
    -- Permissões no Schema Public para o EMS
    \c $EMS_DB_NAME
    GRANT ALL ON SCHEMA public TO $EMS_DB_USER;

    -- Voltar para o DB administrativo para criar o próximo
    \c $POSTGRES_DB

    -- Configuração do SMS
    -- CREATE USER $SMS_DB_USER WITH PASSWORD '$SMS_DB_PASS';
    -- CREATE DATABASE $SMS_DB_NAME;
    -- GRANT ALL PRIVILEGES ON DATABASE $SMS_DB_NAME TO $SMS_DB_USER;

    -- Permissões no Schema Public para o SMS
    -- \c $SMS_DB_NAME
    -- GRANT ALL ON SCHEMA public TO $SMS_DB_USER;

EOSQL